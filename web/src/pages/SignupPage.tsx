import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../features/auth/hooks/useAuth';
import { Card } from '../components/ui/Card';
import { Input } from '../components/ui/Input';
import { Button } from '../components/ui/Button';
import './AuthPages.css';

export function SignupPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [displayName, setDisplayName] = useState('');
  const { signup, isSigningUp, signupError } = useAuth();

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    signup({ email, password, display_name: displayName });
  };

  return (
    <div className="auth-container">
      <div className="auth-content">
        <div className="auth-header">
          <h1 className="game-title">SSW Galaxy</h1>
          <p className="game-subtitle">Explore the stars. Command your destiny.</p>
        </div>

        <Card className="auth-card">
          <h2 className="auth-title">Create Account</h2>
          <p className="auth-description">Join thousands of explorers in the galaxy</p>

          <form onSubmit={handleSubmit}>
            <Input
              type="text"
              label="Display Name"
              placeholder="Captain Stellar"
              value={displayName}
              onChange={(e) => setDisplayName(e.target.value)}
              required
            />

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
              minLength={8}
              required
            />

            {signupError && (
              <div className="error-box">
                {(signupError as any)?.response?.data?.error?.message || 'Signup failed. Please try again.'}
              </div>
            )}

            <Button type="submit" disabled={isSigningUp} className="auth-button">
              {isSigningUp ? 'Creating account...' : 'Create Account'}
            </Button>
          </form>

          <p className="auth-footer">
            Already have an account?{' '}
            <Link to="/login" className="auth-link">
              Sign in
            </Link>
          </p>
        </Card>
      </div>
    </div>
  );
}
