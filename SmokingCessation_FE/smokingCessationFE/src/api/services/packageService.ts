import apiClient from '../apiClient';
import endpoints from '../endpoints';

export interface InformationPackageDTO {
  id: number;
  name: string;
  description: string;
  price: number;
  features: string[];
  duration: number; // in days
  createdAt: string;
  updatedAt: string;
}

export interface UserPackageDTO {
  id: number;
  userId: number;
  infoPackageId: number;
  startDate: string;
  endDate: string;
  status: 'active' | 'cancelled' | 'expired';
  createdAt: string;
  updatedAt: string;
}

export const getAllPackages = async (): Promise<InformationPackageDTO[]> => {
  try {
    const response = await apiClient.get<InformationPackageDTO[]>(endpoints.getAllPackages);
    // Ensure we always return an array
    return Array.isArray(response.data) ? response.data : [];
  } catch (error) {
    console.error('Error fetching packages:', error);
    // Return empty array on error to prevent .map errors
    return [];
  }
};

export const getPackageById = async (packageId: number): Promise<InformationPackageDTO> => {
  const response = await apiClient.get<InformationPackageDTO>(`${endpoints.getAllPackages}/${packageId}`);
  return response.data;
};

export const purchasePackage = async (packageId: number): Promise<UserPackageDTO> => {
  const response = await apiClient.post<UserPackageDTO>(`${endpoints.getAllPackages}/purchase/${packageId}`);
  return response.data;
};

export const cancelPackage = async (packageId: number): Promise<void> => {
  await apiClient.post(`${endpoints.getAllPackages}/cancel/${packageId}`);
};

export const getUserPackages = async (accountId: number): Promise<UserPackageDTO[]> => {
  try {
    const response = await apiClient.get(`/packages/list`, { params: { accountId } });
    // Đảm bảo trả về mảng purchasedPackages hoặc []
    return Array.isArray(response.data.purchasedPackages) ? response.data.purchasedPackages : [];
  } catch (error) {
    console.error('Error fetching user packages:', error);
    return [];
  }
};

export const getActiveUserPackages = async (): Promise<UserPackageDTO[]> => {
  try {
    const response = await apiClient.get<UserPackageDTO[]>(`${endpoints.getAllPackages}/active`);
    // Ensure we always return an array
    return Array.isArray(response.data) ? response.data : [];
  } catch (error) {
    console.error('Error fetching active user packages:', error);
    // Return empty array on error to prevent .map errors
    return [];
  }
};

// Lấy lịch sử log hút thuốc của người dùng
export const getUserSmokingLogs = async () => {
  const response = await apiClient.get('/packages/smoking-logs/list');
  return response.data;
};

// Cập nhật log hút thuốc
export const updateSmokingLog = async (logId: number, logData: any) => {
  const response = await apiClient.put(`/packages/smoking-log/${logId}`, logData);
  return response.data;
};

// Cập nhật package (admin, multipart/form-data)
export const updatePackageAdmin = async (id: number, data: {
  name: string;
  price: number;
  duration: number;
  description: string;
  numberOfConsultations: number;
  numberOfHealthCheckups: number;
}) => {
  const formData = new FormData();
  formData.append('name', data.name);
  formData.append('price', String(data.price));
  formData.append('duration', String(data.duration));
  formData.append('description', data.description);
  formData.append('numberOfConsultations', String(data.numberOfConsultations));
  formData.append('numberOfHealthCheckups', String(data.numberOfHealthCheckups));
  const response = await apiClient.put(`/admin/packages/${id}`, formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  });
  return response.data;
}; 