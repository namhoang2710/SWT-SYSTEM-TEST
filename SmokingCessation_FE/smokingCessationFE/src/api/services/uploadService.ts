import apiClient from '../apiClient';

export async function uploadImage(file: File, onUploadProgress?: (progressEvent: any) => void): Promise<string> {
  try {
    // Kiểm tra file trước khi upload
    if (!file) {
      throw new Error('Không có file được chọn');
    }

    if (!file.type.startsWith('image/')) {
      throw new Error('Chỉ cho phép upload file ảnh');
    }

    if (file.size > 1 * 1024 * 1024) { // 1MB
      throw new Error('Kích thước file phải nhỏ hơn 1MB');
    }

    const formData = new FormData();
    formData.append('file', file);

    console.log('🔄 Uploading file:', file.name, 'Size:', file.size, 'Type:', file.type);

    // ✅ Sửa endpoint để match với AccountController
    const response = await apiClient.post<{ url: string; message?: string }>('/account/upload', formData, {
      headers: {
        // Không set Content-Type để browser tự động set với boundary cho FormData
      },
      onUploadProgress: (progressEvent) => {
        const progress = progressEvent.total 
          ? Math.round((progressEvent.loaded * 100) / progressEvent.total) 
          : 0;
        
        console.log('📤 Upload progress:', progress + '%');
        
        if (onUploadProgress) {
          onUploadProgress(progressEvent);
        }
      },
      timeout: 30000, // 30 seconds timeout
    });

    console.log('✅ Upload successful:', response.data);

    if (!response.data.url) {
      throw new Error('Không nhận được URL ảnh từ server');
    }

    return response.data.url;

  } catch (error: any) {
    console.error('❌ Upload failed:', error);
    
    if (error.response) {
      // Server trả về lỗi
      const status = error.response.status;
      const message = error.response.data?.message || error.response.data || 'Lỗi upload';
      
      if (status === 401) {
        throw new Error('Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.');
      } else if (status === 403) {
        throw new Error('Không có quyền upload file. Vui lòng kiểm tra lại.');
      } else if (status === 413) {
        throw new Error('File quá lớn. Vui lòng chọn file nhỏ hơn.');
      } else {
        throw new Error(`Lỗi upload: ${message}`);
      }
    } else if (error.code === 'ECONNABORTED') {
      throw new Error('Upload timeout. Vui lòng thử lại.');
    } else if (error.message) {
      throw new Error(error.message);
    } else {
      throw new Error('Lỗi upload không xác định');
    }
  }
}