// Tạo file mới - Reusable feedback components
import React, { useState } from 'react';
import { FaStar, FaComment, FaPaperPlane } from 'react-icons/fa';
import { toast } from 'react-toastify';
import { useAuth } from '../contexts/AuthContext';

// StarRating Component
interface StarRatingProps {
  rating: number;
  onRatingChange: (rating: number) => void;
  readonly?: boolean;
  size?: 'small' | 'medium' | 'large';
}

export const StarRating: React.FC<StarRatingProps> = ({ rating, onRatingChange, readonly = false, size = 'medium' }) => {
  const [hoverRating, setHoverRating] = useState(0);

  const getSizeClass = () => {
    switch (size) {
      case 'small': return '14px';
      case 'large': return '24px';
      default: return '18px';
    }
  };

  return (
    <div style={{ display: 'flex', gap: '4px' }}>
      {[1, 2, 3, 4, 5].map((star) => (
        <FaStar
          key={star}
          size={getSizeClass()}
          color={star <= (hoverRating || rating) ? '#ffd700' : '#e4e4e7'}
          style={{ cursor: readonly ? 'default' : 'pointer', transition: 'color 0.2s' }}
          onMouseEnter={() => !readonly && setHoverRating(star)}
          onMouseLeave={() => !readonly && setHoverRating(0)}
          onClick={() => !readonly && onRatingChange(star)}
        />
      ))}
    </div>
  );
};

// FeedbackForm Component
interface FeedbackFormProps {
  onSubmit: (content: string, rating: number) => Promise<void>;
  placeholder?: string;
  showRating?: boolean;
  buttonText?: string;
  type: 'comment' | 'coach' | 'blog';
}

export const FeedbackForm: React.FC<FeedbackFormProps> = ({
  onSubmit, placeholder = "Nhập phản hồi của bạn...", showRating = true, buttonText = "Gửi phản hồi", type
}) => {
  const { isAuthenticated } = useAuth();
  const [content, setContent] = useState('');
  const [rating, setRating] = useState(5);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!isAuthenticated) {
      toast.error('Vui lòng đăng nhập để gửi phản hồi');
      return;
    }
    if (!content.trim()) {
      toast.error('Vui lòng nhập nội dung phản hồi');
      return;
    }

    setIsSubmitting(true);
    try {
      await onSubmit(content.trim(), rating);
      setContent('');
      setRating(5);
      toast.success('Gửi phản hồi thành công!');
    } catch (error: any) {
      toast.error(error.response?.data?.message || 'Không thể gửi phản hồi');
    } finally {
      setIsSubmitting(false);
    }
  };

  if (!isAuthenticated) {
    return (
      <div style={{ padding: '16px', backgroundColor: '#f9fafb', borderRadius: '8px', textAlign: 'center', border: '1px solid #e5e7eb' }}>
        <p style={{ color: '#6b7280', margin: 0 }}>Vui lòng đăng nhập để gửi phản hồi</p>
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit} style={{ padding: '16px', backgroundColor: '#ffffff', borderRadius: '8px', border: '1px solid #e5e7eb', boxShadow: '0 1px 3px rgba(0, 0, 0, 0.1)' }}>
      {showRating && (
        <div style={{ marginBottom: '12px' }}>
          <label style={{ display: 'block', fontSize: '14px', fontWeight: '500', color: '#374151', marginBottom: '8px' }}>
            Đánh giá:
          </label>
          <StarRating rating={rating} onRatingChange={setRating} />
        </div>
      )}
      <div style={{ marginBottom: '12px' }}>
        <textarea
          value={content}
          onChange={(e) => setContent(e.target.value)}
          placeholder={placeholder}
          rows={3}
          style={{ width: '100%', padding: '8px 12px', border: '1px solid #d1d5db', borderRadius: '6px', fontSize: '14px', resize: 'vertical', fontFamily: 'inherit', outline: 'none' }}
          disabled={isSubmitting}
        />
      </div>
      <button
        type="submit"
        disabled={isSubmitting || !content.trim()}
        style={{
          display: 'flex', alignItems: 'center', gap: '8px',
          backgroundColor: isSubmitting || !content.trim() ? '#9ca3af' : '#3b82f6',
          color: 'white', border: 'none', borderRadius: '6px', padding: '8px 16px',
          fontSize: '14px', fontWeight: '500',
          cursor: isSubmitting || !content.trim() ? 'not-allowed' : 'pointer',
          transition: 'background-color 0.2s'
        }}
      >
        <FaPaperPlane size={12} />
        {isSubmitting ? 'Đang gửi...' : buttonText}
      </button>
    </form>
  );
};

// FeedbackList Component
interface FeedbackListProps {
  feedbacks: Array<{
    feedbackId: number;
    content: string;
    rating?: number;
    createdDate: string;
    createdTime: string;
    account: { id: number; name: string; email: string; image?: string; };
  }>;
  onDelete?: (feedbackId: number) => Promise<void>;
  showActions?: boolean;
}

