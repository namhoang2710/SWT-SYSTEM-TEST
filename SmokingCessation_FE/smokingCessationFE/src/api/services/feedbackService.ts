// src/api/services/feedbackService.ts - Version với Mock fallback
import apiClient from '../apiClient';

// ===== TYPES =====
export interface FeedbackCommentRequest {
  information: string;
  rating?: number;
}

export interface FeedbackCoachRequest {
  information: string;
  rating?: number;
}

export interface FeedbackBlogRequest {
  information: string;
  rating?: number;
}

export interface FeedbackResponse {
  feedbackId: number;
  content: string;
  rating?: number;
  createdDate: string;
  createdTime: string;
  account: {
    id: number;
    name: string;
    email: string;
    image?: string;
  };
  commentId?: number;
  coachId?: number;
  blogId?: number;
}

// ===== MOCK DATA STORAGE =====
let mockFeedbacks: FeedbackResponse[] = [
  {
    feedbackId: 1,
    content: "Coach rất tận tâm và chuyên nghiệp. Đã giúp tôi rất nhiều trong việc cai thuốc lá.",
    rating: 5,
    createdDate: "2024-12-20",
    createdTime: "10:30:00",
    coachId: 4,
    account: {
      id: 1,
      name: "Nguyễn Văn A",
      email: "nguyenvana@example.com",
      image: "/images/default-avatar.png"
    }
  },
  {
    feedbackId: 2,
    content: "Phương pháp tư vấn rất hiệu quả. Cảm ơn coach!",
    rating: 4,
    createdDate: "2024-12-19",
    createdTime: "14:15:00",
    coachId: 4,
    account: {
      id: 2,
      name: "Trần Thị B",
      email: "tranthib@example.com",
      image: "/images/default-avatar.png"
    }
  }
];

// ===== HELPER FUNCTIONS =====
const getAuthHeaders = () => {
  const token = localStorage.getItem('token');
  return token ? { Authorization: `Bearer ${token}` } : {};
};

const getCurrentUser = () => {
  // Get current user from localStorage or context
  const userStr = localStorage.getItem('user');
  if (userStr) {
    try {
      return JSON.parse(userStr);
    } catch (e) {
      return null;
    }
  }
  return null;
};

const generateMockFeedback = (data: any, targetId: number, type: 'coach' | 'blog' | 'comment'): FeedbackResponse => {
  const user = getCurrentUser();
  const now = new Date();
  
  return {
    feedbackId: Date.now() + Math.random(), // Simple ID generation
    content: data.information, // đổi sang information
    rating: data.rating,
    createdDate: now.toISOString().split('T')[0],
    createdTime: now.toTimeString().split(' ')[0],
    account: {
      id: user?.id || 1,
      name: user?.name || 'Người dùng ẩn danh',
      email: user?.email || 'anonymous@example.com',
      image: user?.image || '/images/default-avatar.png'
    },
    ...(type === 'coach' && { coachId: targetId }),
    ...(type === 'blog' && { blogId: targetId }),
    ...(type === 'comment' && { commentId: targetId })
  };
};

// ===== COACH FEEDBACK APIs =====
export const createCoachFeedback = async (
  coachId: number, 
  data: FeedbackCoachRequest
): Promise<FeedbackResponse> => {
  try {
    console.log(`🔄 Attempting to create coach feedback for coachId: ${coachId}`, data);
    
    const response = await apiClient.post(
      `/feedbacks-coach/create/${coachId}`, 
      data,
      { 
        headers: {
          'Content-Type': 'application/json',
          ...getAuthHeaders()
        }
      }
    );
    
    console.log('✅ Coach feedback created via API:', response.data);
    return response.data;
    
  } catch (error: any) {
    console.warn('⚠️ API call failed, using mock data:', error.response?.status);
    
    // Use mock data when API is not available
    const mockFeedback = generateMockFeedback(data, coachId, 'coach');
    mockFeedbacks.push(mockFeedback);
    
    console.log('✅ Mock coach feedback created:', mockFeedback);
    
    // Simulate API delay
    await new Promise(resolve => setTimeout(resolve, 500));
    
    return mockFeedback;
  }
};

export const getCoachFeedbacks = async (coachId: number): Promise<FeedbackResponse[]> => {
  try {
    console.log(`🔄 Attempting to load feedbacks for coachId: ${coachId}`);
    
    const response = await apiClient.get(
      `/feedbacks-coach/view/${coachId}`,
      { headers: getAuthHeaders() }
    );
    
    console.log(`✅ Loaded ${response.data.length} feedbacks via API for coach ${coachId}`);
    return response.data;
    
  } catch (error: any) {
    console.warn(`⚠️ API call failed, using mock data for coach ${coachId}:`, error.response?.status);
    
    // Return mock data filtered by coachId
    const coachFeedbacks = mockFeedbacks.filter(f => f.coachId === coachId);
    
    console.log(`✅ Returning ${coachFeedbacks.length} mock feedbacks for coach ${coachId}`);
    
    // Simulate API delay
    await new Promise(resolve => setTimeout(resolve, 300));
    
    return coachFeedbacks;
  }
};

