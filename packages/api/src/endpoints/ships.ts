/**
 * Ship API endpoints
 */

import type { Ship, CreateShipRequest } from '@ssw/contracts';
import type { ApiClient } from '../client.js';

export function createShipApi(client: ApiClient) {
  return {
    create: (request: CreateShipRequest) =>
      client.post<Ship>('/ships', request),

    getById: (id: string) => client.get<Ship>(`/ships/${id}`),

    getByOwner: (ownerId: string) =>
      client.get<Ship[]>(`/ships/by-owner/${ownerId}`),

    update: (id: string, name: string) =>
      client.patch<{ message: string }>(`/ships/${id}`, { name }),
  };
}

export type ShipApi = ReturnType<typeof createShipApi>;
