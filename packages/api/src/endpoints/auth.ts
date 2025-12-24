/**
 * Authentication API endpoints
 */

import type {
  AuthResponse,
  UserProfile,
  LoginCredentials,
  SignupCredentials,
} from '@ssw/contracts';
import type { ApiClient } from '../client.js';

export function createAuthApi(client: ApiClient) {
  return {
    signup: (credentials: SignupCredentials) =>
      client.post<AuthResponse>('/auth/signup', credentials),

    login: (credentials: LoginCredentials) =>
      client.post<AuthResponse>('/auth/login', credentials),

    getMe: () => client.get<UserProfile>('/auth/me'),

    refresh: (refreshToken: string) =>
      client.post<{ access_token: string }>('/auth/refresh', {
        refresh_token: refreshToken,
      }),
  };
}

export type AuthApi = ReturnType<typeof createAuthApi>;
