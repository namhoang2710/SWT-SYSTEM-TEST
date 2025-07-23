import apiClient from '../apiClient';
import endpoints from '../endpoints';

export const getAllMedals = async () => {
  const response = await apiClient.get(`/${endpoints.getAllMedals}`);
  return response.data;
};

export const createMedal = async (data: any) => {
  const response = await apiClient.post(`/${endpoints.createMedal}`, data);
  return response.data;
};

export const deleteMedal = async (id: number | string) => {
  try {
    const response = await apiClient.delete(`/medal/admin/delete/${id}`);
    console.log('Delete medal response:', response);
    return response.data;
  } catch (error) {
    console.error('Delete medal error:', error);
    throw error;
  }
};

export const updateMedal = async (id: number | string, data: any) => {
  const response = await apiClient.put(`/${endpoints.updateMedal}/${id}`, data);
  return response.data;
};

// Lấy tất cả user medal cho admin
export const getAllUserMedalsAdmin = async () => {
  const response = await apiClient.get('/admin/medal/all');
  return response.data;
};

// Coach trao huy chương cho user
export const assignMedalToUser = async (accountId: number, medalId: number, medalInfo: string) => {
  const response = await apiClient.post('/coach/medal/assign', null, {
    params: { accountId, medalId, medalInfo }
  });
  return response.data;
};

// Lấy huy chương của user do coach xem
export const getUserMedalsByCoach = async (accountId: number) => {
  const response = await apiClient.get(`/coach/medal/user/${accountId}`);
  return response.data;
};

// Coach huỷ huy chương của user
export const deleteUserMedalByCoach = async (userMedalId: number) => {
  const response = await apiClient.delete(`/coach/medal/delete/${userMedalId}`);
  return response.data;
}; 