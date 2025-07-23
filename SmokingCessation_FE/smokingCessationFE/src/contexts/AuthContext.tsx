// import React, { createContext, useContext, useState, useCallback, useEffect } from 'react';
// import { authService, type LoginResponse, type User } from '../api/services/authService';
// import apiClient from '../api/apiClient';

// interface AuthContextType {
//   user: User | null;
//   login: (email: string, password: string) => Promise<void>;
//   logout: () => void;
//   isAuthenticated: boolean;
// }

// const AuthContext = createContext<AuthContextType | undefined>(undefined);

// export function AuthProvider({ children }: { children: React.ReactNode }) {
//   const [user, setUser] = useState<User | null>(null);
//   const [isLoading, setIsLoading] = useState(true);

//   // Fetch user data when component mounts
//   useEffect(() => {
//     const fetchUserData = async () => {
//       const token = localStorage.getItem('authToken');
//       if (token) {
//         try {
//           const response = await apiClient.get('/account/profile');
//           setUser(response.data);
//         } catch (error) {
//           console.error('Error fetching user data:', error);
//           // Clean up on error
//           localStorage.removeItem('authToken');
//           localStorage.removeItem('user');
//           setUser(null);
//         }
//       }
//       setIsLoading(false);
//     };

//     fetchUserData();
//   }, []);

//   const login = useCallback(async (email: string, password: string) => {
//     try {
//       const response = await authService.login({ email, password });
//       if (!response || !response.user) {
//         throw new Error('Invalid login response');
//       }
//       setUser(response.user);
//       localStorage.setItem('authToken', response.token);
//       localStorage.setItem('user', JSON.stringify(response.user));
//     } catch (error) {
//       console.error('Login error:', error);
//       localStorage.removeItem('user');
//       localStorage.removeItem('authToken');
//       setUser(null);
//       throw error;
//     }
//   }, []);

//   const logout = useCallback(() => {
//     setUser(null);
//     localStorage.removeItem('user');
//     localStorage.removeItem('authToken');
//   }, []);

//   const value = {
//     user,
//     login,
//     logout,
//     isAuthenticated: !!user,
//   };

//   if (isLoading) {
//     return null; // or a loading spinner
//   }

//   return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
// }

// export function useAuth() {
//   const context = useContext(AuthContext);
//   if (context === undefined) {
//     throw new Error('useAuth must be used within an AuthProvider');
//   }
//   return context;
// } 


import React, { createContext, useContext, useState, useCallback, useEffect } from 'react';
import { authService, type LoginResponse, type User } from '../api/services/authService';
import apiClient from '../api/apiClient';

interface AuthContextType {
  user: User | null;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  isAuthenticated: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Fetch user data when component mounts
  useEffect(() => {
    const fetchUserData = async () => {
      const token = localStorage.getItem('authToken');
      if (token) {
        try {
          const response = await apiClient.get('/account/profile');
          setUser(response.data);
        } catch (error) {
          console.error('Error fetching user data:', error);
          // Clean up on error
          localStorage.removeItem('authToken');
          localStorage.removeItem('user');
          setUser(null);
        }
      }
      setIsLoading(false);
    };

    fetchUserData();
  }, []);

  const login = useCallback(async (email: string, password: string) => {
    try {
      const response = await authService.login({ email, password });
      if (!response || !response.user) {
        throw new Error('Invalid login response');
      }
      setUser(response.user);
      localStorage.setItem('authToken', response.token);
      localStorage.setItem('user', JSON.stringify(response.user));
    } catch (error) {
      console.error('Login error:', error);
      localStorage.removeItem('user');
      localStorage.removeItem('authToken');
      setUser(null);
      throw error;
    }
  }, []);

  const logout = useCallback(() => {
    setUser(null);
    localStorage.removeItem('user');
    localStorage.removeItem('authToken');
  }, []);

  const value = {
    user,
    login,
    logout,
    isAuthenticated: !!user,
  };

  if (isLoading) {
    return null; // or a loading spinner
  }

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
} 