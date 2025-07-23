import React, { useState, useEffect, useRef } from 'react';
import { Box, Container, TextField, Button, Typography, Paper, IconButton, CircularProgress } from '@mui/material';
import { useNavigate, useParams } from 'react-router-dom';
import CloudUploadIcon from '@mui/icons-material/CloudUpload';
import DeleteIcon from '@mui/icons-material/Delete';
import { updateBlog, type BlogPost, getMyBlogs } from '../api/services/blogService';
import { toast } from 'react-toastify';

const EditBlogPage: React.FC = () => {
  const navigate = useNavigate();
  const fileInputRef = useRef<HTMLInputElement>(null);
  const { blogId } = useParams();

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [blog, setBlog] = useState<BlogPost | null>(null);
  const [postData, setPostData] = useState({ title: '', content: '' });
  const [selectedImageFile, setSelectedImageFile] = useState<File | null>(null);
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

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

      setSelectedImageFile(file);
      setPreviewUrl(URL.createObjectURL(file));
      toast.success('Ảnh đã chọn để tải lên!');
    }
  };

  const handleRemoveImage = () => {
    setSelectedImageFile(null);
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

    if (!blog) return;

    try {
      setSubmitting(true);
      await updateBlog(Number(blogId), {
        title: postData.title,
        content: postData.content,
        accountID: blog.account.id,
        image: selectedImageFile,
      });
      toast.success('Cập nhật bài viết thành công!');
      navigate(`/blogs/${blog.blogID}`);
    } catch (error: any) {
      console.error('Error updating post:', error);
      toast.error(error.response?.data?.message || 'Không thể cập nhật bài viết. Vui lòng thử lại.');
    } finally {
      setSubmitting(false);
    }
  };

  useEffect(() => {
    if (!blogId) {
      setError('Không tìm thấy ID bài viết.');
      setLoading(false);
      return;
    }
    const fetchMyBlog = async () => {
      setLoading(true);
      try {
        const myBlogs = await getMyBlogs();
        const found = myBlogs.find(b => b.blogID === Number(blogId));
        if (found) {
          setBlog(found);
          setPostData({
            title: found.title,
            content: found.content,
          });
          setPreviewUrl(found.image || null);
        } else {
          setError('Không tìm thấy bài viết của bạn');
        }
      } catch (err) {
        setError('Không thể tải bài viết');
      } finally {
        setLoading(false);
      }
    };
    fetchMyBlog();
  }, [blogId]);

  if (loading) {
    return (
      <div className="flex justify-center items-center min-h-[60vh]">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500"></div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex justify-center items-center min-h-[60vh]">
        <div className="text-red-500">{error}</div>
      </div>
    );
  }

  if (!blog) {
    return (
      <div className="flex justify-center items-center min-h-[60vh]">
        <div className="text-gray-500">Không tìm thấy bài viết.</div>
      </div>
    );
  }

  return (
    <Container maxWidth="md" sx={{ py: 4 }}>
      <Paper elevation={3} sx={{ p: 4 }}>
        <Typography variant="h4" component="h1" gutterBottom>
          Chỉnh sửa bài viết
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
                startIcon={submitting ? <CircularProgress size={20} /> : <CloudUploadIcon />}
                onClick={() => fileInputRef.current?.click()}
                disabled={submitting}
              >
                Chọn ảnh
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
                    backgroundColor: 'rgba(255, 255, 255, 0.8)',
                    '&:hover': { backgroundColor: 'rgba(255, 255, 255, 1)' }
                  }}
                >
                  <DeleteIcon color="error" />
                </IconButton>
              </Box>
            )}
          </Box>

          <Button
            type="submit"
            variant="contained"
            sx={{
              mt: 3,
              backgroundColor: '#0073b1',
              '&:hover': { backgroundColor: '#005f94' },
              px: 4,
              py: 1.5
            }}
            disabled={submitting}
          >
            {submitting ? <CircularProgress size={24} color="inherit" /> : 'Cập nhật bài viết'}
          </Button>
        </Box>
      </Paper>
    </Container>
  );
};

export default EditBlogPage;