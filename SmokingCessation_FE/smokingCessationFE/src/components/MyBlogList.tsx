import React, { useState, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { getMyBlogs, type BlogPost, deleteBlog } from '../api/services/blogService';
import { useAuth } from '../contexts/AuthContext';
import { format } from 'date-fns';
import { toast } from 'react-toastify';
import styles from './BlogList.module.css'; // Reuse existing styles
import BlogImage from './BlogImage';
import apiClient from '../api/apiClient';

// Import Material-UI components
import { Box, Container, Typography, Paper, Button, CircularProgress, Dialog, DialogTitle, DialogContent, DialogActions } from '@mui/material';
import AddIcon from '@mui/icons-material/Add'; // For the "Create new post" button

interface QuitPlan {
  planId: number;
  title: string;
  description: string;
  startDate: string;
  goalDate: string;
  targetCigarettesPerDay: number;
  status: string;
}

const MyBlogList: React.FC = () => {
  const [blogs, setBlogs] = useState<BlogPost[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const { isAuthenticated, user } = useAuth();
  const navigate = useNavigate();
  const [openDeleteDialog, setOpenDeleteDialog] = useState(false);
  const [blogIdToDelete, setBlogIdToDelete] = useState<number | null>(null);
  const [plans, setPlans] = useState<QuitPlan[]>([]);

  useEffect(() => {
    const fetchMyBlogs = async () => {
      if (!isAuthenticated || !user) {
        navigate('/login');
        toast.info('Vui lòng đăng nhập để xem bài viết của bạn', {
          onClick: () => navigate('/login'),
          closeButton: true,
          autoClose: 5000
        });
        return;
      }
      try {
        const data = await getMyBlogs();
        setBlogs(data);
        setError(null);
      } catch (err: any) {
        setError('Không thể tải bài viết của bạn. Vui lòng thử lại sau.');
        console.error('Lỗi khi lấy dữ liệu bài viết của tôi:', err);
      } finally {
        setLoading(false);
      }
    };

    fetchMyBlogs();
  }, [isAuthenticated, user, navigate]);

  useEffect(() => {
    fetchPlans();
  }, []);

  const fetchPlans = async () => {
    setLoading(true);
    try {
      const res = await apiClient.get('/plans/member/my-plans');
      setPlans(res.data);
    } catch (e) {
      setError('Không thể tải kế hoạch cai thuốc');
      setPlans([]);
    } finally {
      setLoading(false);
    }
  };

  const handleOpenDeleteDialog = (blogId: number) => {
    setBlogIdToDelete(blogId);
    setOpenDeleteDialog(true);
  };

  const handleCloseDeleteDialog = () => {
    setOpenDeleteDialog(false);
    setBlogIdToDelete(null);
  };

  const handleConfirmDelete = async () => {
    if (blogIdToDelete) {
      await handleDelete(blogIdToDelete);
      handleCloseDeleteDialog();
    }
  };

  const handleDelete = async (id: number) => {
    if (!isAuthenticated) {
      toast.info('Vui lòng đăng nhập để xóa bài viết', {
        onClick: () => navigate('/login'),
        closeButton: true,
        autoClose: 5000
      });
      return;
    }

    try {
      await deleteBlog(id);
      setBlogs(blogs.filter(blog => blog.blogID !== id));
      toast.success('Xóa bài viết thành công');
    } catch (err: any) {
      console.error(`Lỗi khi xóa bài viết ${id}:`, err);
      if (err.response?.status === 401) {
        toast.error('Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại', {
          onClick: () => navigate('/login'),
          closeButton: true,
          autoClose: 5000
        });
        return;
      }
      toast.error(err.response?.data?.message || 'Không thể xóa bài viết. Vui lòng thử lại sau.');
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center min-h-[60vh]">
        <CircularProgress />
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex justify-center items-center min-h-[60vh]">
        <Typography color="error">{error}</Typography>
      </div>
    );
  }

  return (
    <Container maxWidth="md" sx={{
      py: 4,
      mt: 4,
      backgroundColor: '#f8f0e3',
      borderRadius: '12px',
      boxShadow: '0 6px 20px rgba(0, 0, 0, 0.08)'
    }}>
      <Paper elevation={3} sx={{
        p: 4,
        backgroundColor: '#fff',
        borderRadius: '12px',
        boxShadow: '0 3px 10px rgba(0, 0, 0, 0.08)'
      }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
          <Typography variant="h4" component="h1" sx={{ fontWeight: 'bold', color: '#333' }}>
            Bài viết của tôi
          </Typography>
          {isAuthenticated && (
            <Link to="/create-post" style={{ textDecoration: 'none' }}>
              <Button
                variant="contained"
                startIcon={<AddIcon />}
                sx={{
                  backgroundColor: '#0073b1',
                  '&:hover': { backgroundColor: '#005f94' },
                  borderRadius: '25px',
                  px: 3,
                  py: 1.2
                }}
              >
                Tạo bài viết mới
              </Button>
            </Link>
          )}
        </Box>

        <Box sx={{ mt: 3 }}>
          {blogs.length > 0 ? (
            blogs.map((blog) => (
              <Paper key={blog.blogID} elevation={1} sx={{
                mb: 3,
                borderRadius: '12px',
                overflow: 'hidden',
                transition: 'all 0.3s ease-in-out',
                '&:hover': {
                  transform: 'translateY(-5px)',
                  boxShadow: '0 8px 20px rgba(0, 0, 0, 0.15)'
                },
                display: 'flex',
                cursor: 'pointer',
                backgroundColor: '#fff' // Ensure blog cards are white
              }} onClick={() => navigate(`/blogs/${blog.blogID}`)}>
                {blog.image && (
                  <Box sx={{ width: '200px', height: '150px', flexShrink: 0, overflow: 'hidden' }}>
                    <BlogImage
                      src={blog.image}
                      alt={blog.title}
                      style={{ width: '100%', height: '100%', objectFit: 'cover', borderRadius: '12px 0 0 12px' }} // Image specific styling
                    />
                  </Box>
                )}
                <Box sx={{ p: 3, flexGrow: 1, display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
                  <Typography variant="h6" component="h2" sx={{ fontWeight: 'bold', mb: 1, color: '#333' }}>
                    <Link to={`/blogs/${blog.blogID}`} style={{ textDecoration: 'none', color: 'inherit' }}>{blog.title}</Link>
                  </Typography>
                  <Typography variant="body2" color="text.secondary" sx={{ mb: 2, display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>
                    {blog.content}
                  </Typography>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <Typography variant="body2" color="text.secondary" sx={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                      <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                      </svg>
                      {blog.createdDate && blog.createdTime ?
                        format(new Date(`${blog.createdDate}T${blog.createdTime}`), 'd MMM, yyyy') :
                        'Ngày không có sẵn'
                      }
                    </Typography>
                    {isAuthenticated && user?.id === blog.account.id && (
                      <Box sx={{ display: 'flex', gap: 1 }}>
                        <Button
                          variant="outlined"
                          size="small"
                          component={Link}
                          to={`/my-blogs/edit/${blog.blogID}`}
                          state={blog}
                          onClick={(e) => e.stopPropagation()}
                          sx={{ color: '#0a66c2', borderColor: '#0a66c2', '&:hover': { backgroundColor: '#e6f0fa' } }}
                        >
                          Chỉnh sửa
                        </Button>
                        <Button
                          variant="outlined"
                          size="small"
                          color="error"
                          onClick={(e) => { e.stopPropagation(); handleOpenDeleteDialog(blog.blogID); }}
                          sx={{ '&:hover': { backgroundColor: '#fdebeb' } }}
                        >
                          Xóa
                        </Button>
                      </Box>
                    )}
                  </Box>
                </Box>
              </Paper>
            ))
          ) : (
            <Typography variant="body1" color="text.secondary" sx={{ textAlign: 'center', mt: 4 }}>
              Bạn chưa có bài viết nào.
            </Typography>
          )}
        </Box>
      </Paper>
      <Dialog open={openDeleteDialog} onClose={handleCloseDeleteDialog}>
        <DialogTitle>Xác nhận xóa bài viết</DialogTitle>
        <DialogContent>Bạn có chắc chắn muốn xóa bài viết này không?</DialogContent>
        <DialogActions>
          <Button onClick={handleCloseDeleteDialog}>Hủy</Button>
          <Button onClick={handleConfirmDelete} color="error">Xóa</Button>
        </DialogActions>
      </Dialog>
    </Container>
  );
};

export default MyBlogList; 