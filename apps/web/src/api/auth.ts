import { apiClient } from './client';

export interface SignupRequest {
  email: string;
  password: string;
  display_name: string;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface AuthResponse {
  access_token: string;
  refresh_token: string;
  token_type: string;
  expires_in: number;
  session_id: string;
}

export interface UserProfile {
  account_id: string;
  email: string;
  status: string;
  home_region: string;
  profile_id: string;
  display_name: string;
  active_sessions: number;
}

export const authApi = {
  signup: async (data: SignupRequest) => {
    const response = await apiClient.post<{ data: AuthResponse }>('/auth/signup', data);
    return response.data.data;
  },

  login: async (data: LoginRequest) => {
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
