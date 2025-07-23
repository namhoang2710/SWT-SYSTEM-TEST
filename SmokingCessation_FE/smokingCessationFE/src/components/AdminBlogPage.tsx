import React, { useEffect, useRef, useState } from 'react';
import { Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper, Button, IconButton, Dialog, DialogTitle, DialogActions } from '@mui/material';
import { Delete, Edit, Visibility } from '@mui/icons-material';
import { getAllBlogsForAdmin, deleteBlogByIdForAdmin, getBlogByIdForAdmin } from '../api/services/blogService';
import { toast } from 'react-toastify';
import Avatar from '@mui/material/Avatar';
import ChatBubbleOutlineIcon from '@mui/icons-material/ChatBubbleOutline';
import FavoriteBorderIcon from '@mui/icons-material/FavoriteBorder';
import BookmarkBorderIcon from '@mui/icons-material/BookmarkBorder';
import CloseIcon from '@mui/icons-material/Close';
import TextField from '@mui/material/TextField';
import InputAdornment from '@mui/material/InputAdornment';
import SearchIcon from '@mui/icons-material/Search';
import { getCommentsByBlogId, type Comment, deleteComment } from '../api/services/commentService';
import { useLocation } from 'react-router-dom';
import './AdminBlogPageHighlight.css';
import DeleteIcon from '@mui/icons-material/Delete';

