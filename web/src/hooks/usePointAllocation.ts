import { useState } from 'react';

interface UsePointAllocationOptions {
  totalPoints: number;
  minPerStat: number;
  maxPerStat: number;
  stats: string[];
}

export function usePointAllocation<T extends Record<string, number>>({
  totalPoints,
  minPerStat,
  maxPerStat,
  stats,
}: UsePointAllocationOptions) {
  const [allocation, setAllocation] = useState<T>(
    stats.reduce((acc, stat) => ({ ...acc, [stat]: minPerStat }), {} as T)
  );

  const allocated = Object.values(allocation).reduce((sum, val) => sum + val, 0);
  const remaining = totalPoints - allocated;

  const increment = (stat: string) => {
    if (remaining > 0 && allocation[stat] < maxPerStat) {
      setAllocation({ ...allocation, [stat]: allocation[stat] + 1 } as T);
    }
  };

  const decrement = (stat: string) => {
    if (allocation[stat] > minPerStat) {
      setAllocation({ ...allocation, [stat]: allocation[stat] - 1 } as T);
    }
  };

  const setValue = (stat: string, value: number) => {
    if (value >= minPerStat && value <= maxPerStat) {
      setAllocation({ ...allocation, [stat]: value } as T);
    }
  };

  const reset = () => {
    setAllocation(stats.reduce((acc, stat) => ({ ...acc, [stat]: minPerStat }), {} as T));
  };

  const isValid = remaining === 0;

  return {
    allocation,
    allocated,
    remaining,
    increment,
    decrement,
    setValue,
    reset,
    isValid,
  };
}
