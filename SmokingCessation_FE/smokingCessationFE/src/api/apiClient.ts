// src/api/apiClient.ts
import axios, { type AxiosInstance } from 'axios';
import { authService } from './services/authService';
import { toast } from 'react-toastify';



const BASE_URL = "https://smoking-cessation.onrender.com/api";
//  const BASE_URL = "http://localhost:8080/api";


console.log('API Base URL:', BASE_URL); 

localStorage.removeItem('token');

const apiClient: AxiosInstance = axios.create({
  baseURL: BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  
  timeout: 10000,
});


apiClient.interceptors.request.use(
  (config) => {
    console.log('Making request to:', config.url);
    
    const token = localStorage.getItem('authToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }

    
    if (config.data instanceof FormData) {
      delete config.headers['Content-Type'];
    } else {

      config.headers['Content-Type'] = 'application/json';
    }

    console.log('Request headers:', config.headers);
    return config;
  },
  (error) => {
    console.error('Request error:', error);
    return Promise.reject(error);
  }
);


apiClient.interceptors.response.use(
  (response) => {
    console.log('Response received:', response.status, response.config.url);
    if (response.data && response.data.message) {
      const responseStr = response.data.message.toLowerCase();
      if (responseStr.includes('đã được đặt') || responseStr.includes('slot đã được đặt')) {
        toast.error(`❌ ${response.data.message}`);
        return response;
      }
      if (
        response.config.url?.includes('/booking') &&
        (responseStr.includes('thành công') || response.status === 200)
      ) {
        toast.success('✅ Đặt lịch thành công!');
        return response;
      }
    }
    return response;
  },
  (error) => {
    console.error('Response error:', error.response?.status, error.config?.url);
    if (error.response?.status === 401) {
      const { pathname } = window.location;
      if (pathname !== '/login' && pathname !== '/register') {
        authService.logout();
        window.location.href = '/login';
      }
    }
    return Promise.reject(error);
  }
);

export default apiClient;
