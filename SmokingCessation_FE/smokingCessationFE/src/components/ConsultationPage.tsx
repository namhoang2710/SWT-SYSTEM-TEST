import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import apiClient from '../api/apiClient';
import endpoints from '../api/endpoints';
// ✨ THÊM: Import feedback services và components
import { createCoachFeedback, getCoachFeedbacks } from '../api/services/feedbackService';
import { FeedbackForm, FeedbackList, StarRating } from '../components/FeedbackComponents';
import { toast } from 'react-toastify';
import { FaStar, FaComment, FaChevronDown, FaChevronUp, FaUserMd } from 'react-icons/fa';

interface CoachProfile {
  coachId: number;
  id?: number;
  specialty: string;
  experience: string;
  account: {
    id: number;
    name: string;
    email: string;
    image: string | null;
    role: string;
    status: string;
    age: number;
    gender: string;
  };
}

const ConsultationPage: React.FC = () => {
  const navigate = useNavigate();
  const { isAuthenticated } = useAuth();
  const [coaches, setCoaches] = useState<CoachProfile[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // ✨ THÊM: Feedback states
  const [showCoachFeedbacks, setShowCoachFeedbacks] = useState<Record<number, boolean>>({});
  const [coachFeedbacks, setCoachFeedbacks] = useState<Record<number, any[]>>({});
  const [feedbackLoading, setFeedbackLoading] = useState<Record<number, boolean>>({});
  const [showFeedbackForm, setShowFeedbackForm] = useState<Record<number, boolean>>({});
  const [coachAverageRatings, setCoachAverageRatings] = useState<Record<number, number>>({});

  useEffect(() => {
    fetchCoaches();
  }, []);

  const fetchCoaches = async () => {
    try {
      setLoading(true);
      setError(null);
      
      const response = await apiClient.get(`/${endpoints.getAllCoachProfiles}`);
      console.log('✅ Real API response:', response.data);
      
      if (Array.isArray(response.data)) {
        const validCoaches = response.data.filter(coach => 
          coach && 
          coach.account && 
          coach.account.name && 
          coach.coachId
        );
        
        setCoaches(validCoaches);
        console.log('✅ Valid coaches loaded:', validCoaches.length);
        
        // ✨ THÊM: Load feedback cho tất cả coaches
        validCoaches.forEach(coach => {
          loadCoachFeedbacks(coach.coachId);
        });
      } else {
        throw new Error('Invalid response format');
      }
      
    } catch (err: any) {
      console.error('❌ Error fetching coaches:', err);
      setError('Không thể tải danh sách coach');
    } finally {
      setLoading(false);
    }
  };

  // ✨ THÊM: Load feedbacks for specific coach
  const loadCoachFeedbacks = async (coachId: number) => {
    setFeedbackLoading(prev => ({ ...prev, [coachId]: true }));
    try {
      const feedbacks = await getCoachFeedbacks(coachId);
      setCoachFeedbacks(prev => ({
        ...prev,
        [coachId]: feedbacks
      }));

      // Calculate average rating
      const ratings = feedbacks.filter((f: any) => f.rating).map((f: any) => f.rating);
      if (ratings.length > 0) {
        const average = ratings.reduce((sum: number, rating: number) => sum + rating, 0) / ratings.length;
        setCoachAverageRatings(prev => ({
          ...prev,
          [coachId]: average
        }));
      }
    } catch (error) {
      console.error('Error loading coach feedbacks:', error);
      setCoachFeedbacks(prev => ({
        ...prev,
        [coachId]: []
      }));
    } finally {
      setFeedbackLoading(prev => ({ ...prev, [coachId]: false }));
    }
  };

  // ✨ THÊM: Handle create feedback
  const handleCreateCoachFeedback = async (coachId: number, content: string, rating: number) => {
    try {
      const newFeedback = await createCoachFeedback(coachId, { content, rating });
      
      // Update feedbacks list
      setCoachFeedbacks(prev => ({
        ...prev,
        [coachId]: [newFeedback, ...(prev[coachId] || [])]
      }));

      // Recalculate average rating
      const allRatings = [rating, ...(coachFeedbacks[coachId] || []).filter(f => f.rating).map(f => f.rating)];
      const newAverage = allRatings.reduce((sum, r) => sum + r, 0) / allRatings.length;
      setCoachAverageRatings(prev => ({
        ...prev,
        [coachId]: newAverage
      }));

      setShowFeedbackForm(prev => ({ ...prev, [coachId]: false }));
      toast.success('Gửi đánh giá thành công!');
    } catch (error: any) {
      console.error('Error creating coach feedback:', error);
      throw error; // Let FeedbackForm handle the error
    }
  };

  // ✨ THÊM: Toggle feedback section
  const toggleCoachFeedbacks = (coachId: number) => {
    setShowCoachFeedbacks(prev => ({
      ...prev,
      [coachId]: !prev[coachId]
    }));
  };

  // ✨ THÊM: Toggle feedback form
  const toggleFeedbackForm = (coachId: number) => {
    setShowFeedbackForm(prev => ({
      ...prev,
      [coachId]: !prev[coachId]
    }));
  };

  const handleCoachClick = (coachId: number) => {
    console.log('🔗 Navigating to coach schedule with coachId:', coachId);
    if (!coachId) {
      console.error('Invalid coach ID');
      return;
    }
    navigate(`/consultation/schedule/${coachId}`);
  };

  const getImageUrl = (imagePath: string | null) => {
    if (!imagePath || imagePath === 'string') return '/images/default-avatar.png';
    if (imagePath.startsWith('http')) return imagePath;
    const baseUrl = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080/api';
    return `${baseUrl}/${imagePath.replace(/\\/g, '/')}`;
  };

  const renderCoachCard = (coach: CoachProfile, index: number) => {
    const feedbacks = coachFeedbacks[coach.coachId] || [];
    const averageRating = coachAverageRatings[coach.coachId] || 0;
    const feedbackCount = feedbacks.length;

    console.log(`Coach ${index}:`, {
      name: coach.account.name,
      coachId: coach.coachId,
      id: coach.id
    });

    return (
      <div 
        key={`coach-${coach.coachId}`}
        style={{ 
          border: '1px solid #e5e7eb',
          borderRadius: '16px', 
          padding: '24px',
          backgroundColor: '#ffffff',
          boxShadow: '0 4px 6px rgba(0, 0, 0, 0.05)',
          transition: 'all 0.3s ease',
          position: 'relative'
        }}
      >
        {/* Coach Header */}
        <div style={{ marginBottom: '16px' }}>
          <div 
            onClick={() => handleCoachClick(coach.coachId)}
            style={{ 
              display: 'flex', 
              alignItems: 'center', 
              gap: '16px', 
              marginBottom: '12px',
              cursor: 'pointer' 
            }}
          >
            <img
              src={getImageUrl(coach.account.image)}
              alt={coach.account.name}
              style={{
                width: '80px',
                height: '80px',
                borderRadius: '50%',
                objectFit: 'cover',
                border: '3px solid #e5e7eb'
              }}
            />
            <div style={{ flex: 1 }}>
              <h3 style={{ 
                margin: '0 0 8px 0', 
                fontSize: '1.25rem', 
                fontWeight: 'bold', 
                color: '#1f2937' 
              }}>
                {coach.account.name}
              </h3>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '4px' }}>
                <FaUserMd size={14} color="#6b7280" />
                <span style={{ fontSize: '14px', color: '#6b7280' }}>
                  {coach.specialty}
                </span>
              </div>
              <p style={{ 
                margin: 0, 
                fontSize: '14px', 
                color: '#6b7280' 
              }}>
                {coach.experience}
              </p>
            </div>
          </div>

          {/* ✨ THÊM: Coach Rating Display */}
          {averageRating > 0 && (
            <div style={{ 
              display: 'flex', 
              alignItems: 'center', 
              gap: '8px',
              padding: '8px 12px',
              backgroundColor: '#f9fafb',
              borderRadius: '8px',
              border: '1px solid #e5e7eb',
              marginBottom: '12px'
            }}>
              <StarRating 
                rating={Math.round(averageRating)} 
                onRatingChange={() => {}} 
                readonly 
                size="small"
              />
              <span style={{ fontSize: '14px', fontWeight: '500', color: '#374151' }}>
                {averageRating.toFixed(1)}
              </span>
              <span style={{ fontSize: '12px', color: '#6b7280' }}>
                ({feedbackCount} đánh giá)
              </span>
            </div>
          )}

          <div style={{ 
            display: 'flex', 
            justifyContent: 'space-between', 
            alignItems: 'center',
            padding: '12px',
            backgroundColor: '#f8fafc',
            borderRadius: '8px',
            marginBottom: '16px'
          }}>
            <div style={{ fontSize: '14px', color: '#6b7280' }}>
              <strong>Tuổi:</strong> {coach.account.age} • <strong>Giới tính:</strong> {coach.account.gender}
            </div>
            <div style={{
              padding: '4px 8px',
              borderRadius: '4px',
              fontSize: '12px',
              fontWeight: '500',
              backgroundColor: coach.account.status === 'Active' ? '#d1fae5' : '#fee2e2',
              color: coach.account.status === 'Active' ? '#065f46' : '#991b1b'
            }}>
              {coach.account.status}
            </div>
          </div>
        </div>

        {/* ✨ THÊM: Feedback Section */}
        <div style={{
          borderTop: '1px solid #e5e7eb',
          paddingTop: '16px'
        }}>
          {/* Feedback Controls */}
          <div style={{ 
            display: 'flex', 
            justifyContent: 'space-between', 
            alignItems: 'center', 
            marginBottom: '12px' 
          }}>
            <h4 style={{ 
              margin: 0, 
              fontSize: '16px', 
              fontWeight: '600', 
              color: '#374151' 
            }}>
              Đánh giá từ học viên
            </h4>
            
            <div style={{ display: 'flex', gap: '8px' }}>
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  toggleCoachFeedbacks(coach.coachId);
                }}
                style={{
                  backgroundColor: 'transparent',
                  color: '#6b7280',
                  border: '1px solid #d1d5db',
                  borderRadius: '6px',
                  padding: '6px 12px',
                  fontSize: '12px',
                  cursor: 'pointer',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '4px'
                }}
              >
                {showCoachFeedbacks[coach.coachId] ? <FaChevronUp size={10} /> : <FaChevronDown size={10} />}
                {showCoachFeedbacks[coach.coachId] ? 'Ẩn' : 'Xem'} đánh giá
              </button>
            </div>
          </div>

          {/* ✨ THÊM: Feedback List */}
          {showCoachFeedbacks[coach.coachId] && (
            <div style={{ marginBottom: '16px' }}>
              {feedbackLoading[coach.coachId] ? (
                <div style={{ textAlign: 'center', padding: '20px', color: '#6b7280' }}>
                  <div style={{ 
                    width: '24px', 
                    height: '24px', 
                    border: '2px solid #e5e7eb',
                    borderTop: '2px solid #3b82f6',
                    borderRadius: '50%',
                    animation: 'spin 1s linear infinite',
                    margin: '0 auto 8px'
                  }}></div>
                  Đang tải đánh giá...
                </div>
              ) : (
                <FeedbackList 
                  feedbacks={feedbacks} 
                  showActions={false} // Don't allow deletion in coach view
                />
              )}
            </div>
          )}

          {/* Book Button */}
          <button
            onClick={(e) => {
              e.stopPropagation();
              handleCoachClick(coach.coachId);
            }}
            style={{
              width: '100%',
              backgroundColor: '#10b981',
              color: 'white',
              border: 'none',
              borderRadius: '8px',
              padding: '12px 16px',
              fontSize: '16px',
              fontWeight: '600',
              cursor: 'pointer',
              transition: 'background-color 0.2s',
              marginTop: '8px'
            }}
            onMouseEnter={(e) => {
              e.currentTarget.style.backgroundColor = '#059669';
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.backgroundColor = '#10b981';
            }}
          >
            📅 Đặt lịch tư vấn với coach {coach.account.name}
          </button>
        </div>

        {/* CSS for spin animation */}
        <style jsx>{`
          @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
          }
        `}</style>
      </div>
    );
  };

  if (loading) {
    return (
      <div style={{ 
        display: 'flex', 
        justifyContent: 'center', 
        alignItems: 'center', 
        height: '400px' 
      }}>
        <div style={{
          width: '40px',
          height: '40px',
          border: '4px solid #e5e7eb',
          borderTop: '4px solid #3b82f6',
          borderRadius: '50%',
          animation: 'spin 1s linear infinite'
        }}></div>
      </div>
    );
  }

  return (
    <div style={{ 
      minHeight: '100vh', 
      background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
      padding: '40px 20px'
    }}>
      <div style={{ maxWidth: '1200px', margin: '0 auto' }}>
        {/* Header */}
        <div style={{ 
          textAlign: 'center', 
          marginBottom: '40px',
          color: 'white'
        }}>
          <h1 style={{ 
            fontSize: '3rem', 
            fontWeight: 'bold', 
            margin: '0 0 16px 0',
            textShadow: '2px 2px 4px rgba(0,0,0,0.3)'
          }}>
            🩺 Chọn Coach Tư Vấn
          </h1>
          <p style={{ 
            fontSize: '1.2rem', 
            margin: 0,
            opacity: 0.9
          }}>
            Tìm coach phù hợp để hỗ trợ hành trình cai thuốc lá của bạn
          </p>
        </div>

        {/* Error State */}
        {error && (
          <div style={{
            backgroundColor: '#fef2f2',
            border: '1px solid #fecaca',
            borderRadius: '12px',
            padding: '20px',
            marginBottom: '30px',
            textAlign: 'center'
          }}>
            <h3 style={{ color: '#dc2626', marginBottom: '10px' }}>⚠️ Thông báo</h3>
            <p style={{ color: '#dc2626' }}>{error}</p>
            <button
              onClick={fetchCoaches}
              style={{
                backgroundColor: '#3b82f6',
                color: 'white',
                border: 'none',
                borderRadius: '8px',
                padding: '12px 24px',
                fontSize: '16px',
                cursor: 'pointer',
                marginTop: '10px'
              }}
            >
              🔄 Thử lại
            </button>
          </div>
        )}

        {/* Coaches Grid */}
        <div style={{ 
          backgroundColor: 'white', 
          borderRadius: '16px', 
          boxShadow: '0 10px 25px rgba(0,0,0,0.1)',
          padding: '30px'
        }}>
          <h2 style={{ 
            fontSize: '2rem', 
            fontWeight: 'bold', 
            color: '#1f2937',
            marginBottom: '30px',
            textAlign: 'center'
          }}>
            Danh sách Coach ({coaches.length} coach)
          </h2>
          
          {coaches.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '60px 20px' }}>
              <div style={{ fontSize: '4rem', marginBottom: '20px' }}>👨‍⚕️</div>
              <p style={{ fontSize: '1.2rem', color: '#6b7280', marginBottom: '20px' }}>
                Chưa có coach nào trong hệ thống
              </p>
              <button
                onClick={fetchCoaches}
                style={{
                  backgroundColor: '#3b82f6',
                  color: 'white',
                  border: 'none',
                  borderRadius: '8px',
                  padding: '12px 24px',
                  fontSize: '16px',
                  cursor: 'pointer'
                }}
              >
                🔄 Tải lại
              </button>
            </div>
          ) : (
            <div style={{ 
              display: 'grid', 
              gridTemplateColumns: 'repeat(auto-fit, minmax(400px, 1fr))',
              gap: '30px'
            }}>
              {coaches.map((coach, index) => renderCoachCard(coach, index))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default ConsultationPage;