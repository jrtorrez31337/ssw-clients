import { useEffect } from 'react';
import { useMutation, useQuery } from '@tanstack/react-query';
import { useNavigate } from 'react-router-dom';
import { authApi, type LoginRequest, type SignupRequest } from '../../../api/auth';
import { useAuthStore } from '../store';

export function useAuth() {
  const { isAuthenticated, profileId, displayName, setTokens, setProfile, logout } = useAuthStore();
  const navigate = useNavigate();

  // Login mutation
  const loginMutation = useMutation({
    mutationFn: authApi.login,
    onSuccess: async (data) => {
      setTokens(data.access_token, data.refresh_token);
      
      // Fetch user profile to get profile_id
      try {
        const profile = await authApi.getMe();
        setProfile(profile.profile_id, profile.display_name);
        navigate('/dashboard');
      } catch (error) {
        console.error('Failed to fetch profile:', error);
      }
    },
  });

  // Signup mutation
  const signupMutation = useMutation({
    mutationFn: authApi.signup,
    onSuccess: async (data) => {
      setTokens(data.access_token, data.refresh_token);
      
      // Fetch user profile to get profile_id
      try {
        const profile = await authApi.getMe();
        setProfile(profile.profile_id, profile.display_name);
        navigate('/dashboard');
      } catch (error) {
        console.error('Failed to fetch profile:', error);
      }
    },
  });

  // Fetch profile query (used on app initialization)
  const profileQuery = useQuery({
    queryKey: ['profile'],
    queryFn: authApi.getMe,
    enabled: isAuthenticated && !profileId,
    retry: false,
  });

  // Update profile when query succeeds
  useEffect(() => {
    if (profileQuery.data) {
      setProfile(profileQuery.data.profile_id, profileQuery.data.display_name);
    }
  }, [profileQuery.data, setProfile]);

  const handleLogin = (data: LoginRequest) => {
    loginMutation.mutate(data);
  };

  const handleSignup = (data: SignupRequest) => {
    signupMutation.mutate(data);
  };

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  return {
    isAuthenticated,
    profileId,
    displayName,
    login: handleLogin,
    signup: handleSignup,
    logout: handleLogout,
    loginError: loginMutation.error,
    signupError: signupMutation.error,
    isLoggingIn: loginMutation.isPending,
    isSigningUp: signupMutation.isPending,
  };
}
