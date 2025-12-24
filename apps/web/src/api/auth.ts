import { apiClient } from './client';
import type {
  AuthResponse,
  UserProfile,
  LoginCredentials,
  SignupCredentials,
} from '@ssw/contracts';

export const authApi = {
  signup: async (data: SignupCredentials) => {
    const response = await apiClient.post<{ data: AuthResponse }>('/auth/signup', data);
    return response.data.data;
  },

  login: async (data: LoginCredentials) => {
    const response = await apiClient.post<{ data: AuthResponse }>('/auth/login', data);
    return response.data.data;
  },

  getMe: async () => {
    const response = await apiClient.get<{ data: UserProfile }>('/auth/me');
    return response.data.data;
  },

  refresh: async (refreshToken: string) => {
    const response = await apiClient.post<{ data: { access_token: string; token_type: string; expires_in: number } }>(
      '/auth/refresh',
      { refresh_token: refreshToken }
    );
    return response.data.data;
  },
};
