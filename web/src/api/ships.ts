import { apiClient } from './client';

export interface ShipStats extends Record<string, number> {
  hull_strength: number;
  shield_capacity: number;
  speed: number;
  cargo_space: number;
  sensors: number;
}

export type ShipType = 'scout' | 'fighter' | 'trader' | 'explorer';

export interface CreateShipRequest {
  owner_id: string;
  ship_type: ShipType;
  name?: string;
  stat_allocation: ShipStats;
}

export interface Ship {
  id: string;
  owner_id: string;
  ship_type: ShipType;
  name?: string;
  hull_points: number;
  hull_max: number;
  shield_points: number;
  shield_max: number;
  cargo_capacity: number;
  location_sector: string;
  created_at: string;
  stat_allocation?: ShipStats;
}

export const shipApi = {
  create: async (data: CreateShipRequest) => {
    const response = await apiClient.post<{ data: Ship }>('/ships', data);
    return response.data.data;
  },

  getById: async (id: string) => {
    const response = await apiClient.get<{ data: Ship }>(`/ships/${id}`);
    return response.data.data;
  },

  getByOwner: async (ownerId: string) => {
    const response = await apiClient.get<{ data: Ship[] }>(
      `/ships/by-owner/${ownerId}`
    );
    return response.data.data;
  },

  update: async (id: string, name: string) => {
    const response = await apiClient.patch<{ data: { message: string } }>(
      `/ships/${id}`,
      { name }
    );
    return response.data.data;
  },
};

// Ship type bonuses for reference
interface ShipBonuses {
  hull?: number;
  shield?: number;
  speed?: number;
  cargo?: number;
  sensors?: number;
}

export const SHIP_TYPE_BONUSES: Record<ShipType, ShipBonuses> = {
  scout: {
    speed: 2,
    sensors: 2,
  },
  fighter: {
    hull: 300,
    shield: 100,
  },
  trader: {
    hull: 100,
    cargo: 40,
  },
  explorer: {
    speed: 1,
    cargo: 10,
    sensors: 2,
  },
};

// Calculate final stats with bonuses
export function calculateShipStats(stats: ShipStats, shipType: ShipType) {
  const bonuses = SHIP_TYPE_BONUSES[shipType];
  
  return {
    hull_max: stats.hull_strength * 100 + (bonuses.hull || 0),
    shield_max: stats.shield_capacity * 50 + (bonuses.shield || 0),
    speed: stats.speed + (bonuses.speed || 0),
    cargo_capacity: stats.cargo_space * 10 + (bonuses.cargo || 0),
    sensor_range: stats.sensors + (bonuses.sensors || 0),
  };
}
