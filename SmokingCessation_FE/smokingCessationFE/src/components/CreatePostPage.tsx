import React, { useState, useRef } from 'react';
import { Box, Container, TextField, Button, Typography, Paper, IconButton, CircularProgress } from '@mui/material';
import { useNavigate } from 'react-router-dom';
import CloudUploadIcon from '@mui/icons-material/CloudUpload';
import DeleteIcon from '@mui/icons-material/Delete';
import { createBlog } from '../api/services/blogService';
import { toast } from 'react-toastify';
import { useAuth } from '../contexts/AuthContext';

const CreatePostPage: React.FC = () => {
  const navigate = useNavigate();
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [postData, setPostData] = useState({
    title: '',
    content: '',
    image: null as File | null,
  });
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  const [uploading, setUploading] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const { user } = useAuth();

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setPostData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      if (!file.type.startsWith('image/')) {
        toast.error('Vui lòng chọn một tệp hình ảnh');
        return;
      }
      if (file.size > 5 * 1024 * 1024) {
        toast.error('Kích thước ảnh phải nhỏ hơn 5MB');
        return;
      }
      setPostData(prev => ({
        ...prev,
        image: file
      }));
      const reader = new FileReader();
      reader.onloadend = () => {
        setPreviewUrl(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
  };

  const handleRemoveImage = () => {
    setPostData(prev => ({
      ...prev,
      image: null
    }));
    setPreviewUrl(null);
    if (fileInputRef.current) {
      fileInputRef.current.value = '';
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!postData.title.trim() || !postData.content.trim()) {
      toast.error('Vui lòng điền đầy đủ thông tin');
      return;
    }

    try {
      setSubmitting(true);
      
      const now = new Date();
      const createdDate = now.toISOString().split('T')[0];
      const createdTime = now.toTimeString().split(' ')[0];

      await createBlog({
        title: postData.title,
        content: postData.content,
        accountID: user?.id || 0,
        image: postData.image,
      });
      toast.success('Tạo bài viết thành công!');
      navigate('/');
    } catch (error: any) {
      console.error('Error creating post:', error);
      toast.error(error.response?.data?.message || 'Không thể tạo bài viết. Vui lòng thử lại.');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <Container maxWidth="md" sx={{ py: 4 }}>
      <Paper elevation={3} sx={{ p: 4 }}>
        <Typography variant="h4" component="h1" gutterBottom>
          Tạo bài viết mới
        </Typography>
        <Box component="form" onSubmit={handleSubmit} sx={{ mt: 3 }}>
          <TextField
            fullWidth
            label="Tiêu đề"
            name="title"
            value={postData.title}
            onChange={handleChange}
            required
            margin="normal"
          />
          <TextField
            fullWidth
            label="Nội dung"
            name="content"
            value={postData.content}
            onChange={handleChange}
            required
            multiline
            rows={6}
            margin="normal"
          />
          
          {/* Image Upload Section */}
          <Box sx={{ mt: 3 }}>
            <Typography variant="subtitle1" gutterBottom>
              Hình ảnh bài viết
            </Typography>
            <input
              type="file"
              accept="image/*"
              onChange={handleImageChange}
              style={{ display: 'none' }}
              ref={fileInputRef}
            />
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
              <Button
                variant="outlined"
                startIcon={uploading ? <CircularProgress size={20} /> : <CloudUploadIcon />}
                onClick={() => fileInputRef.current?.click()}
                disabled={uploading}
              >
                {uploading ? 'Đang upload...' : 'Chọn ảnh'}
              </Button>
            </Box>
            {previewUrl && (
              <Box sx={{ mt: 2, position: 'relative', display: 'inline-block' }}>
                <img
                  src={previewUrl}
                  alt="Preview"
                  style={{
                    maxWidth: '200px',
                    maxHeight: '200px',
                    objectFit: 'cover',
                    borderRadius: '4px'
                  }}
                />
                <IconButton
                  size="small"
                  onClick={handleRemoveImage}
                  sx={{
                    position: 'absolute',
                    top: -8,
                    right: -8,
                    bgcolor: 'white',
                    '&:hover': { bgcolor: 'grey.100' }
                  }}
                >
                  <DeleteIcon />
                </IconButton>
              </Box>
            )}
            <Typography variant="caption" color="text.secondary" sx={{ display: 'block', mt: 1 }}>
              JPG, PNG hoặc GIF. Tối đa 5MB.
            </Typography>
          </Box>

          <Box sx={{ mt: 4, display: 'flex', gap: 2 }}>
            <Button
              variant="contained"
              color="primary"
              type="submit"
              size="large"
              disabled={submitting}
              startIcon={submitting ? <CircularProgress size={20} /> : null}
            >
              {submitting ? 'Đang đăng...' : 'Đăng bài'}
            </Button>
            <Button
              variant="outlined"
              color="secondary"
              onClick={() => navigate('/blogs')}
              size="large"
              disabled={submitting}
            >
              Hủy
            </Button>
          </Box>
        </Box>
      </Paper>
    </Container>
  );
};

export default CreatePostPage; 