import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../features/auth/hooks/useAuth';
import { Card } from '../components/ui/Card';
import { Input } from '../components/ui/Input';
import { Button } from '../components/ui/Button';
import './AuthPages.css';

export function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const { login, isLoggingIn, loginError } = useAuth();

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    login({ email, password });
  };

  return (
    <div className="auth-container">
      <div className="auth-content">
        <div className="auth-header">
          <h1 className="game-title">SSW Galaxy</h1>
          <p className="game-subtitle">Explore the stars. Command your destiny.</p>
        </div>

        <Card className="auth-card">
          <h2 className="auth-title">Welcome Back</h2>
          <p className="auth-description">Sign in to continue your journey</p>

          <form onSubmit={handleSubmit}>
            <Input
              type="email"
              label="Email"
              placeholder="captain@galaxy.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />

            <Input
              type="password"
              label="Password"
              placeholder="••••••••"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />

            {loginError && (
              <div className="error-box">
                {(loginError as any)?.response?.data?.error?.message || 'Login failed. Please try again.'}
              </div>
            )}

            <Button type="submit" disabled={isLoggingIn} className="auth-button">
              {isLoggingIn ? 'Signing in...' : 'Sign In'}
            </Button>
          </form>

          <p className="auth-footer">
            Don't have an account?{' '}
            <Link to="/signup" className="auth-link">
              Create one
            </Link>
          </p>
        </Card>
      </div>
    </div>
  );
}
