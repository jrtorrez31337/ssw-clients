import { apiClient } from './client';
import type {
  AuthResponse,
  UserProfile,
  LoginCredentials,
  SignupCredentials
} from '@ssw/contracts';

export const authApi = {
  signup: (data: SignupCredentials) =>
    apiClient.post<AuthResponse>('/auth/signup', data),

  login: (data: LoginCredentials) =>
    apiClient.post<AuthResponse>('/auth/login', data),

  getMe: () => apiClient.get<UserProfile>('/auth/me'),
};
