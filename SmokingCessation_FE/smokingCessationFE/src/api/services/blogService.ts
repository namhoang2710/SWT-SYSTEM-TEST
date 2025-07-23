import apiClient from '../apiClient';
import endpoints from '../endpoints';

export interface BlogPost {
  blogID: number;
  account: {
    id: number;
    email: string;
    name: string;
    age: number;
    gender: string;
    role: string;
    status: string;
    image: string | null;
    consultations: number;
    healthCheckups: number;
  };
  title: string;
  content: string;
  createdDate: string;
  createdTime: string;
  image?: string;
  commentCount?: number;
  likes?: number;
  liked?: boolean; // Thêm trường này để phản ánh trạng thái đã like
}

export interface BlogComment {
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

// ✅ SIMPLE DTO CHO CREATE COMMENT - KHỚP VỚI BACKEND CŨ
export interface SimpleCommentPayload {
  content: string;
}

export const getTopBlogs = async (): Promise<BlogPost[]> => {
  const response = await apiClient.get<BlogPost[]>(endpoints.getAllBlogs);
  const sortedBlogs = response.data.sort((a, b) => {
    const dateA = new Date(`${a.createdDate}T${a.createdTime}`);
    const dateB = new Date(`${b.createdDate}T${b.createdTime}`);
    return dateB.getTime() - dateA.getTime();
  });
  return sortedBlogs.slice(0, 5);
};

export const getAllBlogs = async (): Promise<BlogPost[]> => {
  const response = await apiClient.get<BlogPost[]>(endpoints.getAllBlogs);
  return response.data;
};

export const getMyBlogs = async (): Promise<BlogPost[]> => {
  const response = await apiClient.get<BlogPost[]>(endpoints.getMyBlogs);
  return response.data;
};

export const getBlogById = async (blogId: number): Promise<BlogPost> => {
  const response = await apiClient.get<BlogPost>(`/blogs/${blogId}`);
  return response.data;
};

// ✅ SỬA: Gọi endpoint cũ trong backend cho create comment
export const createBlogComment = async (blogId: number, content: string): Promise<BlogComment> => {
  try {
    console.log(`🔄 Creating comment for blog ${blogId}...`);
    // Gửi content qua query string thay vì body
    const response = await apiClient.post<BlogComment>(
      `/comments/create/${blogId}?content=${encodeURIComponent(content.trim())}`,
      null
    );
    console.log(`✅ Comment created successfully for blog ${blogId}`);
    return response.data;
  } catch (error: any) {
    console.error(`❌ Error creating comment for blog ${blogId}:`, error);
    if (error.response) {
      console.error('Response status:', error.response.status);
      console.error('Response data:', error.response.data);
    }
    throw error;
  }
};

export const likeBlog = async (blogId: number): Promise<number> => {
  const res = await apiClient.put(`/blogs/like/${blogId}`);
  // Giả sử backend trả về { likes: number }
  return res.data?.likes ?? 0;
};

export const unlikeBlog = async (blogId: number): Promise<void> => {
  await apiClient.delete(`${endpoints.getAllBlogs}/${blogId}/like`);
};

export const likeComment = async (blogId: number, commentId: number): Promise<void> => {
  await apiClient.post(`${endpoints.getAllBlogs}/${blogId}/comments/${commentId}/like`);
};

export const unlikeComment = async (blogId: number, commentId: number): Promise<void> => {
  await apiClient.delete(`${endpoints.getAllBlogs}/${blogId}/comments/${commentId}/like`);
};

export const deleteBlog = async (blogId: number): Promise<void> => {
  await apiClient.delete(`/blogs/delete/${blogId}`);
};

export const createBlog = async (blogData: {
  title: string;
  content: string;
  accountID: number;
  image?: File | null;
}): Promise<BlogPost> => {
  const formData = new FormData();
  formData.append('title', blogData.title);
  formData.append('content', blogData.content);
  formData.append('accountID', blogData.accountID.toString());
  if (blogData.image) {
    formData.append('image', blogData.image);
  }
  const response = await apiClient.post<BlogPost>(
    '/blogs/create',
    formData,
    {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    }
  );
  return response.data;
};

export const updateBlog = async (blogId: number, blogData: { 
  title: string;
  content: string;
  accountID: number;
  image?: File | null;
}): Promise<BlogPost> => {
  const formData = new FormData();
  formData.append('title', blogData.title);
  formData.append('content', blogData.content);
  formData.append('accountID', blogData.accountID.toString());
  
  if (blogData.image) {
    formData.append('image', blogData.image);
  }

  const response = await apiClient.put<BlogPost>(`${endpoints.updateBlog}/${blogId}`, formData, {
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  });
  return response.data;
};

// Lấy tất cả blog cho admin
export const getAllBlogsForAdmin = async (): Promise<BlogPost[]> => {
  const response = await apiClient.get<BlogPost[]>('/blogs/all');
  return response.data;
};

// Lấy 1 blog bất kỳ cho admin
export const getBlogByIdForAdmin = async (blogId: number): Promise<BlogPost> => {
  const response = await apiClient.get<BlogPost>(`/blogs/${blogId}`);
  return response.data;
};

// Xóa 1 blog bất kỳ cho admin
export const deleteBlogByIdForAdmin = async (blogId: number): Promise<void> => {
  await apiClient.delete(`/blogs/delete/${blogId}`);
};

export const getTodayBlogCount = async () => {
  const token = localStorage.getItem('authToken') || localStorage.getItem('token');
  const response = await apiClient.get('/blog/count/today', {
    headers: token ? { Authorization: `Bearer ${token}` } : {}
  });
  return response.data;
};

export const getBlogCountByDate = async (day: number, month: number, year: number) => {
  const token = localStorage.getItem('authToken') || localStorage.getItem('token');
  const response = await apiClient.get('/blog/count/by-date', {
    params: { day, month, year },
    headers: token ? { Authorization: `Bearer ${token}` } : {}
  });
  return response.data;
};