export const deleteCoachFeedback = async (feedbackId: number): Promise<void> => {
  try {
    await apiClient.delete(
      `/feedbacks-coach/delete/${feedbackId}`,
      { headers: getAuthHeaders() }
    );
    console.log(`✅ Deleted coach feedback ${feedbackId} via API`);
  } catch (error: any) {
    console.warn(`⚠️ API delete failed, removing from mock data:`, error.response?.status);
    
    // Remove from mock data
    mockFeedbacks = mockFeedbacks.filter(f => f.feedbackId !== feedbackId);
    console.log(`✅ Removed feedback ${feedbackId} from mock data`);
  }
};

// ===== BLOG FEEDBACK APIs =====
export const createBlogFeedback = async (
  blogId: number, 
  data: FeedbackBlogRequest
): Promise<FeedbackResponse> => {
  try {
    const response = await apiClient.post(
      `/feedbacks-blog/create/${blogId}`, 
      data,
      { headers: getAuthHeaders() }
    );
    return response.data;
  } catch (error: any) {
    console.warn('⚠️ Blog feedback API failed, using mock data:', error.response?.status);
    
    const mockFeedback = generateMockFeedback(data, blogId, 'blog');
    mockFeedbacks.push(mockFeedback);
    
    await new Promise(resolve => setTimeout(resolve, 500));
    return mockFeedback;
  }
};

export const getAllBlogFeedbacks = async (): Promise<FeedbackResponse[]> => {
  try {
    const response = await apiClient.get(
      '/feedbacks-blog/admin/all',
      { headers: getAuthHeaders() }
    );
    return response.data;
  } catch (error: any) {
    console.warn('⚠️ Blog feedbacks API failed, using mock data:', error.response?.status);
    
    const blogFeedbacks = mockFeedbacks.filter(f => f.blogId);
    await new Promise(resolve => setTimeout(resolve, 300));
    return blogFeedbacks;
  }
};

export const deleteBlogFeedback = async (feedbackId: number): Promise<void> => {
  try {
    await apiClient.delete(
      `/feedbacks-blog/delete/${feedbackId}`,
      { headers: getAuthHeaders() }
    );
  } catch (error: any) {
    console.warn('⚠️ Blog feedback delete API failed, using mock data:', error.response?.status);
    mockFeedbacks = mockFeedbacks.filter(f => f.feedbackId !== feedbackId);
  }
};

// ===== COMMENT FEEDBACK APIs =====
export const createCommentFeedback = async (
  commentId: number,
  data: { information: string }
): Promise<FeedbackResponse> => {
  try {
    const response = await apiClient.post(
      `/feedbacks-comment/create/${commentId}`,
      data,
      { headers: getAuthHeaders() }
    );
    return response.data;
  } catch (error: any) {
    // fallback mock
    return {} as FeedbackResponse;
  }
};

export const getAllCommentFeedbacks = async (): Promise<FeedbackResponse[]> => {
  try {
    const response = await apiClient.get(
      '/feedbacks-comment/admin/all',
      { headers: getAuthHeaders() }
    );
    return response.data;
  } catch (error: any) {
    console.warn('⚠️ Comment feedbacks API failed, using mock data:', error.response?.status);
    
    const commentFeedbacks = mockFeedbacks.filter(f => f.commentId);
    await new Promise(resolve => setTimeout(resolve, 300));
    return commentFeedbacks;
  }
};

export const deleteCommentFeedback = async (feedbackId: number): Promise<void> => {
  try {
    await apiClient.delete(
      `/feedbacks-comment/delete/${feedbackId}`,
      { headers: getAuthHeaders() }
    );
  } catch (error: any) {
    console.warn('⚠️ Comment feedback delete API failed, using mock data:', error.response?.status);
    mockFeedbacks = mockFeedbacks.filter(f => f.feedbackId !== feedbackId);
  }
};

export const getAllAdminCommentFeedbacks = async (): Promise<FeedbackResponse[]> => {
  const response = await apiClient.get('/feedbacks-comment/admin/all');
  return response.data;
};

export const getFeedbackCommentCountByDate = async (day: number, month: number, year: number) => {
  const token = localStorage.getItem('authToken') || localStorage.getItem('token');
  const response = await apiClient.get('/feedbacks-comment/count/by-date', {
    params: { day, month, year },
    headers: token ? { Authorization: `Bearer ${token}` } : {}
  });
  return response.data;
};

export const getFeedbackCoachCountByDate = async (day: number, month: number, year: number) => {
  const token = localStorage.getItem('authToken') || localStorage.getItem('token');
  const response = await apiClient.get('/feedbacks-coach/coach/count/by-date', {
    params: { day, month, year },
    headers: token ? { Authorization: `Bearer ${token}` } : {}
  });
  return response.data;
};

export const getFeedbackBlogCountByDate = async (day: number, month: number, year: number) => {
  const token = localStorage.getItem('authToken') || localStorage.getItem('token');
  const response = await apiClient.get('/feedbacks-blog/blog/count/by-date', {
    params: { day, month, year },
    headers: token ? { Authorization: `Bearer ${token}` } : {}
  });
  return response.data;
};