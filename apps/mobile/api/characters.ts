import { apiClient } from './client';
import type { Character, CreateCharacterRequest } from '@ssw/contracts';

// Extend the base request with profile_id which is required by this client
export interface CreateCharacterRequestWithProfile extends Omit<CreateCharacterRequest, 'home_sector'> {
  profile_id: string;
  home_sector: string;
}

export const characterApi = {
  create: (data: CreateCharacterRequestWithProfile) =>
    apiClient.post<Character>('/characters', data),

  getById: (id: string) => apiClient.get<Character>(`/characters/${id}`),

  getByProfile: (profileId: string) =>
    apiClient.get<Character[]>(`/characters/by-profile/${profileId}`),

  update: (id: string, name: string) =>
    apiClient.patch<{ message: string }>(`/characters/${id}`, { name }),
};
