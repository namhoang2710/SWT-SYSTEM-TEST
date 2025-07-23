import React, { useEffect, useState } from 'react';
import apiClient from '../api/apiClient';
import { useAuth } from '../contexts/AuthContext';
import { createCoachFeedback } from '../api/services/feedbackService';

interface CoachAccount {
  id: number;
  email: string;
  name: string;
  yearbirth: number;
  gender: string;
  role: string;
  status: string;
  image: string | null;
  consultations: number;
  healthCheckups: number;
}

interface Coach {
  coachId: number;
  account: CoachAccount;
  specialty: string;
  experience: string;
  image: string | null;
}

interface Slot {
  id: number;
  coach: Coach;
  startTime: string;
  endTime: string;
  booked: boolean;
}

interface Booking {
  id: number;
  user: any;
  slot: Slot;
  bookingTime: string;
  googleMeetLink: string;
}

const ConsultationHistoryPage: React.FC = () => {
  const { isAuthenticated, user } = useAuth();
  const [bookings, setBookings] = useState<Booking[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [openFeedback, setOpenFeedback] = useState<{coachId: number, bookingId: number} | null>(null);
  const [feedbackContent, setFeedbackContent] = useState('');
  const [feedbackRating, setFeedbackRating] = useState(5);
  const [submittedFeedbacks, setSubmittedFeedbacks] = useState<number[]>([]);

  useEffect(() => {
    const fetchBookings = async () => {
      setLoading(true);
      setError(null);
      try {
        const res = await apiClient.get('/user/consultation/my-bookings');
        setBookings(res.data);
      } catch (err: any) {
        setError('Không thể tải lịch sử tư vấn.');
      } finally {
        setLoading(false);
      }
    };
    if (isAuthenticated) fetchBookings();
  }, [isAuthenticated]);

  return (
    <div style={{ minHeight: '100vh', background: 'linear-gradient(120deg, #e0e7ff 0%, #f8fafc 100%)', padding: '40px 0' }}>
      <div style={{ maxWidth: 900, margin: '0 auto', background: '#fff', borderRadius: 18, boxShadow: '0 4px 24px #0001', padding: 32 }}>
        <h2 style={{ fontSize: 28, fontWeight: 900, color: '#2563eb', marginBottom: 24, textAlign: 'center', letterSpacing: 1 }}>
          Lịch sử tư vấn của {user?.name || ''}
        </h2>
        {error && <div style={{ color: 'red', marginBottom: 16, textAlign: 'center', fontWeight: 600 }}>{error}</div>}
        {loading ? (
          <div style={{ textAlign: 'center', color: '#2563eb', fontWeight: 600 }}>Đang tải dữ liệu...</div>
        ) : bookings.length === 0 ? (
          <div style={{ textAlign: 'center', color: '#888', fontSize: 18 }}>Bạn chưa có lịch sử tư vấn nào.</div>
        ) : (
          <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 16, background: '#f8fafc', borderRadius: 12, overflow: 'hidden' }}>
            <thead style={{ background: '#1976d2', color: '#fff' }}>
              <tr>
                <th style={{ padding: 12 }}>Thời gian đặt</th>
                <th style={{ padding: 12 }}>Coach</th>
                <th style={{ padding: 12 }}>Chuyên môn</th>
                <th style={{ padding: 12 }}>Thời gian tư vấn</th>
                <th style={{ padding: 12 }}>Google Meet</th>
                <th style={{ padding: 12 }}>Đánh giá</th>
              </tr>
            </thead>
            <tbody>
              {bookings.map((b) => {
                const isExpired = new Date(b.slot.endTime) < new Date();
                const isFeedbacked = submittedFeedbacks.includes(b.id);
                return (
                  <tr key={b.id} style={{ background: '#fff', borderBottom: '1px solid #e5e7eb' }}>
                    <td style={{ padding: 10 }}>{new Date(b.bookingTime).toLocaleString('vi-VN')}</td>
                    <td style={{ padding: 10, display: 'flex', alignItems: 'center', gap: 8 }}>
                      <img src={b.slot.coach.account.image || '/images/default-avatar.png'} alt={b.slot.coach.account.name} style={{ width: 40, height: 40, borderRadius: '50%', objectFit: 'cover', marginRight: 8 }} />
                      <span>{b.slot.coach.account.name}</span>
                    </td>
                    <td style={{ padding: 10 }}>{b.slot.coach.specialty}</td>
                    <td style={{ padding: 10 }}>
                      {new Date(b.slot.startTime).toLocaleString('vi-VN')}<br />
                      đến<br />
                      {new Date(b.slot.endTime).toLocaleString('vi-VN')}
                    </td>
                    <td style={{ padding: 10 }}>
                      {new Date(b.slot.endTime) < new Date() ? (
                        <span style={{ color: '#888', fontWeight: 600 }}>Hết hạn</span>
                      ) : b.googleMeetLink ? (
                        <a href={b.googleMeetLink} target="_blank" rel="noopener noreferrer" style={{ color: '#2563eb', fontWeight: 600 }}>Tham gia</a>
                      ) : (
                        <span style={{ color: '#888', fontWeight: 600 }}>Không có link</span>
                      )}
                    </td>
                    <td style={{ padding: 10 }}>
                      {isFeedbacked ? (
                        <span style={{ color: '#22c55e', fontWeight: 600 }}>Đã đánh giá</span>
                      ) : (
                        <button style={{ background: '#2563eb', color: '#fff', border: 'none', borderRadius: 8, padding: '6px 18px', fontWeight: 700, cursor: 'pointer' }}
                          onClick={() => setOpenFeedback({ coachId: b.slot.coach.coachId, bookingId: b.id })}>
                          Viết đánh giá
                        </button>
                      )}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        )}
      </div>
      {/* Modal/Form đánh giá */}
      {openFeedback && (
        <div style={{ position: 'fixed', top: 0, left: 0, width: '100vw', height: '100vh', background: 'rgba(0,0,0,0.2)', zIndex: 9999, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <div style={{ background: '#fff', borderRadius: 12, padding: 32, minWidth: 350, boxShadow: '0 4px 24px #0003', position: 'relative' }}>
            <button onClick={() => setOpenFeedback(null)} style={{ position: 'absolute', top: 12, right: 12, background: 'none', border: 'none', fontSize: 22, cursor: 'pointer' }}>×</button>
            <h3 style={{ color: '#2563eb', fontWeight: 800, fontSize: 22, marginBottom: 18, textAlign: 'center' }}>Đánh giá coach</h3>
            <div style={{ marginBottom: 14 }}>
              <label style={{ fontWeight: 700 }}>Nội dung đánh giá:<br />
                <textarea value={feedbackContent} onChange={e => setFeedbackContent(e.target.value)} rows={4} style={{ width: '100%', padding: 10, borderRadius: 8, border: '1px solid #cbd5e1', marginTop: 6, fontSize: 16, minHeight: 60 }} placeholder="Nhập nhận xét..." />
              </label>
            </div>
            <div style={{ marginBottom: 18 }}>
              <label style={{ fontWeight: 700 }}>Đánh giá (1-5):<br />
                <input type="number" min={1} max={5} value={feedbackRating} onChange={e => setFeedbackRating(Number(e.target.value))} style={{ width: 60, padding: 8, borderRadius: 8, border: '1px solid #cbd5e1', marginTop: 6, fontSize: 16 }} />
              </label>
            </div>
            <button style={{ background: '#22c55e', color: '#fff', border: 'none', borderRadius: 8, padding: '12px 32px', fontWeight: 700, fontSize: 18, cursor: 'pointer', width: '100%' }}
              onClick={async () => {
                if (!feedbackContent.trim()) return alert('Vui lòng nhập nội dung đánh giá!');
                await createCoachFeedback(openFeedback.coachId, { information: feedbackContent, rating: feedbackRating });
                setSubmittedFeedbacks(f => [...f, openFeedback.bookingId]);
                setOpenFeedback(null);
                setFeedbackContent('');
                setFeedbackRating(5);
              }}>
              Gửi đánh giá
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

export default ConsultationHistoryPage; 