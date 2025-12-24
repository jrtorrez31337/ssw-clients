import { apiClient } from './client';
import type { Ship, CreateShipRequest } from '@ssw/contracts';

export const shipApi = {
  create: (data: CreateShipRequest) => apiClient.post<Ship>('/ships', data),

  getById: (id: string) => apiClient.get<Ship>(`/ships/${id}`),

  getByOwner: (ownerId: string) =>
    apiClient.get<Ship[]>(`/ships/by-owner/${ownerId}`),

  update: (id: string, name: string) =>
    apiClient.patch<{ message: string }>(`/ships/${id}`, { name }),
};
