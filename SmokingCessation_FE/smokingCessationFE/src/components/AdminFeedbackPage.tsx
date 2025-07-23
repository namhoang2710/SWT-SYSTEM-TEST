// Tạo file mới - Trang quản lý feedback cho Admin
import React, { useState, useEffect } from 'react';
import { getAllBlogFeedbacks, getAllAdminCommentFeedbacks, getCoachFeedbacks, deleteCommentFeedback, deleteBlogFeedback, deleteCoachFeedback } from '../api/services/feedbackService';
import { getAllCoachesForAdmin } from '../api/services/userService';
import { useAuth } from '../contexts/AuthContext';
import { toast } from 'react-toastify';
import { Dialog, DialogTitle, DialogActions, Button, Box, Typography, Tabs, Tab, Card, CardContent, Avatar, IconButton, Paper, FormControl, InputLabel, Select, MenuItem, CircularProgress, Fade } from '@mui/material';
import DeleteIcon from '@mui/icons-material/Delete';
import CommentIcon from '@mui/icons-material/Comment';
import ArticleIcon from '@mui/icons-material/Article';
import PersonIcon from '@mui/icons-material/Person';
import { useNavigate } from 'react-router-dom';

const tabOptions = [
  { value: 'comment', label: 'Feedback cho Comment', icon: <CommentIcon sx={{ mr: 1 }} /> },
  { value: 'blog', label: 'Feedback cho Blog', icon: <ArticleIcon sx={{ mr: 1 }} /> },
  { value: 'coach', label: 'Feedback cho Coach', icon: <PersonIcon sx={{ mr: 1 }} /> },
];