const AdminBlogPage: React.FC = () => {
  const [blogs, setBlogs] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);
  const [deleteId, setDeleteId] = useState<number | null>(null);
  const [deleteDialog, setDeleteDialog] = useState(false);
  const [selectedBlog, setSelectedBlog] = useState<any | null>(null);
  const [viewDialog, setViewDialog] = useState(false);
  const [search, setSearch] = useState('');
  const [commentCounts, setCommentCounts] = useState<Record<number, number>>({});
  const [openCommentBlogId, setOpenCommentBlogId] = useState<number | null>(null);
  const [comments, setComments] = useState<Comment[]>([]);
  const [loadingComments, setLoadingComments] = useState(false);
  const [highlightedCommentId, setHighlightedCommentId] = useState<number | null>(null);
  const [highlightedBlogId, setHighlightedBlogId] = useState<number | null>(null);
  const [deleteCommentDialogOpen, setDeleteCommentDialogOpen] = useState(false);
  const [deleteCommentTarget, setDeleteCommentTarget] = useState<number | null>(null);

  const blogRefs = useRef<Record<number, HTMLDivElement | null>>({});
  const commentRefs = useRef<Record<number, HTMLDivElement | null>>({});
  const location = useLocation();

  const fetchBlogs = async () => {
    setLoading(true);
    try {
      const res = await getAllBlogsForAdmin();
      // Sắp xếp từ mới nhất tới cũ nhất
      const sorted = res.slice().sort((a, b) => {
        const dateA = new Date(`${a.createdDate}T${a.createdTime}`);
        const dateB = new Date(`${b.createdDate}T${b.createdTime}`);
        return dateB.getTime() - dateA.getTime();
      });
      setBlogs(sorted);
      // Gọi API lấy số lượng comment cho từng blog
      const counts: Record<number, number> = {};
      await Promise.all(sorted.map(async (blog) => {
        const comments = await getCommentsByBlogId(blog.blogID);
        counts[blog.blogID] = comments.length;
      }));
      setCommentCounts(counts);
    } catch (err) {
      toast.error('Không thể tải danh sách blog!');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchBlogs();
  }, []);

  // Thêm helper xóa state điều hướng:
  function clearLocationState() {
    if (window.history.replaceState) {
      window.history.replaceState({}, document.title, window.location.pathname + window.location.search);
    }
  }

  useEffect(() => {
    if (location.state?.scrollToBlogId && blogRefs.current[location.state.scrollToBlogId]) {
      blogRefs.current[location.state.scrollToBlogId]?.scrollIntoView({ behavior: 'smooth', block: 'center' });
      setHighlightedBlogId(location.state.scrollToBlogId);
      setTimeout(() => setHighlightedBlogId(null), 1200);
      clearLocationState();
    }
    // Tự động mở comment nếu có yêu cầu
    if (location.state?.openCommentBlogId) {
      handleShowComments(location.state.openCommentBlogId);
      clearLocationState();
    }
  }, [blogs, location.state]);

  useEffect(() => {
    if (location.state?.scrollToCommentId && commentRefs.current[location.state.scrollToCommentId]) {
      setTimeout(() => {
        commentRefs.current[location.state.scrollToCommentId]?.scrollIntoView({ behavior: 'smooth', block: 'center' });
        setHighlightedCommentId(location.state.scrollToCommentId);
        setTimeout(() => setHighlightedCommentId(null), 1500);
        clearLocationState();
      }, 300);
    }
  }, [comments, location.state]);

  const handleDelete = async () => {
    if (!deleteId) return;
    try {
      await deleteBlogByIdForAdmin(deleteId);
      toast.success('Xóa blog thành công!');
      setDeleteDialog(false);
      fetchBlogs();
    } catch (err) {
      toast.error('Xóa blog thất bại!');
    }
  };

  const handleView = async (blogId: number) => {
    try {
      const blog = await getBlogByIdForAdmin(blogId);
      setSelectedBlog(blog);
      setViewDialog(true);
    } catch (err) {
      toast.error('Không thể tải chi tiết blog!');
    }
  };

  const handleShowComments = async (blogId: number) => {
    if (openCommentBlogId === blogId) {
      setOpenCommentBlogId(null);
      setComments([]);
      return;
    }
    setOpenCommentBlogId(blogId);
    setLoadingComments(true);
    const comments = await getCommentsByBlogId(blogId);
    setComments(comments);
    setLoadingComments(false);
  };

  // Lọc blogs theo search
  const filteredBlogs = blogs.filter(blog =>
    blog.title.toLowerCase().includes(search.toLowerCase()) ||
    blog.content.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div style={{ maxWidth: 950, margin: '40px auto', background: '#f8f0e3', minHeight: '100vh', padding: '40px 0' }}>
      <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', width: '100%' }}>
        <h2
          style={{
            fontSize: 38,
            fontWeight: 900,
            marginBottom: 32,
            color: 'transparent',
            background: 'linear-gradient(90deg, #232946 60%, #a259d9 100%)',
            WebkitBackgroundClip: 'text',
            backgroundClip: 'text',
            textAlign: 'center',
            letterSpacing: 1,
            lineHeight: 1.1,
            position: 'relative',
            display: 'inline-block',
          }}
        >
          Quản lý bài viết
          <span
            style={{
              display: 'block',
              width: 120,
              height: 5,
              background: 'linear-gradient(90deg, #a259d9 0%, #232946 100%)',
              borderRadius: 99,
              margin: '16px auto 0 auto',
              opacity: 0.7,
            }}
          />
        </h2>
      </div>
      {/* Thanh tìm kiếm */}
      <div style={{ maxWidth: 420, margin: '0 auto 32px auto' }}>
        <TextField
          fullWidth
          variant="outlined"
          placeholder="Tìm kiếm bài viết..."
          value={search}
          onChange={e => setSearch(e.target.value)}
          InputProps={{
            startAdornment: (
              <InputAdornment position="start">
                <SearchIcon sx={{ color: '#888' }} />
              </InputAdornment>
            ),
            sx: { borderRadius: 99, background: '#fff' }
          }}
          sx={{ borderRadius: 99 }}
        />
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 32 }}>
        {filteredBlogs.map((blog) => (
          <div
            key={blog.blogID}
            ref={el => { blogRefs.current[blog.blogID] = el; }}
            className={highlightedBlogId === blog.blogID ? 'highlight-animated-blog' : ''}
            style={{
              display: 'flex',
              background: '#fff',
              borderRadius: 22,
              boxShadow: '0 6px 32px rgba(44,62,80,0.10)',
              overflow: 'hidden',
              alignItems: 'stretch',
              minHeight: 180,
              transition: 'box-shadow 0.2s, transform 0.2s',
              position: 'relative',
              padding: 0,
              cursor: 'pointer',
              marginBottom: 24,
              flexDirection: 'column',
            }}
            onMouseOver={e => {
              (e.currentTarget as HTMLDivElement).style.boxShadow = '0 16px 40px rgba(44,62,80,0.18)';
              (e.currentTarget as HTMLDivElement).style.transform = 'translateY(-4px) scale(1.015)';
            }}
            onMouseOut={e => {
              (e.currentTarget as HTMLDivElement).style.boxShadow = '0 6px 32px rgba(44,62,80,0.10)';
              (e.currentTarget as HTMLDivElement).style.transform = 'none';
            }}
          >
            <div style={{ display: 'flex' }}>
              {/* Ảnh blog */}
              <div style={{ position: 'relative', width: 240, height: 'auto', display: 'flex', flexDirection: 'column' }}>
                <img
                  src={blog.image || '/images/default-blog.jpg'}
                  alt={blog.title}
                  style={{
                    width: '100%',
                    height: '100%',
                    minHeight: 180,
                    objectFit: 'cover',
                    borderTopLeftRadius: 22,
                    borderBottomLeftRadius: 22,
                    background: '#e0e0e0',
                    display: 'block',
                    flex: 1,
                    transition: 'filter 0.2s',
                  }}
                />
                {/* Overlay khi hover */}
                <div
                  style={{
                    position: 'absolute',
                    top: 0, left: 0, right: 0, bottom: 0,
                    background: 'rgba(44,62,80,0.08)',
                    opacity: 0,
                    transition: 'opacity 0.2s',
                    pointerEvents: 'none',
                  }}
                  className="blog-image-overlay"
                />
              </div>
              {/* Nội dung bên phải */}
              <div style={{ flex: 1, minHeight: 260, display: 'flex', flexDirection: 'column', justifyContent: 'flex-start', padding: '28px 32px 0 32px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 14, marginBottom: 6 }}>
                  <span style={{ color: '#b6b6b6', fontSize: 14, fontWeight: 600, letterSpacing: 1 }}>BLOG</span>
                  <span style={{ color: '#b6b6b6', fontSize: 14 }}>•</span>
                  <span style={{ color: '#b6b6b6', fontSize: 14 }}>{blog.createdDate} {blog.createdTime}</span>
                  {/* Nếu có trạng thái */}
                  {blog.status && (
                    <span style={{
                      background: blog.status === 'Public' ? '#22c55e' : '#64748b',
                      color: '#fff',
                      borderRadius: 8,
                      padding: '2px 10px',
                      fontSize: 13,
                      fontWeight: 700,
                      marginLeft: 10,
                    }}>
                      {blog.status}
                    </span>
                  )}
                </div>
                <div style={{ fontSize: 25, fontWeight: 800, marginBottom: 8, color: '#232946', lineHeight: 1.2 }}>{blog.title}</div>
                <div style={{
                  color: '#444',
                  fontSize: 17,
                  marginBottom: 0,
                  overflow: 'hidden',
                  textOverflow: 'ellipsis',
                  display: '-webkit-box',
                  WebkitLineClamp: 2,
                  WebkitBoxOrient: 'vertical',
                  fontWeight: 500
                }}>
                  {blog.content}
                </div>
                {/* Footer */}
                <div style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: 14,
                  marginTop: 22,
                  padding: '18px 0 6px 0',
                  borderTop: '1.5px solid #f0ece7',
                  minHeight: 56,
                  width: '100%',
                  background: 'transparent',
                }}>
                  <Avatar src={blog.account?.image || undefined} alt={blog.account?.name || 'Ẩn danh'} sx={{ width: 42, height: 42, border: '2.5px solid #e0e0e0', boxShadow: '0 2px 8px rgba(44,62,80,0.10)' }} />
                  <span style={{ fontWeight: 700, fontSize: 17, color: '#232946' }}>{blog.account?.name || 'Ẩn danh'}</span>
                  <span style={{ color: '#b6b6b6', fontSize: 15 }}>{blog.createdDate} {blog.createdTime}</span>
                  <span style={{ flex: 1 }}></span>
                  <span style={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                    <FavoriteBorderIcon fontSize="small" style={{ color: '#e74c3c', transition: 'color 0.2s' }} />
                    <span style={{ color: '#e74c3c', fontSize: 16, marginRight: 16 }}>{blog.likes ?? 0}</span>
                    <IconButton sx={{ color: '#1976d2' }} title="Xem bình luận" onClick={() => handleShowComments(blog.blogID)}>
                      <ChatBubbleOutlineIcon />
                      <span style={{ marginLeft: 4, fontWeight: 600, fontSize: 17 }}>{commentCounts[blog.blogID] ?? 0}</span>
                    </IconButton>
                  </span>
                  {/* Nút xem/xóa/sửa khác giữ nguyên */}
                  <IconButton color="primary" title="Xem chi tiết" onClick={() => handleView(blog.blogID)}><Visibility /></IconButton>
                  <IconButton sx={{ color: '#e74c3c' }} title="Xóa" onClick={() => { setDeleteId(blog.blogID); setDeleteDialog(true); }}><Delete /></IconButton>
                </div>
              </div>
            </div>
            {/* Hiển thị bình luận nếu blog này đang mở */}
            {openCommentBlogId === blog.blogID && (
              <div style={{ maxHeight: 320, overflowY: 'auto', overflowX: 'hidden', background: '#fff', borderRadius: 10, boxShadow: '0 2px 8px rgba(44,62,80,0.06)', padding: 18, margin: '0 18px 18px 18px', minWidth: 0 }}>
                <div style={{ fontWeight: 700, color: '#232946', margin: '0 0 10px 0', fontSize: 17 }}>Bình luận:</div>
                {loadingComments ? (
                  <div>Đang tải bình luận...</div>
                ) : comments.length === 0 ? (
                  <div style={{ color: '#888', fontStyle: 'italic' }}>Chưa có bình luận nào.</div>
                ) : (
                  comments.map(comment => {
                    const c: any = comment;
                    const name = c.commenterName || c.account?.name || c.account?.email || 'Ẩn danh';
                    const image = c.commenterImage || c.account?.image || '/images/default-avatar.png';
                    return (
                      <div
                        key={c.commentId}
                        ref={el => { commentRefs.current[c.commentId] = el; }}
                        className={highlightedCommentId === c.commentId ? 'highlight-animated-comment comment-row' : 'comment-row'}
                        style={{ display: 'flex', alignItems: 'flex-start', gap: 12, marginBottom: 18, position: 'relative' }}
                      >
                        <img
                          src={image}
                          alt={name}
                          style={{ width: 40, height: 40, borderRadius: '50%', objectFit: 'cover', marginTop: 2 }}
                        />
                        <div style={{ flex: 1 }}>
                          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                            <span style={{ fontWeight: 600, color: '#232946', fontSize: 16 }}>{name}</span>
                            {c.account?.email && !c.commenterName && (
                              <span style={{ color: '#888', fontSize: 13, marginLeft: 4 }}>{c.account.email}</span>
                            )}
                            {c.account && 'role' in c.account && c.account.role && (
                              <span style={{ color: '#1976d2', fontSize: 12, marginLeft: 8, fontWeight: 500 }}>{c.account.role}</span>
                            )}
                            {c.account && 'status' in c.account && c.account.status && (
                              <span style={{ color: '#22c55e', fontSize: 12, marginLeft: 8, fontWeight: 500 }}>{c.account.status}</span>
                            )}
                          </div>
                          <div style={{ color: '#888', fontSize: 13, marginBottom: 2 }}>{c.createdDate} {c.createdTime}</div>
                          <div style={{ color: '#232946', fontSize: 16, background: '#f8fafc', borderRadius: 8, padding: '7px 14px', lineHeight: 1.5, minHeight: 38, maxWidth: '100%', wordBreak: 'break-word', overflow: 'hidden', display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 8 }}>
                            <span>{c.content}</span>
                            <button
                              onClick={() => {
                                setDeleteCommentTarget(c.commentId);
                                setDeleteCommentDialogOpen(true);
                              }}
                              className="comment-delete-btn"
                              style={{
                                background: '#ef4444',
                                color: '#fff',
                                border: 'none',
                                borderRadius: '50%',
                                padding: 0,
                                width: 28,
                                height: 28,
                                minWidth: 0,
                                minHeight: 0,
                                display: 'flex',
                                alignItems: 'center',
                                justifyContent: 'center',
                                boxShadow: '0 2px 8px rgba(239,68,68,0.10)',
                                opacity: 0.85,
                                transition: 'opacity 0.2s, box-shadow 0.2s',
                                cursor: 'pointer',
                                marginLeft: 8
                              }}
                              onMouseEnter={e => { e.currentTarget.style.opacity = '1'; e.currentTarget.style.boxShadow = '0 4px 16px rgba(239,68,68,0.18)'; }}
                              onMouseLeave={e => { e.currentTarget.style.opacity = '0.85'; e.currentTarget.style.boxShadow = '0 2px 8px rgba(239,68,68,0.10)'; }}
                            >
                              <DeleteIcon style={{ fontSize: 17 }} />
                            </button>
                          </div>
                        </div>
                      </div>
                    );
                  })
                )}
              </div>
            )}
          </div>
        ))}
      </div>

      {/* Dialog xác nhận xóa */}
      <Dialog open={deleteDialog} onClose={() => setDeleteDialog(false)}>
        <DialogTitle>Xác nhận xóa blog?</DialogTitle>
        <DialogActions>
          <Button onClick={() => setDeleteDialog(false)}>Hủy</Button>
          <Button onClick={handleDelete} color="error" variant="contained">Xóa</Button>
        </DialogActions>
      </Dialog>

      {/* Dialog xem chi tiết blog */}
      <Dialog open={viewDialog} onClose={() => setViewDialog(false)} maxWidth="md" fullWidth>
        <DialogTitle sx={{ fontSize: 28, fontWeight: 800, color: '#232946', pb: 0, pr: 6, position: 'relative' }}>
          Chi tiết Blog
          <IconButton
            aria-label="close"
            onClick={() => setViewDialog(false)}
            sx={{
              position: 'absolute',
              right: 12,
              top: 12,
              color: '#888',
              background: 'rgba(0,0,0,0.03)',
              '&:hover': { background: 'rgba(25, 118, 210, 0.08)', color: '#1976d2' },
              zIndex: 10,
            }}
            size="large"
          >
            <CloseIcon fontSize="large" />
          </IconButton>
        </DialogTitle>
        <div style={{ padding: 32, background: '#f8fafc', minHeight: 320 }}>
          {selectedBlog ? (
            <>
              <div style={{ fontSize: 24, fontWeight: 700, color: '#232946', marginBottom: 10 }}>{selectedBlog.title}</div>
              <div style={{ marginBottom: 8, color: '#444', fontSize: 17 }}>
                <b>Tác giả:</b> <span style={{ fontWeight: 600 }}>{selectedBlog.account?.name || 'Ẩn danh'}</span>
              </div>
              <div style={{ marginBottom: 16, color: '#888', fontSize: 15 }}>
                <b>Ngày tạo:</b> {selectedBlog.createdDate} {selectedBlog.createdTime}
              </div>
              <div style={{ fontWeight: 700, color: '#232946', marginBottom: 6, fontSize: 17 }}>Nội dung:</div>
              <div style={{ whiteSpace: 'pre-line', marginBottom: 24, color: '#232946', fontSize: 17, lineHeight: 1.7, background: '#fff', borderRadius: 12, padding: 18, boxShadow: '0 2px 12px rgba(44,62,80,0.06)' }}>{selectedBlog.content}</div>
              {selectedBlog.image && (
                <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', margin: '36px 0 48px 0' }}>
                  <img
                    src={selectedBlog.image}
                    alt="Blog"
                    style={{
                      display: 'block',
                      maxWidth: 420,
                      width: '100%',
                      borderRadius: 28,
                      boxShadow: '0 8px 32px rgba(44,62,80,0.13)',
                      background: '#e0e0e0',
                      objectFit: 'cover',
                    }}
                  />
                </div>
              )}
            </>
          ) : (
            <p>Đang tải...</p>
          )}
        </div>
      </Dialog>

      {/* Dialog xác nhận xóa comment */}
      <Dialog open={deleteCommentDialogOpen} onClose={() => setDeleteCommentDialogOpen(false)}>
        <DialogTitle>Bạn có chắc chắn muốn xóa bình luận này không?</DialogTitle>
        <DialogActions>
          <Button onClick={() => setDeleteCommentDialogOpen(false)}>Hủy</Button>
          <Button
            color="error"
            variant="contained"
            onClick={async () => {
              if (deleteCommentTarget) {
                await deleteComment(deleteCommentTarget);
                toast.success('Đã xóa bình luận thành công!');
                setComments(prev => prev.filter(item => item.commentId !== deleteCommentTarget));
                // Cập nhật lại số lượng comment cho blog tương ứng
                if (openCommentBlogId) {
                  setCommentCounts(prev => ({
                    ...prev,
                    [openCommentBlogId]: (prev[openCommentBlogId] || 1) - 1
                  }));
                }
              }
              setDeleteCommentDialogOpen(false);
              setDeleteCommentTarget(null);
            }}
          >
            Xóa
          </Button>
        </DialogActions>
      </Dialog>
    </div>
  );
};

export default AdminBlogPage; 