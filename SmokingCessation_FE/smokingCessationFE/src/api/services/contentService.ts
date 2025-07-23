import apiClient from '../apiClient';
import endpoints from '../endpoints';

// ✅ KHỚP VỚI CommentResponseDTO từ backend
export interface Comment {
  content: string;
  commenterName: string;
  commenterImage: string;
  createdDate: string;  // LocalDate from backend
  createdTime: string;  // LocalTime from backend
}

// ✅ INTERFACE CHO CREATE COMMENT RESPONSE (khác với Comment)
export interface CommentCreateResponse {
  commentID: number;
  content: string;
  createdDate: string;
  createdTime: string;
  account: {
    id: number;
    email: string;
    name: string | null;
    image: string | null;
  };
  blog: {
    blogID: number;
  };
}

// ✅ SỬA: Hàm getCommentsByBlogId với debug chi tiết
export const getCommentsByBlogId = async (blogId: number): Promise<Comment[]> => {
  try {
    console.log(`🔄 Loading comments for blog ${blogId} using backend endpoint...`);
    console.log(`🌐 Calling: GET /api/comments/${blogId}`);
    
    // ✅ GỌI ENDPOINT CHÍNH XÁC như trong Swagger
    const response = await apiClient.get<Comment[]>(`/comments/${blogId}`);
    console.log(`✅ Raw response for blog ${blogId}:`, response.data);
    console.log(`📊 Response status:`, response.status);
    console.log(`📋 Response headers:`, response.headers);
    
    // ✅ Backend đã trả về CommentResponseDTO, không cần map thêm
    return response.data;
    
  } catch (error: any) {
    console.error(`❌ Error loading comments for blog ${blogId}:`, error);
    console.error('📊 Error status:', error.response?.status);
    console.error('📊 Error data:', error.response?.data);
    console.error('📊 Error headers:', error.response?.headers);
    console.error('📊 Full error object:', error);
    
    // ✅ DETAILED ERROR LOGGING
    if (error.code === 'ECONNREFUSED') {
      console.error('🔌 Connection refused - Backend server might be down');
    } else if (error.code === 'ENOTFOUND') {
      console.error('🌐 DNS resolution failed - Check API URL');
    } else if (error.response) {
      console.error('📡 Server responded with error:', {
        status: error.response.status,
        statusText: error.response.statusText,
        url: error.config?.url,
        method: error.config?.method
      });
    }
    
    return [];
  }
};
