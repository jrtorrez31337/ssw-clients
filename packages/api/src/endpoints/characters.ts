/**
 * Character API endpoints
 */

import type { Character, CharacterAttributes } from '@ssw/contracts';
import type { ApiClient } from '../client.js';

export interface CreateCharacterRequest {
  profile_id: string;
  name: string;
  home_sector: string;
  attributes: CharacterAttributes;
}

export function createCharacterApi(client: ApiClient) {
  return {
    create: (request: CreateCharacterRequest) =>
      client.post<Character>('/characters', request),

    getById: (id: string) => client.get<Character>(`/characters/${id}`),

    getByProfile: (profileId: string) =>
      client.get<Character[]>(`/characters/by-profile/${profileId}`),

    update: (id: string, name: string) =>
      client.patch<{ message: string }>(`/characters/${id}`, { name }),
  };
}

export type CharacterApi = ReturnType<typeof createCharacterApi>;
