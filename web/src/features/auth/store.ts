import { create } from 'zustand';

interface AuthState {
  accessToken: string | null;
  refreshToken: string | null;
  profileId: string | null;
  displayName: string | null;
  isAuthenticated: boolean;

  setTokens: (accessToken: string, refreshToken: string) => void;
  setProfile: (profileId: string, displayName: string) => void;
  logout: () => void;
  initialize: () => void;
}

export const useAuthStore = create<AuthState>((set) => ({
  accessToken: null,
  refreshToken: null,
  profileId: null,
  displayName: null,
  isAuthenticated: false,

  initialize: () => {
    const accessToken = localStorage.getItem('access_token');
    const refreshToken = localStorage.getItem('refresh_token');
    const profileId = localStorage.getItem('profile_id');
    const displayName = localStorage.getItem('display_name');
    
    set({
      accessToken,
      refreshToken,
      profileId,
      displayName,
      isAuthenticated: !!accessToken,
    });
  },

  setTokens: (accessToken, refreshToken) => {
    localStorage.setItem('access_token', accessToken);
    localStorage.setItem('refresh_token', refreshToken);
    set({ accessToken, refreshToken, isAuthenticated: true });
  },

  setProfile: (profileId, displayName) => {
    localStorage.setItem('profile_id', profileId);
    localStorage.setItem('display_name', displayName);
    set({ profileId, displayName });
  },

  logout: () => {
    localStorage.removeItem('access_token');
    localStorage.removeItem('refresh_token');
    localStorage.removeItem('profile_id');
    localStorage.removeItem('display_name');
    set({
      accessToken: null,
      refreshToken: null,
      profileId: null,
      displayName: null,
      isAuthenticated: false,
    });
  },
}));
