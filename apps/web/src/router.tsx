import { createBrowserRouter, Navigate } from 'react-router-dom';
import { LoginPage } from './pages/LoginPage';
import { SignupPage } from './pages/SignupPage';
import { DashboardPage } from './pages/DashboardPage';
import { CharacterCreatePage } from './pages/CharacterCreatePage';
import { ShipCustomizePage } from './pages/ShipCustomizePage';
import { ProtectedRoute } from './components/layout/ProtectedRoute';

export const router = createBrowserRouter([
  {
    path: '/',
    element: <Navigate to="/login" replace />,
  },
  {
    path: '/login',
    element: <LoginPage />,
  },
  {
    path: '/signup',
    element: <SignupPage />,
  },
  {
    path: '/dashboard',
    element: (
      <ProtectedRoute>
        <DashboardPage />
      </ProtectedRoute>
    ),
  },
  {
    path: '/character-create',
    element: (
      <ProtectedRoute>
        <CharacterCreatePage />
      </ProtectedRoute>
    ),
  },
  {
    path: '/ship-create',
    element: (
      <ProtectedRoute>
        <ShipCustomizePage />
      </ProtectedRoute>
    ),
  },
]);
