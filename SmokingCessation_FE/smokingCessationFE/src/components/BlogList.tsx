import React, { useEffect, useState, useRef } from 'react';
import { useNavigate, Link, useSearchParams } from 'react-router-dom';
import { getAllBlogs, type BlogPost, deleteBlog, createBlogComment, likeBlog } from '../api/services/blogService';
import { getCommentsByBlogId, type Comment, updateComment, deleteComment } from '../api/services/commentService';
import { useAuth } from '../contexts/AuthContext';
import { formatDistanceToNow, parseISO } from 'date-fns';
import { vi } from 'date-fns/locale';
import { toast } from 'react-toastify';
import styles from './BlogList.module.css';
import BlogImage from './BlogImage';
import { FeedbackForm, FeedbackList } from './FeedbackComponents';
import { createBlogFeedback, getAllBlogFeedbacks, type FeedbackResponse } from '../api/services/feedbackService';
import { createCommentFeedback } from '../api/services/feedbackService';
import apiClient from '../api/apiClient';
import { motion, useAnimation, AnimationControls } from 'framer-motion';
import LikeButton from './LikeButton';

interface BlogListProps {
  displayMode?: 'default' | 'memberHome';
  allowEditComment?: boolean;
}

const BlogList: React.FC<BlogListProps> = ({ displayMode = 'default', allowEditComment = false }) => {
  const [blogs, setBlogs] = useState<BlogPost[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [showComments, setShowComments] = useState<Record<number, boolean>>({});
  const [blogComments, setBlogComments] = useState<Record<number, Comment[]>>({});
  const [newCommentContent, setNewCommentContent] = useState<Record<number, string>>({});
  const [commentLoading, setCommentLoading] = useState<Record<number, boolean>>({});
  const [commentSubmitting, setCommentSubmitting] = useState<Record<number, boolean>>({});
  const { isAuthenticated, user } = useAuth();
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const blogRefs = useRef<Map<number, HTMLDivElement | null>>(new Map());
  const [activeTab, setActiveTab] = useState<'forYou' | 'topRated'>('forYou');
  const [visibleCount, setVisibleCount] = useState(5);
  const [blogLikes, setBlogLikes] = useState<{ [blogId: number]: number }>({});
  const [likedBlogs, setLikedBlogs] = useState<{ [blogId: number]: boolean }>({});
  const [expandedBlogs, setExpandedBlogs] = useState<{ [blogId: number]: boolean }>({});
  const [showBlogFeedbacks, setShowBlogFeedbacks] = useState<Record<number, boolean>>({});
  const [feedbackLoading, setFeedbackLoading] = useState<Record<number, boolean>>({});
  const [blogFeedbacks, setBlogFeedbacks] = useState<Record<number, FeedbackResponse[]>>({});
  const [editingComment, setEditingComment] = useState<{ blogId: number, commentId: number, content: string } | null>(null);
  const [editSubmitting, setEditSubmitting] = useState(false);
  const [feedbackingCommentId, setFeedbackingCommentId] = useState<number | null>(null);
  const [feedbackContent, setFeedbackContent] = useState<string>('');
  const [deleteConfirm, setDeleteConfirm] = useState<{ blogId: number, commentId: number } | null>(null);
  const likeControls = useRef<{ [blogId: number]: any }>({});

  // Đặt filteredBlogs trước các useEffect sử dụng nó
  const filteredBlogs = displayMode === 'memberHome'
    ? [...blogs].sort((a, b) => {
        const dateA = new Date(`${a.createdDate}T${a.createdTime}`);
        const dateB = new Date(`${b.createdDate}T${b.createdTime}`);
        return dateB.getTime() - dateA.getTime();
      })
    : (activeTab === 'forYou' ? blogs : blogs.sort((a, b) => (b.commentCount || 0) - (a.commentCount || 0)));

  useEffect(() => {
    const fetchBlogs = async () => {
      try {
        const data = await getAllBlogs();
        console.log('📝 Blogs loaded:', data.length);
        setBlogs(data.map(blog => ({ ...blog, commentCount: 0 })));
        // Đồng bộ trạng thái likedBlogs từ API
        const likedMap: { [blogId: number]: boolean } = {};
        data.forEach(blog => {
          likedMap[blog.blogID] = !!blog.liked;
        });
        setLikedBlogs(likedMap);
        setError(null);
      } catch (err: any) {
        console.error('❌ Error loading blogs:', err);
        setError('Không thể tải bài viết. Vui lòng thử lại sau.');
      } finally {
        setLoading(false);
      }
    };

    fetchBlogs();
  }, []);

  useEffect(() => {
    const scrollToBlogId = searchParams.get('scrollTo');
    if (scrollToBlogId && displayMode === 'default') {
      const targetBlogElement = blogRefs.current.get(Number(scrollToBlogId));
      if (targetBlogElement) {
        targetBlogElement.scrollIntoView({ behavior: 'smooth', block: 'start' });
      }
    }
  }, [blogs, searchParams, displayMode]);

  useEffect(() => {
    setVisibleCount(5);
  }, [blogs]);

  useEffect(() => {
    const handleScroll = () => {
      if (
        window.innerHeight + window.scrollY >= document.body.offsetHeight - 200 &&
        visibleCount < filteredBlogs.length
      ) {
        setVisibleCount(v => Math.min(v + 5, filteredBlogs.length));
      }
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, [visibleCount, filteredBlogs.length]);

  const handleDelete = async (id: number) => {
    if (!isAuthenticated) {
      toast.info('Vui lòng đăng nhập để xóa bài viết');
      return;
    }

    if (!window.confirm('Bạn có chắc chắn muốn xóa bài viết này?')) {
      return;
    }

    try {
      await deleteBlog(id);
      setBlogs(blogs.filter(blog => blog.blogID !== id));
      toast.success('Xóa bài viết thành công');
    } catch (err: any) {
      console.error(`❌ Error deleting blog ${id}:`, err);
      toast.error('Không thể xóa bài viết. Vui lòng thử lại sau.');
    }
  };

  const handleCommentSubmit = async (blogId: number) => {
    if (!isAuthenticated || !user) {
      toast.info('Vui lòng đăng nhập để bình luận');
      return;
    }

    const content = newCommentContent[blogId]?.trim();
    if (!content) {
      toast.error('Nội dung bình luận không được để trống.');
      return;
    }

    setCommentSubmitting(prev => ({ ...prev, [blogId]: true }));

    try {
      console.log(`🔄 Submitting comment for blog ${blogId}...`);
      
      const newComment = await createBlogComment(blogId, content);
      console.log(`✅ Comment created:`, newComment);
      
      const localComment = {
        commentId: newComment.commentId !== undefined ? newComment.commentId : (newComment.commentID !== undefined ? newComment.commentID : Math.floor(Math.random() * 1000000)),
        accountId: user.id,
        content: content,
        createdDate: new Date().toISOString().split('T')[0],
        createdTime: new Date().toTimeString().split(' ')[0],
        commenterName: user.name,
        commenterImage: user.image,
        account: {
          id: user.id,
          email: user.email,
          name: user.name,
          image: user.image,
          role: user.role,
          status: user.status,
        },
      };
      
      setBlogComments(prevState => ({
        ...prevState,
        [blogId]: [...(prevState[blogId] || []), localComment],
      }));
      
      setNewCommentContent(prevState => ({ ...prevState, [blogId]: '' }));
      
      setBlogs(prevBlogs => prevBlogs.map(blog =>
        blog.blogID === blogId ? { ...blog, commentCount: (blog.commentCount || 0) + 1 } : blog
      ));
      
      toast.success('Bình luận của bạn đã được đăng!');
      
    } catch (err: any) {
      console.error(`❌ Error creating comment for blog ${blogId}:`, err);
      
      if (err.response?.status === 401) {
        toast.error('Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại');
      } else if (err.response?.status === 403) {
        toast.error('Bạn không có quyền bình luận');
      } else if (err.response?.status === 404) {
        toast.error('Bài viết không tồn tại');
      } else {
        toast.error(err.response?.data?.message || 'Không thể đăng bình luận. Vui lòng thử lại sau.');
      }
    } finally {
      setCommentSubmitting(prev => ({ ...prev, [blogId]: false }));
    }
  };

  const loadComments = async (blogId: number) => {
    console.log(`🔄 Starting loadComments for blog ${blogId}`);
    console.log(`🌐 API Base URL: ${window.location.origin.includes('localhost') ? 'http://localhost:8080/api' : 'https://smoking-cessation.onrender.com/api'}`);
    
    setCommentLoading(prev => ({ ...prev, [blogId]: true }));
    
    try {
      console.log(`📡 Calling getCommentsByBlogId(${blogId})...`);
      const comments = await getCommentsByBlogId(blogId);
      console.log(`✅ Comments loaded for blog ${blogId}:`, comments);
      console.log(`📊 Comment count: ${comments.length}`);
      
      setBlogComments(prevState => {
        const newState = {
          ...prevState,
          [blogId]: comments,
        };
        console.log(`💾 Updated blogComments state:`, newState);
        return newState;
      });
      
      setBlogs(prevBlogs => prevBlogs.map(blog =>
        blog.blogID === blogId ? { ...blog, commentCount: comments.length } : blog
      ));
      
    } catch (err: any) {
      console.error(`❌ Error loading comments for blog ${blogId}:`, err);
      console.error(`📊 Error status: ${err.response?.status}`);
      console.error(`📊 Error data:`, err.response?.data);
      console.error(`📊 Full error:`, err);
      
      setBlogComments(prevState => ({
        ...prevState,
        [blogId]: [],
      }));
      
      if (err.response?.status === 404) {
        toast.error(`Blog ${blogId} không tồn tại hoặc không có comment`);
      } else if (err.response?.status === 500) {
        toast.error('Lỗi server khi tải comment');
      } else {
        toast.error('Không thể tải comment. Vui lòng thử lại sau.');
      }
    } finally {
      setCommentLoading(prev => ({ ...prev, [blogId]: false }));
    }
  };

  const toggleComments = async (blogId: number) => {
    console.log(`🔘 Toggle comments clicked for blog ${blogId}`);
    
    const isCurrentlyShowing = showComments[blogId];
    console.log(`📊 Currently showing: ${isCurrentlyShowing}`);
    
    setShowComments(prevState => ({
      ...prevState,
      [blogId]: !prevState[blogId],
    }));

    if (isCurrentlyShowing) {
      console.log(`📴 Closing comments for blog ${blogId}`);
      return;
    }

    if (!blogComments[blogId] || blogComments[blogId].length === 0) {
      console.log(`📥 Loading comments for blog ${blogId}...`);
      await loadComments(blogId);
    } else {
      console.log(`📋 Comments already loaded for blog ${blogId}:`, blogComments[blogId]);
    }
  };

  const getPostReadTime = (content: string) => {
    const wordsPerMinute = 200;
    const words = content.split(/\s+/).length;
    const minutes = Math.ceil(words / wordsPerMinute);
    return `${minutes} phút đọc`;
  };

  const getRelativeTime = (createdDate: string, createdTime: string) => {
    try {
      const dateTimeString = `${createdDate}T${createdTime}`;
      const date = parseISO(dateTimeString);
      return formatDistanceToNow(date, { addSuffix: true, locale: vi });
    } catch (error) {
      return 'Không xác định';
    }
  };

  const handleLike = async (blogId: number) => {
    try {
      const newLikes = await likeBlog(blogId);
      setBlogLikes(prev => ({ ...prev, [blogId]: newLikes }));
      setLikedBlogs(prev => ({ ...prev, [blogId]: !prev[blogId] }));
    } catch (e) {
      // Có thể hiện thông báo lỗi nếu cần
    }
  };

  const toggleBlogFeedbacks = (blogId: number) => {
    setShowBlogFeedbacks(prev => ({ ...prev, [blogId]: !prev[blogId] }));
  };

  const handleCreateBlogFeedback = async (blogId: number, content: string, rating: number) => {
    if (!isAuthenticated || !user) {
      toast.info('Vui lòng đăng nhập để đánh giá bài viết');
      return;
    }

    setFeedbackLoading(prev => ({ ...prev, [blogId]: true }));

    try {
      console.log(`🔄 Submitting feedback for blog ${blogId}...`);
      
      const newFeedback = await createBlogFeedback(blogId, { information: content, rating });
      console.log(`✅ Feedback created:`, newFeedback);
      
      setBlogFeedbacks(prevState => ({
        ...prevState,
        [blogId]: [...(prevState[blogId] || []), newFeedback],
      }));
      
      toast.success('Đánh giá của bạn đã được đăng!');
      setShowBlogFeedbacks(prev => ({ ...prev, [blogId]: false }));
    } catch (err: any) {
      console.error(`❌ Error creating feedback for blog ${blogId}:`, err);
      
      if (err.response?.status === 401) {
        toast.error('Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại');
      } else if (err.response?.status === 403) {
        toast.error('Bạn không có quyền đánh giá');
      } else if (err.response?.status === 404) {
        toast.error('Bài viết không tồn tại');
      } else {
        toast.error(err.response?.data?.message || 'Không thể đăng đánh giá. Vui lòng thử lại sau.');
      }
    } finally {
      setFeedbackLoading(prev => ({ ...prev, [blogId]: false }));
    }
  };

  const handleOpenFeedback = (commentID: number) => {
    setFeedbackingCommentId(commentID);
    setFeedbackContent('');
  };

  const handleSendFeedback = async (commentId: number) => {
    if (!feedbackContent.trim()) return;
    try {
      await createCommentFeedback(commentId, { information: feedbackContent });
      toast.success('Đã gửi feedback cho bình luận!');
      setFeedbackContent('');
      setFeedbackingCommentId(null);
    } catch (err) {
      console.error('Feedback API error:', err);
      toast.error('Gửi feedback thất bại!');
    }
  };

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

  const visibleBlogs = filteredBlogs.slice(0, visibleCount);

  return (
    <div className={styles.container || 'max-w-6xl mx-auto p-4'}>
      {displayMode === 'default' ? (
        <div className="flex justify-between gap-8">
          <div className="w-2/3">
            <div className="flex justify-between items-center mb-6">
              <h1 className="text-3xl font-bold text-gray-900">Danh sách bài viết</h1>
              {isAuthenticated && user?.role === 'Admin' && (
                <Link 
                  to="/create-post" 
                  className={styles.createButton || 'bg-blue-500 text-white px-4 py-2 rounded-lg hover:bg-blue-600'}
                >
                  <svg className="w-5 h-5 inline mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 4v16m8-8H4" />
                  </svg>
                  Tạo bài viết mới
                </Link>
              )}
            </div>

            <div className="space-y-6">
              {visibleBlogs.map((blog) => (
                <div 
                  key={blog.blogID} 
                  className={styles.blogCard || 'bg-white rounded-lg shadow-md border overflow-hidden'}
                  ref={(el) => { blogRefs.current.set(blog.blogID, el); }}
                >
                  <div className="flex" onClick={() => navigate(`/blogs/${blog.blogID}`)}>
                    {blog.image && (
                      <div className={styles.blogImageContainer || 'w-64 h-48 flex-shrink-0'}>
                        <BlogImage 
                          src={blog.image}
                          alt={blog.title}
                          className={styles.blogImage || 'w-full h-full object-cover'}
                        />
                      </div>
                    )}
                    <div className={styles.blogContentDefault || 'flex-1 p-6'}>
                      <div className={styles.blogMetaDefault || 'flex items-center text-sm text-gray-600 mb-2'}>
                        <span className={styles.blogCategory || 'font-semibold uppercase mr-2'}>QUAN ĐIỂM - TRANH LUẬN</span>
                        <span className={styles.blogReadTime || 'mr-auto'}> • {getPostReadTime(blog.content)}</span>
                        <span className={styles.blogBookmark || 'text-gray-400'}><i className="far fa-bookmark"></i></span>
                      </div>
                      <h2 className={styles.blogTitleDefault || 'text-xl font-bold text-gray-900 mb-2'}>
                        {blog.title}
                      </h2>
                      <p
                        className={
                          expandedBlogs[blog.blogID]
                            ? 'text-gray-600 mb-4'
                            : styles.blogExcerptDefault || 'text-gray-600 mb-4'
                        }
                      >
                        {expandedBlogs[blog.blogID]
                          ? <>
                              {blog.content}
                              <button
                                className="ml-2 text-blue-500 hover:underline text-sm"
                                onClick={e => {
                                  e.stopPropagation();
                                  setExpandedBlogs(prev => ({ ...prev, [blog.blogID]: false }));
                                }}
                              >
                                Thu gọn
                              </button>
                            </>
                          : blog.content.length > 100
                            ? <>
                                {`${blog.content.substring(0, 100)}...`}
                                <button
                                  className="ml-2 text-blue-500 hover:underline text-sm"
                                  onClick={e => {
                                    e.stopPropagation();
                                    setExpandedBlogs(prev => ({ ...prev, [blog.blogID]: true }));
                                  }}
                                >
                                  Xem thêm
                                </button>
                              </>
                            : blog.content}
                      </p>
                      <div className={styles.blogAuthorStats || 'flex items-center justify-between mt-auto'}>
                        <div className={styles.blogAuthorInfoDefault || 'flex items-center'}>
                          <div className={styles.blogAuthorAvatarDefault || 'w-8 h-8 rounded-full overflow-hidden mr-3'}>
                            <img 
                              src={blog.account?.image || '/public/images/logo.png'} 
                              alt={blog.account?.name || ''} 
                              className="w-full h-full object-cover"
                            />
                          </div>
                          <span className={styles.blogAuthorNameDefault || 'font-semibold text-gray-900'}>
                            {blog.account?.name || 'Ẩn danh'}
                          </span>
                          {user?.role === 'Admin' && <i className="fas fa-check-circle text-blue-500 ml-1"></i>}
                          <span className={styles.blogDateDefault || 'text-gray-500 text-sm ml-2'}>
                            • {getRelativeTime(blog.createdDate, blog.createdTime)}
                          </span>
                        </div>
                        <div className={styles.blogStatsDefault || 'flex items-center gap-4 text-gray-500'}>
                          <span className={styles.blogLikesDefault || 'flex items-center gap-1'}>
                            <i className="fas fa-caret-up"></i> 3
                          </span>
                          <span 
                            className={styles.blogCommentsDefault || 'flex items-center gap-1 cursor-pointer'}
                            onClick={(e) => { 
                              e.stopPropagation(); 
                              setShowBlogFeedbacks(prev => ({ ...prev, [blog.blogID]: false }));
                              loadComments(blog.blogID);
                              setShowComments(prev => ({ ...prev, [blog.blogID]: !prev[blog.blogID] })); 
                            }}
                          >
                            <i className="fas fa-comment-dots"></i> 
                            {blogComments[blog.blogID] ? blogComments[blog.blogID].length : '?'}
                            {commentLoading[blog.blogID] && <span className="ml-1">🔄</span>}
                          </span>
                        </div>
                      </div>
                    </div>
                  </div>
                  
                  {isAuthenticated && user?.role === 'Admin' && (
                    <div className="flex space-x-2 mt-3 px-4 pb-4">
                      <Link
                        to={`/edit-blog/${blog.blogID}`}
                        state={blog}
                        className="text-blue-500 hover:text-blue-600 text-sm"
                      >
                        Chỉnh sửa
                      </Link>
                      <button 
                        onClick={(e) => { 
                          e.stopPropagation(); 
                          handleDelete(blog.blogID); 
                        }} 
                        className="text-red-500 hover:text-red-600 text-sm"
                      >
                        Xóa
                      </button>
                    </div>
                  )}

                  {showComments[blog.blogID] && !showBlogFeedbacks[blog.blogID] && (
                    <div className={styles.commentSection || 'bg-gray-50 p-4 border-t'}>
                      <h3 className="text-lg font-semibold mb-3">
                        Bình luận 
                        {commentLoading[blog.blogID] && <span className="ml-2 text-sm text-blue-500">Đang tải...</span>}
                      </h3>
                      
                      {commentLoading[blog.blogID] ? (
                        <div className="flex justify-center py-4">
                          <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-500"></div>
                        </div>
                      ) : (
                        <>
                          {blogComments[blog.blogID] && blogComments[blog.blogID].length > 0 ? (
                            <div className="space-y-3 mb-4">
                              {blogComments[blog.blogID].map((comment, index) => (
                                <div key={`${blog.blogID}-${index}`} className="bg-white p-3 rounded-lg">
                                  <div className="flex items-center mb-2">
                                    <img 
                                      src={comment.commenterImage || '/public/images/logo.png'} 
                                      alt={comment.commenterName || ''} 
                                      className="w-8 h-8 rounded-full mr-2" 
                                    />
                                    <span className="font-semibold text-gray-900">{comment.commenterName || 'Ẩn danh'}</span>
                                    <span className="text-sm text-gray-500 ml-auto">
                                      {comment.createdDate} {comment.createdTime}
                                    </span>
                                  </div>
                                  {/* Inline edit: nếu đang sửa thì hiện textarea, không thì hiện nội dung */}
                                  
                                  {/* Nút Sửa/Xóa chỉ hiện nếu là của mình */}
                                  {(comment.account?.id === user?.id || comment.accountId === user?.id) && (
                                    <>
                                      <button className="ml-2 text-xs text-blue-500 hover:underline" onClick={() => setEditingComment({ blogId: blog.blogID, commentId: comment.commentId, content: comment.content })}>Sửa</button>
                                      <button
                                        className="ml-2 text-xs text-red-500 hover:underline"
                                        onClick={() => setDeleteConfirm({ blogId: blog.blogID, commentId: comment.commentId })}
                                      >Xóa</button>
                                    </>
                                  )}
                                  {/* Nút phản hồi cho người khác */}
                                  {!(comment.account?.id === user?.id || comment.accountId === user?.id) && (
                                    <>
                                      <button
                                        className="ml-2 text-xs text-green-500 hover:underline"
                                        onClick={() => handleOpenFeedback(comment.commentId)}
                                      >
                                        Phản hồi
                                      </button>
                                      {feedbackingCommentId === comment.commentId && (
                                        <form
                                          className="flex gap-2 mt-2"
                                          onSubmit={e => {
                                            e.preventDefault();
                                            handleSendFeedback(comment.commentId);
                                          }}
                                        >
                                          <input
                                            className="flex-1 p-1 border rounded"
                                            type="text"
                                            placeholder="Nhập feedback..."
                                            value={feedbackContent}
                                            onChange={e => setFeedbackContent(e.target.value)}
                                          />
                                          <button
                                            type="submit"
                                            className="px-2 py-1 bg-green-500 text-white rounded disabled:opacity-60"
                                            disabled={!feedbackContent.trim()}
                                          >Gửi</button>
                                          <button
                                            type="button"
                                            className="px-2 py-1 bg-gray-300 rounded"
                                            onClick={() => setFeedbackingCommentId(null)}
                                          >Hủy</button>
                                        </form>
                                      )}
                                    </>
                                  )}
                                </div>
                              ))}
                            </div>
                          ) : (
                            <p className="text-gray-600 mb-4">Chưa có bình luận nào. Hãy là người đầu tiên bình luận!</p>
                          )}
                          
                          {/* Ô nhập comment mới */}
                          {isAuthenticated && (
                            <div className="mb-4">
                              <textarea
                                className="w-full p-2 border rounded mb-2"
                                placeholder="Nhập bình luận của bạn..."
                                value={newCommentContent[blog.blogID] || ''}
                                onChange={e => setNewCommentContent(prev => ({ ...prev, [blog.blogID]: e.target.value }))}
                                rows={2}
                                disabled={commentSubmitting[blog.blogID]}
                              />
                              <button
                                className="px-3 py-1 bg-blue-500 text-white rounded disabled:opacity-60"
                                disabled={commentSubmitting[blog.blogID] || !(newCommentContent[blog.blogID]?.trim())}
                                onClick={() => handleCommentSubmit(blog.blogID)}
                              >Gửi</button>
                            </div>
                          )}
                          
                          {/* Xóa form sửa ở dưới cùng, chỉ để inline */}
                        </>
                      )}
                    </div>
                  )}
                </div>
              ))}
            </div>
          </div>

          <div className="w-1/3">
            <div className={styles.searchContainer || 'bg-white rounded-lg shadow-md p-6 sticky top-24'}>
              <h2 className={styles.searchTitle || 'text-xl font-bold text-gray-900 mb-4'}>
                Tìm kiếm bài viết
              </h2>
              <input
                type="text"
                placeholder="Nhập từ khóa tìm kiếm..."
                className={styles.searchInput || 'w-full p-3 border border-gray-300 rounded-lg'}
              />
              <div className="mt-6">
                <h3 className="font-semibold text-gray-900 mb-3">Chủ đề phổ biến</h3>
                <div className="flex flex-wrap gap-2">
                  {['Sức khỏe', 'Lối sống', 'Kinh nghiệm', 'Mẹo hay'].map((tag) => (
                    <span
                      key={tag}
                      className="px-3 py-1 bg-gray-100 text-gray-700 rounded-full text-sm hover:bg-gray-200 cursor-pointer transition-colors"
                    >
                      {tag}
                    </span>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </div>
      ) : (
        <div className={styles.memberHomeBlogList || 'flex flex-col gap-4 p-4 bg-orange-50'}>
          <div className={styles.memberHomeBlogGrid || 'flex flex-col gap-2'}>
            {visibleBlogs.map((blog) => (
              <div key={blog.blogID} className={styles.memberHomeBlogCard || 'bg-white rounded-lg border p-4 hover:shadow-md transition-shadow'}>
                <div className={styles.memberHomeBlogMetaTop || 'flex items-center justify-between mb-3'}>
                  <div className={styles.memberHomeAuthorInfo || 'flex items-center'}>
                    <div className={styles.memberHomeAuthorAvatar || 'w-10 h-10 rounded-full overflow-hidden mr-3'}>
                      <img 
                        src={blog.account?.image || '/public/images/logo.png'} 
                        alt={blog.account?.name || ''} 
                        className="w-full h-full object-cover"
                      />
                    </div>
                    <div>
                      <span className={styles.memberHomeAuthorName || 'font-semibold text-gray-900 block'}>
                        {blog.account?.name || 'Ẩn danh'}
                      </span>
                      <span className={styles.memberHomeTimeAgo || 'text-gray-500 text-sm'}>
                        {getRelativeTime(blog.createdDate, blog.createdTime)}
                      </span>
                    </div>
                  </div>
                  <span className={styles.memberHomeBookmark || 'text-gray-400 cursor-pointer hover:text-gray-600'}>
                    <i className="far fa-bookmark"></i>
                  </span>
                </div>

                <h3 
                  className={styles.memberHomeBlogTitle || 'text-lg font-bold text-gray-900 mb-2 cursor-pointer hover:text-blue-600'} 
                  onClick={() => navigate(`/blogs/${blog.blogID}`)}
                >
                  {blog.title}
                </h3>

                <p
                  className={
                    expandedBlogs[blog.blogID]
                      ? 'text-gray-600 mb-3'
                      : styles.memberHomeBlogExcerpt || 'text-gray-600 mb-3 line-clamp-3'
                  }
                >
                  {expandedBlogs[blog.blogID]
                    ? <>
                        {blog.content}
                        <button
                          className="ml-2 text-blue-500 hover:underline text-sm"
                          onClick={e => {
                            e.stopPropagation();
                            setExpandedBlogs(prev => ({ ...prev, [blog.blogID]: false }));
                          }}
                        >
                          Thu gọn
                        </button>
                      </>
                    : blog.content.length > 150 
                      ? <>
                          {`${blog.content.substring(0, 150)}...`}
                          <button
                            className="ml-2 text-blue-500 hover:underline text-sm"
                            onClick={e => {
                              e.stopPropagation();
                              setExpandedBlogs(prev => ({ ...prev, [blog.blogID]: true }));
                            }}
                          >
                            Xem thêm
                          </button>
                        </>
                    : blog.content}
                </p>

                {blog.image && (
                  <div style={{ marginTop: 10, marginBottom: 10 }}>
                    <img
                      src={blog.image}
                      alt={blog.title}
                      style={{ width: '100%', borderRadius: 12, maxHeight: 350, objectFit: 'cover' }}
                    />
                  </div>
                )}

                <div className={styles.memberHomeStats || 'text-sm text-gray-500 mb-4'}>
                  <span className={styles.memberHomeLikesComments || 'inline-block'}>
                    {`${blogLikes[blog.blogID] ?? blog.likes ?? 0} lượt thích`}
                    {commentLoading[blog.blogID] && <span className="ml-1">🔄</span>}
                  </span>
                </div>

                <div className={styles.memberHomeActionsFlex || 'flex justify-around pt-3 border-t border-gray-200'}>
                  <LikeButton
                    liked={likedBlogs[blog.blogID]}
                    onClick={() => handleLike(blog.blogID)}
                  />
                  <button 
                    className={styles.actionButton || 'flex items-center gap-2 text-gray-600 hover:text-blue-600 transition-colors px-4 py-2 rounded-lg hover:bg-blue-50'}
                    onClick={(e) => { 
                      e.stopPropagation(); 
                      setShowBlogFeedbacks(prev => ({ ...prev, [blog.blogID]: false }));
                      loadComments(blog.blogID);
                      setShowComments(prev => ({ ...prev, [blog.blogID]: !prev[blog.blogID] })); 
                    }}
                  >
                    <i className="fas fa-comment"></i> Bình luận
                  </button>
                  <button
                    className={styles.actionButton || 'flex items-center gap-2 text-gray-600 hover:text-green-600 transition-colors px-4 py-2 rounded-lg hover:bg-green-50'}
                    onClick={(e) => {
                      e.stopPropagation();
                      setShowComments(prev => ({ ...prev, [blog.blogID]: false }));
                      setShowBlogFeedbacks(prev => ({ ...prev, [blog.blogID]: !prev[blog.blogID] }));
                    }}
                  >
                    <i className="fas fa-flag"></i> Phản hồi
                  </button>
                </div>
                
                {showComments[blog.blogID] && !showBlogFeedbacks[blog.blogID] && (
                  <div className={styles.commentsSection || 'mt-4 pt-4 border-t border-gray-200'}>
                    <h4 className={styles.commentsTitle || 'font-semibold text-gray-900 mb-3'}>
                      Bình luận
                      {commentLoading[blog.blogID] && <span className="ml-2 text-sm text-blue-500">Đang tải...</span>}
                    </h4>
                    
                    <div className={styles.commentList || 'mb-4'}>
                      {commentLoading[blog.blogID] ? (
                        <div className="flex justify-center py-4">
                          <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-500"></div>
                        </div>
                      ) : blogComments[blog.blogID]?.length === 0 ? (
                        <p className="text-gray-600 text-sm">Chưa có bình luận nào. Hãy là người đầu tiên!</p>
                      ) : (
                        blogComments[blog.blogID]?.map((comment, index) => {
                          const id = comment.commentId;
                          return (
                            <div key={`${blog.blogID}-${id || index}`} className={styles.commentItem || 'bg-gray-50 rounded-lg p-3 mb-2'}>
                              <div className="flex items-center mb-2">
                                <img 
                                  src={comment.commenterImage || '/public/images/logo.png'} 
                                  alt={comment.commenterName || ''} 
                                  className="w-8 h-8 rounded-full mr-2" 
                                />
                                <span className="font-semibold text-gray-900">{comment.commenterName || 'Ẩn danh'}</span>
                              </div>
                              {/* Sửa inline: nếu đang sửa comment này thì hiện textarea, không thì hiện nội dung */}
                              {editingComment && editingComment.blogId === blog.blogID && editingComment.commentId === id ? (
                                <>
                                  <textarea
                                    className="w-full p-2 border rounded mb-2"
                                    value={editingComment.content}
                                    onChange={e => setEditingComment(edit => edit ? { ...edit, content: e.target.value } : null)}
                                    rows={2}
                                    disabled={editSubmitting}
                                  />
                                  <div className="flex gap-2">
                                    <button
                                      className="px-3 py-1 bg-blue-500 text-white rounded disabled:opacity-60"
                                      disabled={editSubmitting || !editingComment.content.trim()}
                                      onClick={async () => {
                                        setEditSubmitting(true);
                                        try {
                                          if (!editingComment.commentId) {
                                            alert('Không tìm thấy ID comment để cập nhật!');
                                            setEditSubmitting(false);
                                            return;
                                          }
                                          await updateComment(editingComment.commentId, { content: editingComment.content });
                                          setBlogComments(prev => ({
                                            ...prev,
                                            [blog.blogID]: prev[blog.blogID].map(c => {
                                              const cid = (c.commentId !== undefined ? c.commentId : c.commentID);
                                              return cid === editingComment.commentId ? { ...c, content: editingComment.content } : c;
                                            })
                                          }));
                                          setEditingComment(null);
                                          toast.success('Đã cập nhật bình luận!');
                                        } catch (err) {
                                          toast.error('Cập nhật bình luận thất bại!');
                                        } finally {
                                          setEditSubmitting(false);
                                        }
                                      }}
                                    >Lưu</button>
                                    <button
                                      className="px-3 py-1 bg-gray-300 text-gray-800 rounded"
                                      onClick={() => setEditingComment(null)}
                                    >Hủy</button>
                                  </div>
                                </>
                              ) : (
                                <p className="text-gray-700 mb-1">{comment.content}</p>
                              )}
                              {/* Nút Sửa/Xóa chỉ hiện nếu là của mình */}
                              {isAuthenticated && user?.id === comment.accountId && (
                                <div className="flex gap-2 mt-1">
                                  <button
                                    className="text-xs text-blue-500 hover:underline"
                                    onClick={() => setEditingComment({ blogId: blog.blogID, commentId: id, content: comment.content })}
                                  >Sửa</button>
                                  <button
                                    className="text-xs text-red-500 hover:underline"
                                    onClick={() => setDeleteConfirm({ blogId: blog.blogID, commentId: id })}
                                  >Xóa</button>
                                </div>
                              )}
                              {/* Nút phản hồi cho người khác */}
                              {!(isAuthenticated && user?.id === comment.accountId) && (
                                <>
                                  <button
                                    className="ml-2 text-xs text-green-500 hover:underline"
                                    onClick={() => handleOpenFeedback(id)}
                                  >
                                    Phản hồi
                                  </button>
                                  {(feedbackingCommentId === id) && (
                                    <form
                                      className="flex gap-2 mt-2"
                                      onSubmit={e => {
                                        e.preventDefault();
                                        handleSendFeedback(id);
                                      }}
                                    >
                                      <input
                                        className="flex-1 p-1 border rounded"
                                        type="text"
                                        placeholder="Nhập feedback..."
                                        value={feedbackContent}
                                        onChange={e => setFeedbackContent(e.target.value)}
                                      />
                                      <button
                                        type="submit"
                                        className="px-2 py-1 bg-green-500 text-white rounded disabled:opacity-60"
                                        disabled={!feedbackContent.trim()}
                                      >Gửi</button>
                                      <button
                                        type="button"
                                        className="px-2 py-1 bg-gray-300 rounded"
                                        onClick={() => setFeedbackingCommentId(null)}
                                      >Hủy</button>
                                    </form>
                                  )}
                                </>
                              )}
                            </div>
                          );
                        })
                      )}
                    </div>
                    
                    {/* Ô nhập comment mới */}
                    {isAuthenticated && (
                      <div className="mb-4">
                        <textarea
                          className="w-full p-2 border rounded mb-2"
                          placeholder="Nhập bình luận của bạn..."
                          value={newCommentContent[blog.blogID] || ''}
                          onChange={e => setNewCommentContent(prev => ({ ...prev, [blog.blogID]: e.target.value }))}
                          rows={2}
                          disabled={commentSubmitting[blog.blogID]}
                        />
                        <button
                          className="px-3 py-1 bg-blue-500 text-white rounded disabled:opacity-60"
                          disabled={commentSubmitting[blog.blogID] || !(newCommentContent[blog.blogID]?.trim())}
                          onClick={() => handleCommentSubmit(blog.blogID)}
                        >Gửi</button>
                      </div>
                    )}
                    
                  </div>
                )}

                {showBlogFeedbacks[blog.blogID] && !showComments[blog.blogID] && (
                  <div className="px-4 py-4 bg-blue-50 border-t mt-2 rounded">
                    <h4 className="font-semibold text-gray-900 mb-3 flex items-center">
                      <i className="fas fa-flag mr-2"></i>
                      Đánh giá bài viết
                    </h4>
                    <div className="mb-4">
                      <FeedbackForm
                        onSubmit={(content, rating) => handleCreateBlogFeedback(blog.blogID, content, rating)}
                        placeholder="Chia sẻ suy nghĩ của bạn về bài viết này..."
                        type="blog"
                        buttonText="Gửi đánh giá"
                      />
                    </div>
                    {feedbackLoading[blog.blogID] ? (
                      <div className="text-center py-4">
                        <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-500 mx-auto"></div>
                        <p className="text-sm text-gray-600 mt-2">Đang tải đánh giá...</p>
                      </div>
                    ) : (
                      <FeedbackList 
                        feedbacks={blogFeedbacks[blog.blogID] || []} 
                        showActions={user?.role === 'Admin'} 
                      />
                    )}
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>
      )}
      {deleteConfirm && (
        <div className={styles.modalOverlay}>
          <div className={styles.modalCard}>
            <div className={styles.modalTitle}>Bạn có chắc chắn muốn xóa bình luận này?</div>
            <div className={styles.modalActions}>
              <button
                className={styles.modalButtonDanger}
                onClick={async () => {
                  try {
                    await deleteComment(deleteConfirm.commentId);
                    setBlogComments(prev => ({
                      ...prev,
                      [deleteConfirm.blogId]: prev[deleteConfirm.blogId].filter(c => c.commentId !== deleteConfirm.commentId)
                    }));
                    toast.success('Đã xóa bình luận!');
                  } catch {
                    toast.error('Xóa bình luận thất bại!');
                  }
                  setDeleteConfirm(null);
                }}
              >Xóa</button>
              <button className={styles.modalButton} onClick={() => setDeleteConfirm(null)}>Hủy</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default BlogList;