const AdminFeedbackPage: React.FC = () => {
  const { user } = useAuth();
  const [feedbacks, setFeedbacks] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [tab, setTab] = useState<'comment' | 'blog' | 'coach'>('comment');
  const [coachList, setCoachList] = useState<any[]>([]);
  const [selectedCoach, setSelectedCoach] = useState<string>('');
  const [loadingCoachList, setLoadingCoachList] = useState(false);
  const navigate = useNavigate();
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [deleteTarget, setDeleteTarget] = useState<{ id: number, type: 'comment' | 'blog' | 'coach', extra?: any } | null>(null);

  useEffect(() => {
    if (user?.role === 'Admin') {
      loadFeedbacks(tab);
      if (tab === 'coach') {
        setLoadingCoachList(true);
        getAllCoachesForAdmin().then((data) => {
          setCoachList(data);
          setLoadingCoachList(false);
        });
      }
    }
  }, [user, tab]);

  const loadFeedbacks = async (type: 'comment' | 'blog' | 'coach', coachId?: string) => {
    setLoading(true);
    try {
      if (type === 'comment') {
        const commentFeedbacks = await getAllAdminCommentFeedbacks();
        setFeedbacks(commentFeedbacks.map((f: any) => ({ ...f, type: 'comment', feedbackId: f.commentFeedbackID })));
      } else if (type === 'blog') {
        const blogFeedbacks = await getAllBlogFeedbacks();
        setFeedbacks(blogFeedbacks.map((f: any) => ({ ...f, type: 'blog', feedbackId: f.feedbackBlogID })));
      } else if (type === 'coach' && coachId) {
        const coachFeedbacks = await getCoachFeedbacks(Number(coachId));
        setFeedbacks(coachFeedbacks.map((f: any) => ({ ...f, type: 'coach', feedbackId: f.coachFeedbackID })));
      } else {
        setFeedbacks([]);
      }
    } catch (error) {
      toast.error('Không thể tải danh sách phản hồi');
    } finally {
      setLoading(false);
    }
  };

  const handleCoachChange = (e: any) => {
    setSelectedCoach(e.target.value);
    if (e.target.value) {
      loadFeedbacks('coach', e.target.value);
    } else {
      setFeedbacks([]);
    }
  };

  if (user?.role !== 'Admin') {
    return <Box textAlign="center" py={8}>Không có quyền truy cập</Box>;
  }

  return (
    <Box sx={{ p: { xs: 1, md: 4 }, maxWidth: 1400, mx: 'auto', minHeight: '100vh', bgcolor: '#f8fafc' }}>
      <Typography
        variant="h2"
        fontWeight={900}
        textAlign="center"
        sx={{
          mb: 4,
          background: 'linear-gradient(90deg, #6366f1 30%, #06b6d4 100%)',
          WebkitBackgroundClip: 'text',
          WebkitTextFillColor: 'transparent',
          letterSpacing: 1,
          textShadow: '0 2px 16px rgba(99,102,241,0.10)',
          lineHeight: 1.1,
        }}
      >
        Quản lý Phản hồi
        <Box sx={{ display: 'block', width: 120, height: 5, background: 'linear-gradient(90deg, #06b6d4 0%, #6366f1 100%)', borderRadius: 99, mx: 'auto', mt: 2, opacity: 0.7 }} />
      </Typography>
      <Paper elevation={2} sx={{ mb: 3, borderRadius: 3, p: 1, bgcolor: '#fff', display: 'flex', justifyContent: 'center' }}>
        <Tabs
          value={tab}
          onChange={(_, v) => setTab(v)}
          textColor="primary"
          indicatorColor="primary"
          variant="fullWidth"
          sx={{ minHeight: 56 }}
        >
          {tabOptions.map(opt => (
            <Tab
              key={opt.value}
              value={opt.value}
              label={<Box sx={{ display: 'flex', alignItems: 'center', fontWeight: 700, fontSize: 17 }}>{opt.icon}{opt.label}</Box>}
              sx={{ fontWeight: 700, fontSize: 17, minHeight: 56 }}
            />
          ))}
        </Tabs>
      </Paper>
      {tab === 'coach' && !loadingCoachList && (
        <Box maxWidth={400} mx="auto" mb={3}>
          <FormControl fullWidth size="medium">
            <InputLabel id="select-coach-label">Chọn Coach</InputLabel>
            <Select
              labelId="select-coach-label"
              value={selectedCoach}
              label="Chọn Coach"
              onChange={handleCoachChange}
              sx={{ borderRadius: 2, bgcolor: '#f8fafc' }}
            >
              <MenuItem value="">Chọn Coach</MenuItem>
              {coachList.map(coach => (
                <MenuItem key={coach.id} value={coach.id}>{coach.name}</MenuItem>
              ))}
            </Select>
          </FormControl>
        </Box>
      )}
      {tab === 'coach' && loadingCoachList && (
        <Box textAlign="center" mb={3} minHeight={60}>
          <CircularProgress color="primary" thickness={5} size={40} sx={{ mb: 1 }} />
          <Typography color="primary" fontWeight={600}>Đang tải danh sách coach...</Typography>
        </Box>
      )}
      {loading ? (
        <Fade in={loading}><Box display="flex" flexDirection="column" alignItems="center" justifyContent="center" minHeight={180}>
          <CircularProgress color="primary" thickness={5} size={48} sx={{ mb: 2 }} />
          <Typography color="primary" fontWeight={600} fontSize={18}>Đang tải...</Typography>
        </Box></Fade>
      ) : (
        <Box display="flex" flexWrap="wrap" gap={3} justifyContent={{ xs: 'center', md: 'flex-start' }}>
          {feedbacks.length === 0 && (
            <Paper elevation={0} sx={{ p: 6, mx: 'auto', my: 4, textAlign: 'center', borderRadius: 4, bgcolor: '#f1f5f9', minWidth: 320 }}>
              <Box mb={2}><CommentIcon sx={{ fontSize: 48, color: '#6366f1', opacity: 0.5 }} /></Box>
              <Typography color="text.secondary" fontWeight={500} fontSize={18}>Chưa có phản hồi nào</Typography>
            </Paper>
          )}
          {tab === 'comment' && feedbacks.map(feedback => (
            <Card key={feedback.feedbackId} sx={{ maxWidth: 420, width: '100%', borderRadius: 4, boxShadow: 3, p: 0, cursor: 'pointer', transition: 'box-shadow 0.2s', '&:hover': { boxShadow: 8, transform: 'translateY(-2px)' }, mx: 'auto' }} onClick={() => navigate('/admin/blogs', { state: { scrollToBlogId: feedback.comment?.blog?.blogID, openCommentBlogId: feedback.comment?.blog?.blogID, scrollToCommentId: feedback.comment?.commentId || feedback.comment?.commentID } })}>
              <CardContent sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                <Box display="flex" alignItems="center" gap={2} mb={1}>
                  <Avatar src={feedback.comment?.account?.image || '/images/default-avatar.png'} alt={feedback.comment?.account?.name || 'Ẩn danh'} sx={{ width: 56, height: 56, boxShadow: 2, border: '2.5px solid #6366f1' }} />
                  <Box>
                    <Typography fontWeight={700} fontSize={18} color="#232946">{feedback.comment?.account?.name || 'Ẩn danh'}</Typography>
                    <Typography fontSize={13} color="#6b7280">{feedback.createdDate?.split('T')[0]} {feedback.createdTime?.split('T')[1] || feedback.createdTime}</Typography>
                  </Box>
                </Box>
                <Paper elevation={0} sx={{ bgcolor: '#fff', borderRadius: 2, p: 1.5, mb: 1, boxShadow: 0 }}>
                  <Typography color="primary" fontWeight={600} display="inline">Bình luận:</Typography>
                  <Typography display="inline" sx={{ ml: 1, color: '#374151' }}>{feedback.comment?.content}</Typography>
                </Paper>
                <Paper elevation={0} sx={{ bgcolor: '#f1f5f9', borderRadius: 2, p: 1.5, boxShadow: 0 }}>
                  <Typography color="error" fontWeight={600} display="inline">Feedback:</Typography>
                  <Typography display="inline" sx={{ ml: 1, color: '#232946' }}>{feedback.information}</Typography>
                </Paper>
                <Box display="flex" justifyContent="flex-end" mt={1}>
                  <IconButton color="error" onClick={e => { e.stopPropagation(); setDeleteTarget({ id: feedback.feedbackId, type: 'comment' }); setDeleteDialogOpen(true); }}>
                    <DeleteIcon />
                  </IconButton>
                </Box>
              </CardContent>
            </Card>
          ))}
          {tab === 'blog' && feedbacks.map(feedback => (
            <Card key={feedback.feedbackId} sx={{ maxWidth: 520, width: '100%', borderRadius: 4, boxShadow: 3, p: 0, cursor: 'pointer', transition: 'box-shadow 0.2s', '&:hover': { boxShadow: 8, transform: 'translateY(-2px)' }, mx: 'auto' }} onClick={() => navigate('/admin/blogs', { state: { scrollToBlogId: feedback.blog?.blogID } })}>
              <CardContent sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                <Box display="flex" alignItems="center" gap={2} mb={1}>
                  <Avatar src={feedback.blog?.account?.image || '/images/default-avatar.png'} alt={feedback.blog?.account?.name || 'Ẩn danh'} sx={{ width: 56, height: 56, boxShadow: 2, border: '2.5px solid #6366f1' }} />
                  <Box>
                    <Typography fontWeight={700} fontSize={18} color="#232946">{feedback.blog?.account?.name || 'Ẩn danh'}</Typography>
                    <Typography fontSize={13} color="#6b7280">{feedback.createdDate} {feedback.createdTime}</Typography>
                  </Box>
                </Box>
                <Paper elevation={0} sx={{ bgcolor: '#fff', borderRadius: 2, p: 1.5, mb: 1, boxShadow: 0 }}>
                  <Typography fontWeight={600} color="primary" fontSize={16} mb={0.5}>Tiêu đề blog: {feedback.blog?.title}</Typography>
                  <Typography color="#374151" mb={0.5}>{feedback.blog?.content}</Typography>
                  {feedback.blog?.image && (
                    <Box mt={1}>
                      <img src={feedback.blog.image} alt={feedback.blog.title} style={{ width: '100%', borderRadius: 10, maxHeight: 220, objectFit: 'cover', boxShadow: '0 1px 8px rgba(99,102,241,0.08)' }} />
                    </Box>
                  )}
                </Paper>
                <Paper elevation={0} sx={{ bgcolor: '#f1f5f9', borderRadius: 2, p: 2, boxShadow: 0 }}>
                  <Typography color="error" fontWeight={700} fontSize={16} display="inline">Feedback:</Typography>
                  <Typography display="inline" sx={{ ml: 1, color: '#232946', fontSize: 16 }}>{feedback.information}</Typography>
                </Paper>
                <Box display="flex" justifyContent="flex-end" mt={1}>
                  <IconButton color="error" onClick={e => { e.stopPropagation(); setDeleteTarget({ id: feedback.feedbackId, type: 'blog' }); setDeleteDialogOpen(true); }}>
                    <DeleteIcon />
                  </IconButton>
                </Box>
              </CardContent>
            </Card>
          ))}
          {tab === 'coach' && feedbacks.map(feedback => (
            <Card key={feedback.coachFeedbackID} sx={{ maxWidth: 520, width: '100%', borderRadius: 4, boxShadow: 3, p: 0, mx: 'auto', transition: 'box-shadow 0.2s', '&:hover': { boxShadow: 8, transform: 'translateY(-2px)' } }}>
              <CardContent sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                <Box display="flex" alignItems="center" gap={2} mb={1}>
                  <Avatar src={feedback.image || '/images/default-avatar.png'} alt={feedback.name || 'Ẩn danh'} sx={{ width: 56, height: 56, boxShadow: 2, border: '2.5px solid #6366f1' }} />
                  <Box>
                    <Typography fontWeight={700} fontSize={18} color="#232946">{feedback.name || 'Ẩn danh'}</Typography>
                    <Typography fontSize={13} color="#6b7280">{feedback.createdDate} {feedback.createdTime}</Typography>
                  </Box>
                </Box>
                <Paper elevation={0} sx={{ bgcolor: '#f1f5f9', borderRadius: 2, p: 2, boxShadow: 0 }}>
                  <Typography color="error" fontWeight={700} fontSize={16} display="inline">Feedback:</Typography>
                  <Typography display="inline" sx={{ ml: 1, color: '#232946', fontSize: 16 }}>{feedback.information}</Typography>
                </Paper>
                <Box display="flex" justifyContent="flex-end" mt={1}>
                  <IconButton color="error" onClick={e => { e.stopPropagation(); setDeleteTarget({ id: feedback.coachFeedbackID, type: 'coach', extra: selectedCoach }); setDeleteDialogOpen(true); }}>
                    <DeleteIcon />
                  </IconButton>
                </Box>
              </CardContent>
            </Card>
          ))}
        </Box>
      )}
      <Dialog open={deleteDialogOpen} onClose={() => setDeleteDialogOpen(false)}>
        <DialogTitle>Bạn có chắc chắn muốn xóa feedback này không?</DialogTitle>
        <DialogActions>
          <Button onClick={() => setDeleteDialogOpen(false)}>Hủy</Button>
          <Button
            color="error"
            variant="contained"
            onClick={async () => {
              if (deleteTarget) {
                if (deleteTarget.type === 'comment') await deleteCommentFeedback(deleteTarget.id);
                if (deleteTarget.type === 'blog') await deleteBlogFeedback(deleteTarget.id);
                if (deleteTarget.type === 'coach') await deleteCoachFeedback(deleteTarget.id);
                toast.success('Đã xóa feedback thành công!');
                if (deleteTarget.type === 'comment') loadFeedbacks('comment');
                if (deleteTarget.type === 'blog') loadFeedbacks('blog');
                if (deleteTarget.type === 'coach') loadFeedbacks('coach', deleteTarget.extra);
              }
              setDeleteDialogOpen(false);
              setDeleteTarget(null);
            }}
          >
            Xóa
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default AdminFeedbackPage;