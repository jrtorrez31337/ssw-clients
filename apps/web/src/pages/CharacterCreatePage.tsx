import React, { useState } from 'react';
import { useMutation } from '@tanstack/react-query';
import { useNavigate } from 'react-router-dom';
import { characterApi, type CharacterAttributes } from '../api/characters';
import { useAuthStore } from '../features/auth/store';
import { usePointAllocation } from '../hooks/usePointAllocation';
import { Card } from '../components/ui/Card';
import { Input } from '../components/ui/Input';
import { Button } from '../components/ui/Button';
import './CharacterCreatePage.css';

const ATTRIBUTE_INFO = {
  piloting: {
    name: 'Piloting',
    description: 'Ship maneuverability and flight control',
    icon: '🚀',
  },
  engineering: {
    name: 'Engineering',
    description: 'Tech/repair bonuses and ship systems',
    icon: '🔧',
  },
  science: {
    name: 'Science',
    description: 'Research, discovery, and scanning',
    icon: '🔬',
  },
  tactics: {
    name: 'Tactics',
    description: 'Combat effectiveness and strategy',
    icon: '⚔️',
  },
  leadership: {
    name: 'Leadership',
    description: 'Crew bonuses and faction influence',
    icon: '👑',
  },
};

export function CharacterCreatePage() {
  const [name, setName] = useState('');
  const [homeSector] = useState('sol');
  const profileId = useAuthStore((state) => state.profileId);
  const navigate = useNavigate();

  const {
    allocation,
    remaining,
    increment,
    decrement,
    isValid,
  } = usePointAllocation<CharacterAttributes>({
    totalPoints: 20,
    minPerStat: 1,
    maxPerStat: 10,
    stats: ['piloting', 'engineering', 'science', 'tactics', 'leadership'],
  });

  const createMutation = useMutation({
    mutationFn: characterApi.create,
    onSuccess: (character) => {
      console.log('Character created:', character);
      navigate('/ship-create');
    },
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!profileId || !isValid || name.length < 3) return;

    createMutation.mutate({
      profile_id: profileId,
      name,
      home_sector: homeSector,
      attributes: allocation,
    });
  };

  return (
    <div className="creation-container">
      <div className="creation-content">
        <div className="creation-header">
          <h1 className="creation-title">Create Your Character</h1>
          <p className="creation-subtitle">Define your captain's attributes and skills</p>
        </div>

        <Card>
          <form onSubmit={handleSubmit}>
            <div className="form-section">
              <Input
                type="text"
                label="Character Name"
                placeholder="Captain Stellar"
                value={name}
                onChange={(e) => setName(e.target.value)}
                minLength={3}
                maxLength={32}
                required
              />

              <div className="sector-info">
                <label>Home Sector</label>
                <div className="sector-badge">Sol System</div>
              </div>
            </div>

            <div className="form-section">
              <div className="points-header">
                <h3>Attribute Allocation</h3>
                <div className="points-remaining">
                  <span className="points-label">Points Remaining:</span>
                  <span className={`points-value ${remaining === 0 ? 'complete' : ''}`}>
                    {remaining} / 20
                  </span>
                </div>
              </div>

              <div className="attributes-list">
                {Object.entries(allocation).map(([stat, value]) => {
                  const info = ATTRIBUTE_INFO[stat as keyof typeof ATTRIBUTE_INFO];
                  return (
                    <div key={stat} className="attribute-item">
                      <div className="attribute-header">
                        <div className="attribute-info">
                          <span className="attribute-icon">{info.icon}</span>
                          <div>
                            <div className="attribute-name">{info.name}</div>
                            <div className="attribute-description">{info.description}</div>
                          </div>
                        </div>
                        <div className="attribute-value">{value}</div>
                      </div>

                      <div className="attribute-controls">
                        <Button
                          type="button"
                          size="small"
                          variant="secondary"
                          onClick={() => decrement(stat)}
                          disabled={value <= 1}
                        >
                          −
                        </Button>

                        <div className="attribute-bar">
                          <div
                            className="attribute-fill"
                            style={{ width: `${(value / 10) * 100}%` }}
                          />
                          <div className="attribute-markers">
                            {[...Array(10)].map((_, i) => (
                              <div key={i} className="marker" />
                            ))}
                          </div>
                        </div>

                        <Button
                          type="button"
                          size="small"
                          variant="secondary"
                          onClick={() => increment(stat)}
                          disabled={value >= 10 || remaining <= 0}
                        >
                          +
                        </Button>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>

            {createMutation.isError && (
              <div className="error-box">
                {(createMutation.error as any)?.response?.data?.error?.message || 
                  'Failed to create character. Please try again.'}
              </div>
            )}

            <div className="form-actions">
              <Button
                type="submit"
                disabled={!isValid || name.length < 3 || createMutation.isPending}
                size="large"
              >
                {createMutation.isPending ? 'Creating...' : 'Create Character'}
              </Button>
            </div>
          </form>
        </Card>
      </div>
    </div>
  );
}
