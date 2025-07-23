import apiClient from '../apiClient';
import endpoints from '../endpoints';

export interface UserRanking {
  id: number;
  name: string;
  image: string;
  points: number;
  rank: number;
}

export interface UserProfile {
  id: number;
  name: string;
  email: string;
  image: string;
  points: number;
  joinDate: string;
  bio?: string;
  phone?: string;
  address?: string;
}


export const getUserProfile = async (userId: number): Promise<UserProfile> => {
  const response = await apiClient.get<UserProfile>(`${endpoints.listMembers}/${userId}`);
  return response.data;
};

export const updateUserProfile = async (userId: number, data: Partial<UserProfile>): Promise<UserProfile> => {
  const response = await apiClient.put<UserProfile>(`${endpoints.listMembers}/${userId}`, data);
  return response.data;
};

export const getCoachSchedule = async (coachId: number) => {
  const response = await apiClient.get(endpoints.getCoachSchedule, { params: { coachId } });
  return response.data;
};

// Cập nhật động lực cai thuốc (motivation)
export const updateMotivation = async (data: { accountId: number, startDate: string, endDate?: string, motivation: string }) => {
  const response = await apiClient.put('/member/profile/update', data);
  return response.data;
};

export const getMemberProfileForCoach = async (userId: number) => {
  const token = localStorage.getItem('authToken') || localStorage.getItem('token');
  console.log('Token gửi lên:', token);
  const response = await apiClient.get(`/coach/user/${userId}/profile`, {
    headers: token ? { Authorization: `Bearer ${token}` } : {}
  });
  return response.data.memberProfile;
};

export const getAllCoachesForAdmin = async () => {
  const response = await apiClient.get('/admin/coaches/all');
  return response.data;
};

// Xóa coach (admin)
export async function deleteCoachByAdmin(accountId: number) {
  const response = await apiClient.delete(`/admin/coaches/${accountId}`);
  return response.data;
}

// Tạo coach (admin)
export async function createCoachByAdmin(data: { name: string; email: string; gender: string; yearbirth: number }) {
  const response = await apiClient.post('/admin/coaches/create', data);
  return response.data;
}

export const getAllMemberProfiles = async (page = 0, size = 10) => {
  const token = localStorage.getItem('authToken') || localStorage.getItem('token');
  const response = await apiClient.get('/member/profile/all', {
    params: { page, size },
    headers: token ? { Authorization: `Bearer ${token}` } : {}
  });
  return response.data;
};

// Thêm hàm banAccount
export const banAccount = async (accountId: number): Promise<void> => {
  await apiClient.delete(`/account/Ban/${accountId}`);
};

// Thêm hàm unbanAccount
export const unbanAccount = async (accountId: number): Promise<void> => {
  await apiClient.delete(`/account/Unban/${accountId}`);
};

// Lấy số lượng thành viên đăng ký hôm nay (admin)
export const getTodayRegisteredMembersCount = async () => {
  const token = localStorage.getItem('authToken') || localStorage.getItem('token');
  const response = await apiClient.get('/member/profile/admin/today', {
    headers: token ? { Authorization: `Bearer ${token}` } : {}
  });
  return response.data;
};

// Lấy danh sách thành viên đăng ký theo ngày (admin)
export const getMembersByDate = async (day: number, month: number, year: number) => {
  const token = localStorage.getItem('authToken') || localStorage.getItem('token');
  const response = await apiClient.get('/member/profile/members/by-date', {
    params: { day, month, year },
    headers: token ? { Authorization: `Bearer ${token}` } : {}
  });
  return response.data;
};
