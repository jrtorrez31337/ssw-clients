import { apiClient } from './client';

export interface CharacterAttributes extends Record<string, number> {
  piloting: number;
  engineering: number;
  science: number;
  tactics: number;
  leadership: number;
}

export interface CreateCharacterRequest {
  profile_id: string;
  name: string;
  home_sector: string;
  attributes: CharacterAttributes;
}

export interface Character {
  id: string;
  profile_id: string;
  name: string;
  home_sector: string;
  attributes: CharacterAttributes;
  created_at: string;
}

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
