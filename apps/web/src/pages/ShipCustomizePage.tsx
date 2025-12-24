import React, { useState } from 'react';
import { useMutation } from '@tanstack/react-query';
import { useNavigate } from 'react-router-dom';
import { shipApi, type ShipType, type ShipStats, calculateShipStats } from '../api/ships';
import { useAuthStore } from '../features/auth/store';
import { usePointAllocation } from '../hooks/usePointAllocation';
import { ShipPreview } from '../scenes/ShipPreview';
import { Card } from '../components/ui/Card';
import { Input } from '../components/ui/Input';
import { Button } from '../components/ui/Button';
import './ShipCustomizePage.css';

const SHIP_TYPES: Array<{
  type: ShipType;
  name: string;
  description: string;
  bonuses: string[];
}> = [
  {
    type: 'scout',
    name: 'Scout',
    description: 'Fast and agile reconnaissance vessel',
    bonuses: ['+2 Speed', '+2 Sensors'],
  },
  {
    type: 'fighter',
    name: 'Fighter',
    description: 'Heavy combat ship with strong defenses',
    bonuses: ['+300 Hull HP', '+100 Shield'],
  },
  {
    type: 'trader',
    name: 'Trader',
    description: 'Cargo hauler for profitable trade routes',
    bonuses: ['+100 Hull HP', '+40 Cargo'],
  },
  {
    type: 'explorer',
    name: 'Explorer',
    description: 'Long-range vessel for deep space exploration',
    bonuses: ['+1 Speed', '+10 Cargo', '+2 Sensors'],
  },
];

const STAT_INFO = {
  hull_strength: {
    name: 'Hull Strength',
    description: 'Ship durability (×100 HP)',
    icon: '🛡️',
  },
  shield_capacity: {
    name: 'Shield Capacity',
    description: 'Energy shields (×50 Shield)',
    icon: '✨',
  },
  speed: {
    name: 'Speed',
    description: 'Travel and combat speed',
    icon: '⚡',
  },
  cargo_space: {
    name: 'Cargo Space',
    description: 'Storage capacity (×10 units)',
    icon: '📦',
  },
  sensors: {
    name: 'Sensors',
    description: 'Detection and scanning range',
    icon: '📡',
  },
};

export function ShipCustomizePage() {
  const [shipType, setShipType] = useState<ShipType>('scout');
  const [name, setName] = useState('');
  const profileId = useAuthStore((state) => state.profileId);
  const navigate = useNavigate();

  const {
    allocation,
    remaining,
    increment,
    decrement,
    isValid,
  } = usePointAllocation<ShipStats>({
    totalPoints: 30,
    minPerStat: 1,
    maxPerStat: 15,
    stats: ['hull_strength', 'shield_capacity', 'speed', 'cargo_space', 'sensors'],
  });

  const createMutation = useMutation({
    mutationFn: shipApi.create,
    onSuccess: (ship) => {
      console.log('Ship created:', ship);
      navigate('/dashboard');
    },
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!profileId || !isValid) return;

    createMutation.mutate({
      owner_id: profileId,
      ship_type: shipType,
      name: name || undefined,
      stat_allocation: allocation,
    });
  };

  const finalStats = calculateShipStats(allocation, shipType);

  return (
    <div className="creation-container">
      <div className="creation-content ship-content">
        <div className="creation-header">
          <h1 className="creation-title">Customize Your Ship</h1>
          <p className="creation-subtitle">Design your vessel for the perfect mission</p>
        </div>

        <div className="ship-layout">
          <div className="ship-main">
            <Card title="Ship Type">
              <div className="ship-types">
                {SHIP_TYPES.map((type) => (
                  <button
                    key={type.type}
                    type="button"
                    className={`ship-type-card ${shipType === type.type ? 'active' : ''}`}
                    onClick={() => setShipType(type.type)}
                  >
                    <h3>{type.name}</h3>
                    <p className="type-description">{type.description}</p>
                    <div className="type-bonuses">
                      {type.bonuses.map((bonus, i) => (
                        <span key={i} className="bonus-badge">{bonus}</span>
                      ))}
                    </div>
                  </button>
                ))}
              </div>
            </Card>

            <Card title="Ship Configuration">
              <form onSubmit={handleSubmit}>
                <Input
                  type="text"
                  label="Ship Name (Optional)"
                  placeholder="Star Runner"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  maxLength={32}
                />

                <div className="points-header">
                  <h3>Stat Allocation</h3>
                  <div className="points-remaining">
                    <span className="points-label">Points Remaining:</span>
                    <span className={`points-value ${remaining === 0 ? 'complete' : ''}`}>
                      {remaining} / 30
                    </span>
                  </div>
                </div>

                <div className="stats-list">
                  {Object.entries(allocation).map(([stat, value]) => {
                    const info = STAT_INFO[stat as keyof typeof STAT_INFO];
                    return (
                      <div key={stat} className="stat-item">
                        <div className="stat-header">
                          <div className="stat-info">
                            <span className="stat-icon">{info.icon}</span>
                            <div>
                              <div className="stat-name">{info.name}</div>
                              <div className="stat-description">{info.description}</div>
                            </div>
                          </div>
                          <div className="stat-value">{value}</div>
                        </div>

                        <div className="stat-controls">
                          <Button
                            type="button"
                            size="small"
                            variant="secondary"
                            onClick={() => decrement(stat)}
                            disabled={value <= 1}
                          >
                            −
                          </Button>

                          <div className="stat-bar">
                            <div
                              className="stat-fill"
                              style={{ width: `${(value / 15) * 100}%` }}
                            />
                          </div>

                          <Button
                            type="button"
                            size="small"
                            variant="secondary"
                            onClick={() => increment(stat)}
                            disabled={value >= 15 || remaining <= 0}
                          >
                            +
                          </Button>
                        </div>
                      </div>
                    );
                  })}
                </div>

                {createMutation.isError && (
                  <div className="error-box">
                    {(createMutation.error as any)?.response?.data?.error?.message || 
                      'Failed to create ship. Please try again.'}
                  </div>
                )}

                <div className="form-actions">
                  <Button
                    type="submit"
                    disabled={!isValid || createMutation.isPending}
                    size="large"
                  >
                    {createMutation.isPending ? 'Creating...' : 'Launch Ship'}
                  </Button>
                </div>
              </form>
            </Card>
          </div>

          <div className="ship-sidebar">
            <Card title="Ship Preview">
              <ShipPreview shipType={shipType} />
            </Card>

            <Card title="Final Stats">
              <div className="final-stats">
                <div className="final-stat">
                  <span className="final-stat-label">Hull Points</span>
                  <span className="final-stat-value">{finalStats.hull_max}</span>
                </div>
                <div className="final-stat">
                  <span className="final-stat-label">Shield Points</span>
                  <span className="final-stat-value">{finalStats.shield_max}</span>
                </div>
                <div className="final-stat">
                  <span className="final-stat-label">Speed</span>
                  <span className="final-stat-value">{finalStats.speed}</span>
                </div>
                <div className="final-stat">
                  <span className="final-stat-label">Cargo Capacity</span>
                  <span className="final-stat-value">{finalStats.cargo_capacity}</span>
                </div>
                <div className="final-stat">
                  <span className="final-stat-label">Sensor Range</span>
                  <span className="final-stat-value">{finalStats.sensor_range}</span>
                </div>
              </div>
            </Card>
          </div>
        </div>
      </div>
    </div>
  );
}