export const FeedbackList: React.FC<FeedbackListProps> = ({ feedbacks, onDelete, showActions = false }) => {
  const { user } = useAuth();
  const [deletingId, setDeletingId] = useState<number | null>(null);

  const handleDelete = async (feedbackId: number) => {
    if (!onDelete) return;
    if (!window.confirm('Bạn có chắc chắn muốn xóa phản hồi này?')) return;

    setDeletingId(feedbackId);
    try {
      await onDelete(feedbackId);
      toast.success('Xóa phản hồi thành công');
    } catch (error: any) {
      toast.error(error.response?.data?.message || 'Không thể xóa phản hồi');
    } finally {
      setDeletingId(null);
    }
  };

  if (feedbacks.length === 0) {
    return (
      <div style={{ padding: '32px', textAlign: 'center', color: '#6b7280', backgroundColor: '#f9fafb', borderRadius: '8px', border: '1px solid #e5e7eb' }}>
        <FaComment size={24} style={{ marginBottom: '8px', opacity: 0.5 }} />
        <p style={{ margin: 0 }}>Chưa có phản hồi nào</p>
      </div>
    );
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
      {feedbacks.map(feedback => (
        <div
          key={feedback.commentFeedbackID || feedback.feedbackId}
          style={{
            background: 'linear-gradient(135deg, #f8fafc 0%, #e0e7ff 100%)',
            borderRadius: 18,
            boxShadow: '0 4px 24px rgba(31,38,135,0.10)',
            padding: 24,
            marginBottom: 24,
            display: 'flex',
            flexDirection: 'column',
            gap: 12,
            maxWidth: 480,
            width: '100%',
            marginLeft: 'auto',
            marginRight: 'auto',
            border: '1px solid #e0e7ff',
            transition: 'box-shadow 0.2s',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: 16, marginBottom: 8 }}>
            <img
              src={feedback.image || feedback.account?.image || '/images/default-avatar.png'}
              alt={feedback.name || feedback.account?.name || 'Ẩn danh'}
              style={{ width: 56, height: 56, borderRadius: '50%', objectFit: 'cover', boxShadow: '0 2px 8px rgba(59,130,246,0.10)' }}
            />
            <div>
              <div style={{ fontWeight: 700, fontSize: 18, color: '#232946', marginBottom: 2 }}>{feedback.name || feedback.account?.name || 'Ẩn danh'}</div>
              <div style={{ fontSize: 13, color: '#6b7280' }}>{feedback.createdDate} {feedback.createdTime}</div>
            </div>
          </div>
          <div style={{ background: '#fff', borderRadius: 10, padding: 14, marginBottom: 8, boxShadow: '0 1px 4px rgba(0,0,0,0.04)' }}>
            <span style={{ color: '#6366f1', fontWeight: 600 }}>Bình luận:</span>
            <span style={{ marginLeft: 8, color: '#374151' }}>{feedback.comment?.content}</span>
          </div>
          <div style={{ background: '#f1f5f9', borderRadius: 10, padding: 14, boxShadow: '0 1px 4px rgba(0,0,0,0.03)' }}>
            <span style={{ color: '#ef4444', fontWeight: 600 }}>Feedback:</span>
            <span style={{ marginLeft: 8, color: '#232946' }}>{feedback.information}</span>
          </div>
        </div>
      ))}
    </div>
  );
};

// Hiển thị feedback cho blog
export const FeedbackBlogList = ({ feedbacks }: { feedbacks: any[] }) => (
  <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
    {feedbacks.map(feedback => (
      <div
        key={feedback.feedbackBlogID}
        style={{
          background: 'linear-gradient(135deg, #fff7ed 0%, #f3e8ff 100%)',
          borderRadius: 18,
          boxShadow: '0 4px 24px rgba(31,38,135,0.10)',
          padding: 24,
          marginBottom: 24,
          maxWidth: 540,
          width: '100%',
          marginLeft: 'auto',
          marginRight: 'auto',
          border: '1px solid #f3e8ff',
          display: 'flex',
          flexDirection: 'column',
          gap: 16,
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
          <img
            src={feedback.blog?.account?.image || '/images/default-avatar.png'}
            alt={feedback.blog?.account?.name || 'Ẩn danh'}
            style={{ width: 56, height: 56, borderRadius: '50%', objectFit: 'cover', boxShadow: '0 2px 8px rgba(59,130,246,0.10)' }}
          />
          <div>
            <div style={{ fontWeight: 700, fontSize: 18, color: '#232946', marginBottom: 2 }}>{feedback.blog?.account?.name || 'Ẩn danh'}</div>
            <div style={{ fontSize: 13, color: '#6b7280' }}>{feedback.createdDate} {feedback.createdTime}</div>
          </div>
        </div>
        <div style={{ background: '#fff', borderRadius: 10, padding: 14, marginBottom: 8, boxShadow: '0 1px 4px rgba(0,0,0,0.04)' }}>
          <div style={{ fontWeight: 600, color: '#6366f1', fontSize: 16, marginBottom: 4 }}>Tiêu đề blog: {feedback.blog?.title}</div>
          <div style={{ color: '#374151', marginBottom: 6 }}>{feedback.blog?.content}</div>
          {feedback.blog?.image && (
            <img src={feedback.blog.image} alt={feedback.blog.title} style={{ width: '100%', borderRadius: 10, marginTop: 8, maxHeight: 220, objectFit: 'cover', boxShadow: '0 1px 8px rgba(99,102,241,0.08)' }} />
          )}
        </div>
        <div style={{ background: '#f1f5f9', borderRadius: 10, padding: 18, boxShadow: '0 1px 4px rgba(0,0,0,0.03)' }}>
          <span style={{ color: '#ef4444', fontWeight: 700, fontSize: 16 }}>Feedback:</span>
          <span style={{ marginLeft: 12, color: '#232946', fontSize: 16 }}>{feedback.information}</span>
        </div>
      </div>
    ))}
  </div>
);