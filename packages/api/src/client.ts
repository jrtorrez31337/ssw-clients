/**
 * Shared API client with automatic token refresh and error handling
 */

import type { ApiErrorResponse, ApiResponse } from '@ssw/contracts';
import type { TokenStore } from './token-store.js';

export interface ApiClientConfig {
  baseURL: string;
  tokenStore: TokenStore;
  onUnauthorized?: () => void;
}

interface RequestConfig {
  method: 'GET' | 'POST' | 'PATCH' | 'DELETE';
  body?: unknown;
  headers?: Record<string, string>;
}

export class ApiClient {
  private baseURL: string;
  private tokenStore: TokenStore;
  private onUnauthorized?: () => void;
  private isRefreshing = false;
  private refreshPromise: Promise<string | null> | null = null;

  constructor(config: ApiClientConfig) {
    this.baseURL = config.baseURL;
    this.tokenStore = config.tokenStore;
    this.onUnauthorized = config.onUnauthorized;
  }

  async request<T>(endpoint: string, config: RequestConfig): Promise<T> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      ...config.headers,
    };

    const token = await Promise.resolve(this.tokenStore.getAccessToken());
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }

    const requestInit: RequestInit = {
      method: config.method,
      headers,
      body: config.body ? JSON.stringify(config.body) : undefined,
    };

    try {
      const response = await fetch(`${this.baseURL}${endpoint}`, requestInit);

      // Handle 401 with token refresh
      if (response.status === 401 && token && !endpoint.includes('/auth/')) {
        const newToken = await this.handleTokenRefresh();
        if (newToken) {
          headers['Authorization'] = `Bearer ${newToken}`;
          const retryResponse = await fetch(`${this.baseURL}${endpoint}`, {
            ...requestInit,
            headers,
          });
          return this.handleResponse<T>(retryResponse);
        }
      }

      return this.handleResponse<T>(response);
    } catch (error) {
      console.error('API request failed:', error);
      throw new Error('Failed to connect to backend');
    }
  }

  private async handleResponse<T>(response: Response): Promise<T> {
    const contentType = response.headers.get('content-type');
    const isJson = contentType?.includes('application/json');

    if (!response.ok) {
      if (isJson) {
        const errorData = (await response.json()) as ApiErrorResponse;
        throw new Error(errorData.error.message || 'Request failed');
      } else {
        throw new Error(`Request failed with status ${response.status}`);
      }
    }

    if (isJson) {
      const data = (await response.json()) as ApiResponse<T>;
      return data.data;
    }

    return {} as T;
  }

  private async handleTokenRefresh(): Promise<string | null> {
    if (this.isRefreshing && this.refreshPromise) {
      return this.refreshPromise;
    }

    this.isRefreshing = true;
    this.refreshPromise = this.refreshToken();

    try {
      const newToken = await this.refreshPromise;
      return newToken;
    } finally {
      this.isRefreshing = false;
      this.refreshPromise = null;
    }
  }

  private async refreshToken(): Promise<string | null> {
    try {
      const refreshToken = await Promise.resolve(
        this.tokenStore.getRefreshToken()
      );
      if (!refreshToken) {
        throw new Error('No refresh token');
      }

      const response = await fetch(`${this.baseURL}/auth/refresh`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refresh_token: refreshToken }),
      });

      if (!response.ok) {
        throw new Error('Token refresh failed');
      }

      const data = (await response.json()) as ApiResponse<{
        access_token: string;
      }>;
      const newToken = data.data.access_token;

      await Promise.resolve(this.tokenStore.setAccessToken(newToken));
      return newToken;
    } catch (error) {
      console.error('Token refresh failed:', error);
      await Promise.resolve(this.tokenStore.clearTokens());
      this.onUnauthorized?.();
      return null;
    }
  }

  async get<T>(endpoint: string): Promise<T> {
    return this.request<T>(endpoint, { method: 'GET' });
  }

  async post<T>(endpoint: string, body?: unknown): Promise<T> {
    return this.request<T>(endpoint, { method: 'POST', body });
  }

  async patch<T>(endpoint: string, body?: unknown): Promise<T> {
    return this.request<T>(endpoint, { method: 'PATCH', body });
  }

  async delete<T>(endpoint: string): Promise<T> {
    return this.request<T>(endpoint, { method: 'DELETE' });
  }
}
