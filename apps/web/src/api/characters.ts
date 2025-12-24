import { apiClient } from './client';
import type { Character, CharacterAttributes } from '@ssw/contracts';

// Web-specific request type that includes profile_id
export interface CreateCharacterRequest {
  profile_id: string;
  name: string;
  home_sector: string;
  attributes: CharacterAttributes;
}

// Re-export for backward compatibility
export type { CharacterAttributes };

export const characterApi = {
  create: async (data: CreateCharacterRequest) => {
    const response = await apiClient.post<{ data: Character }>('/characters', data);
    return response.data.data;
  },

  getById: async (id: string) => {
    const response = await apiClient.get<{ data: Character }>(`/characters/${id}`);
    return response.data.data;
  },

  getByProfile: async (profileId: string) => {
    const response = await apiClient.get<{ data: Character[] }>(
      `/characters/by-profile/${profileId}`
    );
    return response.data.data;
  },

  update: async (id: string, name: string) => {
    const response = await apiClient.patch<{ data: { message: string } }>(
      `/characters/${id}`,
      { name }
    );
    return response.data.data;
  },
};
