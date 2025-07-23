// 

// src/api/services/authService.ts
import { callApi } from '../apiHelper';
import endpoints from '../endpoints';

export interface LoginRequest {
  email: string;
  password: string;
}

export interface User {
  id: number;
  email: string;
  name: string;
  yearbirth?: number;
  dob?: string;
  age: number;
  gender: string;
  role: string;
  status: string;
  image: string;
  consultations: number;
  healthCheckups: number;
}

export interface RegisterRequest {
  email: string;
  password: string;
  name: string;
  yearbirth: number; // Đổi từ age sang yearbirth
  gender: string;
  image?: string;
}

export interface LoginResponse {
  token: string;
}

export interface ErrorResponse {
  error: string;
  message: string;
}

export const authService = {
  async login(credentials: LoginRequest): Promise<{ token: string; user: User }> {
    console.log('AuthService: Attempting login with credentials:', { email: credentials.email });
    
    try {
      // First, get the token from login
      const loginResponse = await callApi<LoginResponse>(
        'login', 
        'post',
        {
          body: {
            email: credentials.email,
            password: credentials.password
          },
          headers: {
            'Content-Type': 'application/json'
          }
        }
      );
      
      console.log('AuthService: Login response:', loginResponse);
      
      // Validate the token response
      if (!loginResponse || !loginResponse.token) {
        console.error('AuthService: Invalid login response:', loginResponse);
        throw new Error('No authentication token received');
      }

      // Store the token
      localStorage.setItem('authToken', loginResponse.token);
      console.log('AuthService: Token stored successfully');

      try {
        // Fetch user profile using the token
        const userProfile = await callApi<User>('profile', 'get');
        console.log('AuthService: User profile fetched:', userProfile);

        if (!userProfile) {
          console.error('AuthService: Failed to fetch user profile');
          throw new Error('Failed to fetch user profile');
        }

        // Check if account is active (allow both 'Active' and 'ACTIVE')
        if (userProfile.status !== 'Active' && userProfile.status !== 'ACTIVE') {
          localStorage.removeItem('authToken');
          throw new Error('Tài khoản của bạn chưa được xác thực. Vui lòng kiểm tra email để xác thực tài khoản.');
        }

        return {
          token: loginResponse.token,
          user: userProfile
        };
      } catch (profileError: any) {
        // If profile fetch fails, clean up the token
        localStorage.removeItem('authToken');
        throw profileError;
      }
    } catch (error: any) {
      console.error('AuthService: Login error:', error);
      
      // Clean up on error
      localStorage.removeItem('authToken');
      
      // Handle specific error cases
      if (error.response) {
        if (error.response.status === 401) {
          throw new Error('Invalid email or password');
        }
        if (error.response.data?.message) {
          throw new Error(error.response.data.message);
        }
      }
      
      throw error;
    }
  },

  async register(userData: RegisterRequest): Promise<void> {
    await callApi<void>(
      'register',
      'post',
      { body: userData }
    );
  },

  logout(): void {
    localStorage.removeItem('authToken');
  },

  getToken(): string | null {
    return localStorage.getItem('authToken');
  },

  isAuthenticated(): boolean {
    return !!this.getToken();
  },

  async fetchCoachProfile(): Promise<any> {
    return await callApi<any>('getMyCoachProfile', 'get');
  },

  async updateCoachProfile(formData: FormData): Promise<any> {
    return await callApi<any>('updateCoachProfile', 'put', {
      body: formData,
      headers: { 'Content-Type': 'multipart/form-data' }
    });
  },

  async verifyAccount(code: string): Promise<string> {
    const response = await callApi<{ message: string }>(
      'verify',
      'get',
      { queryParams: { code } }
    );
    return response.message;
  },

  async forgotPassword(email: string): Promise<void> {
    await callApi<void>('forgotPassword', 'post', {
      body: { email },
      headers: { 'Content-Type': 'application/json' }
    });
  },

  async resetPassword(token: string, newPassword: string): Promise<void> {
    await callApi<void>('resetPassword', 'post', {
      body: { token, newPassword },
      headers: { 'Content-Type': 'application/json' }
    });
  }
};