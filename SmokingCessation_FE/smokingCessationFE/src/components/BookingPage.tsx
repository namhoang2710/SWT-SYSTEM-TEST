import React, { useEffect, useState } from 'react';
import apiClient from '../api/apiClient';
import styles from './BookingPage.module.css';
import { FaChevronDown, FaChevronRight, FaCheckCircle, FaRegClock } from 'react-icons/fa';
import { toast } from 'react-toastify';

interface Coach {
  coachId: number;
  account: {
    id: number;
    email: string;
    name: string;
    age: number;
    gender: string;
    role: string;
    status: string;
    image: string;
    consultations: number;
    healthCheckups: number;
  };
  specialty: string;
  experience: string;
}

const BookingPage: React.FC = () => {
  const [coaches, setCoaches] = useState<Coach[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [openCoach, setOpenCoach] = useState<number | null>(null);
  const [coachSchedules, setCoachSchedules] = useState<Record<number, any[]>>({});
  const [loadingSchedules, setLoadingSchedules] = useState<Record<number, boolean>>({});
  const [bookingStatus, setBookingStatus] = useState<string | null>(null);
  const [bookingLoading, setBookingLoading] = useState<Record<string, boolean>>({});
  const [hoveredSlot, setHoveredSlot] = useState<string | null>(null);

  // Tự động xóa thông báo sau 5 giây
  useEffect(() => {
    if (bookingStatus) {
      const timer = setTimeout(() => {
        setBookingStatus(null);
      }, 5000);
      return () => clearTimeout(timer);
    }
  }, [bookingStatus]);

  useEffect(() => {
    const fetchCoaches = async () => {
      try {
        const token = localStorage.getItem('token') || undefined;
        const res = await apiClient.get('/coach/profile/all', {
          headers: token ? { Authorization: `Bearer ${token}` } : {}
        });
        setCoaches(res.data);
        setError(null);
      } catch (err: any) {
        setError('Không thể tải danh sách coach.');
      } finally {
        setLoading(false);
      }
    };
    fetchCoaches();
  }, []);

  const handleToggleCoach = async (coachId: number) => {
    if (openCoach === coachId) {
      setOpenCoach(null);
      return;
    }
    setOpenCoach(coachId);
    if (!coachSchedules[coachId]) {
      setLoadingSchedules(prev => ({ ...prev, [coachId]: true }));
      try {
        const token = localStorage.getItem('token') || undefined;
        const res = await apiClient.get(`/Booking/available`, {
          params: { coachId },
          headers: token ? { Authorization: `Bearer ${token}` } : {}
        });
        setCoachSchedules(prev => ({ ...prev, [coachId]: res.data }));
      } catch (err) {
        setCoachSchedules(prev => ({ ...prev, [coachId]: [] }));
      } finally {
        setLoadingSchedules(prev => ({ ...prev, [coachId]: false }));
      }
    }
  };

  const handleBookSlot = async (coachId: number, slotId: number) => {
    setBookingLoading(prev => ({ ...prev, [`${coachId}-${slotId}`]: true }));
    setBookingStatus(null);
    try {
      const token = localStorage.getItem('token') || undefined;
      // Gọi API POST /Booking/book?slotId=xxx
      const response = await apiClient.post(`/Booking/book`, null, {
        params: { slotId },
        headers: token ? { Authorization: `Bearer ${token}` } : {}
      });
      
      // Kiểm tra response một cách chính xác
      const responseData = response.data;
      const responseStr = String(responseData).toLowerCase();
      
      // Kiểm tra nếu response chứa thông báo lỗi
      if (responseStr.includes('đã được đặt') || 
          responseStr.includes('đã có người đặt') || 
          responseStr.includes('không khả dụng') ||
          responseStr.includes('thất bại') ||
          responseStr.includes('lỗi')) {
        toast.error('❌ Slot này đã được đặt bởi người khác. Vui lòng chọn slot khác!');
        // Refresh lại danh sách slot để cập nhật trạng thái
        setLoadingSchedules(prev => ({ ...prev, [coachId]: true }));
        try {
          const res = await apiClient.get(`/Booking/available`, {
            params: { coachId },
            headers: token ? { Authorization: `Bearer ${token}` } : {}
          });
          setCoachSchedules(prev => ({ ...prev, [coachId]: res.data }));
        } catch (refreshErr) {
          console.error('Không thể refresh danh sách slot:', refreshErr);
        } finally {
          setLoadingSchedules(prev => ({ ...prev, [coachId]: false }));
        }
        return;
      }
      
      // Kiểm tra nếu response chứa thông báo thành công
      if (responseStr.includes('thành công') || response.status === 200) {
        toast.success('✅ Đặt lịch thành công!');
        // Reload lại lịch coach này
        setLoadingSchedules(prev => ({ ...prev, [coachId]: true }));
        const res = await apiClient.get(`/Booking/available`, {
          params: { coachId },
          headers: token ? { Authorization: `Bearer ${token}` } : {}
        });
        setCoachSchedules(prev => ({ ...prev, [coachId]: res.data }));
      } else {
        toast.error(`❌ ${responseData}`);
      }
    } catch (err: any) {
      // Xử lý lỗi từ server
      const errorMessage = err.response?.data || err.message;
      const errorStr = String(errorMessage).toLowerCase();
      
      if (errorStr.includes('đã được đặt') || 
          errorStr.includes('đã có người đặt') || 
          errorStr.includes('không khả dụng') ||
          errorStr.includes('slot đã được book')) {
        toast.error('❌ Slot này đã được đặt bởi người khác. Vui lòng chọn slot khác!');
      } else {
        toast.error(`❌ Đặt lịch thất bại: ${errorMessage}`);
      }
    } finally {
      setBookingLoading(prev => ({ ...prev, [`${coachId}-${slotId}`]: false }));
      setLoadingSchedules(prev => ({ ...prev, [coachId]: false }));
      
      // Refresh lại danh sách slot nếu có lỗi liên quan đến slot đã được đặt
      if (bookingStatus && bookingStatus.includes('đã được đặt')) {
        const token = localStorage.getItem('token') || undefined;
        try {
          const res = await apiClient.get(`/Booking/available`, {
            params: { coachId },
            headers: token ? { Authorization: `Bearer ${token}` } : {}
          });
          setCoachSchedules(prev => ({ ...prev, [coachId]: res.data }));
        } catch (refreshErr) {
          console.error('Không thể refresh danh sách slot:', refreshErr);
        }
      }
    }
  };

  function groupSlotsByDate(slots: any[]) {
    return slots.reduce((acc: Record<string, any[]>, slot) => {
      const date = new Date(slot.startTime).toLocaleDateString('vi-VN', { day: '2-digit', month: '2-digit', year: 'numeric' });
      if (!acc[date]) acc[date] = [];
      acc[date].push(slot);
      return acc;
    }, {});
  }

  return (
    <div style={{ maxWidth: 800, margin: '32px auto', background: '#fff', borderRadius: 12, padding: 32, boxShadow: '0 4px 24px rgba(0,0,0,0.08)' }}>
      <div style={{ textAlign: 'center', marginBottom: 28 }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 12, marginBottom: 8 }}>
          <span style={{
            fontFamily: `'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif`,
            fontSize: 34,
            fontWeight: 900,
            background: 'linear-gradient(90deg,#0a66c2,#22c55e)',
            WebkitBackgroundClip: 'text',
            WebkitTextFillColor: 'transparent',
            letterSpacing: 2
          }}>Đặt lịch tư vấn</span>
        </div>
        <div style={{ fontFamily: `'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif`, fontSize: 17, color: '#444', marginBottom: 8 }}>Chọn huấn luyện viên phù hợp để đồng hành cùng bạn trên hành trình cai thuốc</div>
        <div style={{ width: 80, height: 3, background: 'linear-gradient(90deg,#0a66c2,#22c55e)', borderRadius: 2, margin: '0 auto' }}></div>
      </div>
      {loading ? (
        <div>Đang tải danh sách coach...</div>
      ) : error ? (
        <div style={{ color: 'red' }}>{error}</div>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
          {coaches.map((coach, idx) => {
            const isOpen = openCoach === coach.coachId;
            return (
              <div key={`${coach.coachId}-${idx}`} style={{ background: '#f8fafc', borderRadius: 8, padding: 16, boxShadow: '0 2px 8px rgba(0,0,0,0.04)', width: '100%', display: 'flex', flexDirection: 'column', gap: 0 }}>
                <div style={{ display: 'flex', alignItems: 'flex-start', gap: 20 }}>
                  <img src={coach.account.image || '/public/images/logo.png'} alt={coach.account.name} style={{ width: 80, height: 80, borderRadius: '50%', objectFit: 'cover', flexShrink: 0 }} />
                  <div style={{ flex: 1, textAlign: 'left' }}>
                    <div style={{ fontWeight: 700, fontSize: 18 }}>{coach.account.name}</div>
                    <div style={{ color: '#666', fontSize: 14 }}>{coach.account.email}</div>
                    <div style={{ color: '#0a66c2', fontSize: 13, margin: '6px 0' }}>{coach.specialty}</div>
                    <div style={{ fontSize: 13, color: '#888', marginTop: 8 }}>{coach.experience}</div>
                  </div>
                  <button onClick={() => handleToggleCoach(coach.coachId)} style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 8, marginTop: 8 }} aria-label="Xem lịch trống">
                    {isOpen ? <FaChevronDown size={20} color="#0a66c2" /> : <FaChevronRight size={20} color="#0a66c2" />}
                  </button>
                </div>
                {isOpen && (
                  <div style={{ marginTop: 12, paddingLeft: 12 }}>
                    {bookingStatus && (
                      <div 
                        style={{ 
                          padding: '10px 15px',
                          borderRadius: '8px',
                          marginBottom: '12px',
                          fontWeight: '500',
                          fontSize: '14px',
                          border: bookingStatus.includes('✅') ? '1px solid #d1fae5' : '1px solid #fecaca',
                          backgroundColor: bookingStatus.includes('✅') ? '#ecfdf5' : '#fef2f2',
                          color: bookingStatus.includes('✅') ? '#065f46' : '#dc2626'
                        }}
                      >
                        {bookingStatus}
                      </div>
                    )}
                    {loadingSchedules[coach.coachId] ? (
                      <div>Đang tải lịch trống...</div>
                    ) : coachSchedules[coach.coachId] && coachSchedules[coach.coachId].length > 0 ? (
                      <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
                        {Object.entries(groupSlotsByDate(coachSchedules[coach.coachId])).map(([date, slots]: [string, any[]]) => (
                          <div key={date} style={{ background: '#f1f5f9', borderRadius: 8, padding: 16, boxShadow: '0 1px 4px rgba(0,0,0,0.04)' }}>
                            <div style={{ fontWeight: 700, fontSize: 16, color: '#0a66c2', marginBottom: 8, display: 'flex', alignItems: 'center', gap: 8 }}>
                              <span>{date}</span>
                            </div>
                            <div className={styles.slotWrapper}>
                              {slots.map((slot: any, slotIdx: number) => {
                                const slotKey = `${coach.coachId}-${slot.slotId ?? slotIdx}`;
                                if (slot.booked) {
                                  return (
                                    <div key={slotKey} className={`${styles.slotBtn} ${styles.slotBooked}`}> <FaCheckCircle color="#e11d48" size={20} /> </div>
                                  );
                                }
                                return (
                                  <button
                                    key={slotKey}
                                    className={`${styles.slotBtn} ${hoveredSlot === slotKey ? styles.slotBtnActive : ''}`}
                                    disabled={bookingLoading[slotKey]}
                                    onClick={() => handleBookSlot(coach.coachId, slot.slotId)}
                                    onMouseEnter={() => setHoveredSlot(slotKey)}
                                    onMouseLeave={() => setHoveredSlot(null)}
                                  >
                                    <span className={styles.slotIcon} style={{fontSize: 15, fontWeight: 600, color: 'inherit'}}>
                                      {`${new Date(slot.startTime).toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' })} - ${new Date(slot.endTime).toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' })}`}
                                    </span>
                                    <span className={styles.slotLabel}>
                                      {bookingLoading[slotKey]
                                        ? 'Đang đặt...'
                                        : hoveredSlot === slotKey
                                          ? 'Đặt lịch'
                                          : ''}
                            </span>
                                  </button>
                                );
                              })}
                            </div>
                          </div>
                        ))}
                      </div>
                    ) : (
                      <div>Không có lịch trống.</div>
                    )}
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
};

export default BookingPage; 