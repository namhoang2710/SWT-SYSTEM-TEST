import apiClient from '../apiClient';
import endpoints from '../endpoints';

export interface Comment {
  commentId: number;
  accountId?: number;
  content: string;
  createdDate: string;
  createdTime: string;
  commenterName?: string;
  commenterImage?: string;
  account?: {
    id: number;
    email: string;
    name: string | null;
    image: string | null;
    role?: string;
    status?: string;
  };
  blog?: {
    blogID: number;
    // ...other fields
  };
}

// ✅ SỬA: Gọi endpoint cũ trong backend - KHÔNG CẦN authentication để xem
export const getCommentsByBlogId = async (blogId: number): Promise<Comment[]> => {
  try {
    console.log(`🔄 Loading comments for blog ${blogId} using old backend endpoint...`);
    
    // ✅ GỌI ENDPOINT CŨ: /api/comments/{blogId} (PUBLIC - không cần auth)
    const response = await apiClient.get<Comment[]>(`/comments/${blogId}`);
    console.log(`✅ Found ${response.data.length} comments for blog ${blogId}`);
    return response.data;
    
  } catch (error: any) {
    console.error(`❌ Error loading comments for blog ${blogId}:`, error);
    
    // ✅ Error handling
    if (error.response?.status === 404) {
      console.log(`📭 Blog ${blogId} not found or no comments`);
    } else if (error.response?.status === 500) {
      console.log(`🔥 Server error loading comments for blog ${blogId}`);
    } else if (error.response?.status === 403) {
      console.log(`🔒 Access denied for blog ${blogId} comments`);
    }
    
    return [];
  }
};

export const updateComment = async (commentId: number, data: { content: string }) => {
  // Gọi API đúng chuẩn: content là query param
  const response = await apiClient.put(`/comments/update/${commentId}`, null, {
    params: { content: data.content }
  });
  return response.data;
};

export const deleteComment = async (commentId: number) => {
  const response = await apiClient.delete(`/comments/delete/${commentId}`);
  return response.data;
};

export const getTodayCommentCount = async () => {
  const token = localStorage.getItem('authToken') || localStorage.getItem('token');
  const response = await apiClient.get('/comment/count/today', {
    headers: token ? { Authorization: `Bearer ${token}` } : {}
  });
  return response.data;
};

export const getCommentCountByDate = async (day: number, month: number, year: number) => {
  const token = localStorage.getItem('authToken') || localStorage.getItem('token');
  const response = await apiClient.get('/comment/count/by-date', {
    params: { day, month, year },
    headers: token ? { Authorization: `Bearer ${token}` } : {}
  });
  return response.data;
};
