/**
 * Token storage abstraction for platform-specific implementations
 */

export interface TokenStore {
  /**
   * Get the current access token
   */
  getAccessToken(): Promise<string | null> | string | null;

  /**
   * Get the current refresh token
   */
  getRefreshToken(): Promise<string | null> | string | null;

  /**
   * Store access and refresh tokens
   */
  setTokens(accessToken: string, refreshToken: string): Promise<void> | void;

  /**
   * Store only the access token (after refresh)
   */
  setAccessToken(accessToken: string): Promise<void> | void;

  /**
   * Clear all stored tokens
   */
  clearTokens(): Promise<void> | void;

  /**
   * Optional: Store profile ID
   */
  setProfileId?(profileId: string): Promise<void> | void;

  /**
   * Optional: Get profile ID
   */
  getProfileId?(): Promise<string | null> | string | null;
}

/**
 * Web implementation using localStorage
 */
export class WebTokenStore implements TokenStore {
  getAccessToken(): string | null {
    return localStorage.getItem('access_token');
  }

  getRefreshToken(): string | null {
    return localStorage.getItem('refresh_token');
  }

  setTokens(accessToken: string, refreshToken: string): void {
    localStorage.setItem('access_token', accessToken);
    localStorage.setItem('refresh_token', refreshToken);
  }

  setAccessToken(accessToken: string): void {
    localStorage.setItem('access_token', accessToken);
  }

  clearTokens(): void {
    localStorage.removeItem('access_token');
    localStorage.removeItem('refresh_token');
    localStorage.removeItem('profile_id');
  }

  setProfileId(profileId: string): void {
    localStorage.setItem('profile_id', profileId);
  }

  getProfileId(): string | null {
    return localStorage.getItem('profile_id');
  }
}
