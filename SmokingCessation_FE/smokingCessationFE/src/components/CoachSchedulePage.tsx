import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import apiClient from '../api/apiClient';
import endpoints from '../api/endpoints';
import styles from './CoachSchedulePage.module.css';
import { toast } from 'react-toastify';
import ReactModal from 'react-modal';

interface ConsultationSlot {
  id: number;
  startTime: string;
  endTime: string;
  booked: boolean;
  coach: {
    coachId: number;
    specialty: string;
    experience: string;
    account: {
      id: number;
      name: string;
      email: string;
      image: string | null;
    };
  };
}

interface CoachProfile {
  coachId: number;
  specialty: string;
  experience: string;
  account: {
    id: number;
    name: string;
    email: string;
    image: string | null;
    role: string;
    age: number;
    gender: string;
    status: string;
  };
}

const CoachSchedulePage: React.FC = () => {
  const navigate = useNavigate();
  const { coachId } = useParams<{ coachId: string }>();
  const { isAuthenticated } = useAuth();
  const [slots, setSlots] = useState<ConsultationSlot[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [coachInfo, setCoachInfo] = useState<CoachProfile | null>(null);
  const [bookingLoading, setBookingLoading] = useState<number | null>(null);
  const [userBookingCount, setUserBookingCount] = useState<number>(0);
  
  // Booking confirmation states
  const [selectedSlot, setSelectedSlot] = useState<ConsultationSlot | null>(null);
  const [showConfirmation, setShowConfirmation] = useState(false);
  const [bookingStep, setBookingStep] = useState<'select' | 'confirm' | 'success'>('select');

  // Week navigation
  const [currentWeekStart, setCurrentWeekStart] = useState<Date>(() => {
    const today = new Date();
    const dayOfWeek = today.getDay();
    const monday = new Date(today);
    monday.setDate(today.getDate() - (dayOfWeek === 0 ? 6 : dayOfWeek - 1));
    monday.setHours(0, 0, 0, 0);
    return monday;
  });

  // Time slots for table rows
  const timeSlots = ['08:00', '09:00', '10:00', '11:00', '13:00', '14:00', '15:00', '16:00'];

  const [showSmokingLogModal, setShowSmokingLogModal] = useState(false);

  useEffect(() => {
    if (coachId && !isNaN(parseInt(coachId))) {
      fetchCoachInfo();
      fetchSchedule();
      fetchUserBookingCount();
    } else {
      setError('Coach ID không hợp lệ');
      setLoading(false);
    }
  }, [coachId, currentWeekStart]);

  const fetchCoachInfo = async () => {
    try {
      const response = await apiClient.get(`/${endpoints.getAllCoachProfiles}`);
      
      if (Array.isArray(response.data)) {
        const coachIdNum = parseInt(coachId!);
        const coach = response.data.find((c: CoachProfile) => c.coachId === coachIdNum);

        if (coach) {
          setCoachInfo(coach);
        } else {
          setError(`Không tìm thấy coach với ID ${coachId}`);
        }
      } else {
        setError('Không có dữ liệu coach');
      }
    } catch (err: any) {
      setError('Không thể tải thông tin coach');
    } finally {
      setLoading(false);
    }
  };

  const fetchSchedule = async () => {
    try {
      const response = await apiClient.get(`/${endpoints.getUserCoachSlots}/${coachId}`);
      
      if (Array.isArray(response.data)) {
        // Filter slots for current week
        const weekStart = new Date(currentWeekStart);
        const weekEnd = new Date(weekStart);
        weekEnd.setDate(weekStart.getDate() + 7);
        
        const weekSlots = response.data.filter(slot => {
          const slotDate = new Date(slot.startTime);
          return slotDate >= weekStart && slotDate < weekEnd;
        });
        
        setSlots(weekSlots);
      } else {
        setSlots([]);
      }
    } catch (err: any) {
      if (err.response?.status === 403) {
        setError('Bạn cần đăng nhập để xem lịch trình');
      }
      setSlots([]);
    }
  };

  const fetchUserBookingCount = async () => {
    try {
      // Gọi API để lấy số lần đặt lịch của user với coach này
      const response = await apiClient.get(`/${endpoints.userBookingCount}/${coachId}`);
      setUserBookingCount(response.data.count || 0);
    } catch (err: any) {
      // Nếu không lấy được, mặc định là 0
      console.log('Could not fetch user booking count:', err);
      setUserBookingCount(0);
    }
  };

  // Week navigation functions
  const goToPreviousWeek = () => {
    const newWeekStart = new Date(currentWeekStart);
    newWeekStart.setDate(currentWeekStart.getDate() - 7);
    setCurrentWeekStart(newWeekStart);
  };

  const goToNextWeek = () => {
    const newWeekStart = new Date(currentWeekStart);
    newWeekStart.setDate(currentWeekStart.getDate() + 7);
    setCurrentWeekStart(newWeekStart);
  };

  const goToCurrentWeek = () => {
    const today = new Date();
    const dayOfWeek = today.getDay();
    const monday = new Date(today);
    monday.setDate(today.getDate() - (dayOfWeek === 0 ? 6 : dayOfWeek - 1));
    monday.setHours(0, 0, 0, 0);
    setCurrentWeekStart(monday);
  };

  // Generate week dates
  const getWeekDates = () => {
    const dates = [];
    for (let i = 0; i < 7; i++) {
      const date = new Date(currentWeekStart);
      date.setDate(currentWeekStart.getDate() + i);
      dates.push(date);
    }
    return dates;
  };

  // Find slot for specific time and date
  const findSlot = (timeSlot: string, date: Date) => {
    return slots.find(slot => {
      const slotDate = new Date(slot.startTime);
      const slotTime = slotDate.toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit', hour12: false });
      const isSameDate = slotDate.toDateString() === date.toDateString();
      return isSameDate && slotTime === timeSlot;
    });
  };

  // Check if a date is in the past
  const isDateInPast = (date: Date) => {
    const today = new Date();
    today.setHours(0, 0, 0, 0); // Set to start of today
    const checkDate = new Date(date);
    checkDate.setHours(0, 0, 0, 0); // Set to start of check date
    return checkDate < today;
  };

  // Handle slot selection (show confirmation)
  const handleSlotSelect = async (slot: ConsultationSlot, date: Date) => {
    // Check if date is in the past
    if (isDateInPast(date)) {
      return; // Don't allow selection of past dates
    }

    if (!slot.booked && isAuthenticated) {
      // Kiểm tra nếu user đã đặt lịch từ 2 lần trở lên
      if (userBookingCount >= 1) {
        const confirmMessage = `Bạn đã đặt ${userBookingCount} lịch tư vấn với coach này. Bạn có chắc là muốn đặt thêm lịch nữa không?`;
        if (!window.confirm(confirmMessage)) {
          return; // User chọn hủy
        }
      }

      // Kiểm tra smoking log trước khi cho đặt lịch
      try {
        const res = await apiClient.get('/packages/smoking-logs/list');
        if (!Array.isArray(res.data) || res.data.length === 0) {
          setShowSmokingLogModal(true);
          return;
        }
      } catch (err) {
        toast.error('Không kiểm tra được tình trạng hút thuốc. Vui lòng thử lại!');
        return;
      }

      setSelectedSlot(slot);
      setShowConfirmation(true);
      setBookingStep('confirm');
    }
  };

  const handleBookSlot = async (slotId: number) => {
    if (!isAuthenticated) {
      toast.error('Vui lòng đăng nhập để đặt lịch');
      navigate('/login');
      return;
    }

    try {
      setBookingLoading(slotId);
      const response = await apiClient.post(`/${endpoints.userBookConsultation}?slotId=${slotId}`);
      
      // Kiểm tra response một cách chính xác hơn
      const responseData = response.data;
      const responseStr = String(responseData).toLowerCase();
      
      // Kiểm tra nếu response chứa thông báo lỗi
      if (responseStr.includes('đã được đặt') || 
          responseStr.includes('đã có người đặt') || 
          responseStr.includes('không khả dụng') ||
          responseStr.includes('thất bại') ||
          responseStr.includes('lỗi')) {
        toast.error(`❌ ${responseData}`);
        return;
      }
      
      // Kiểm tra nếu response chứa thông báo thành công
      if (responseStr.includes('thành công') || response.status === 200) {
        setSlots(prevSlots => 
          prevSlots.map(slot => 
            slot.id === slotId ? { ...slot, booked: true } : slot
          )
        );
        // Cập nhật số lần đặt lịch của user
        setUserBookingCount(prev => prev + 1);
        setBookingStep('success');
        fetchSchedule();
        toast.success('✅ Đặt lịch thành công!');
      } else {
        toast.error(`❌ ${responseData}`);
      }
    } catch (error: any) {
      // Xử lý lỗi từ server
      const errorMessage = error.response?.data || error.message;
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
      setBookingLoading(null);
    }
  };

  const handleConfirmBooking = () => {
    if (selectedSlot) {
      handleBookSlot(selectedSlot.id);
    }
  };

  const handleCancelBooking = () => {
    setSelectedSlot(null);
    setShowConfirmation(false);
    setBookingStep('select');
  };

  const formatDateTime = (dateTimeStr: string) => {
    try {
      const date = new Date(dateTimeStr);
      return {
        date: date.toLocaleDateString('vi-VN', { 
          weekday: 'long', 
          day: '2-digit', 
          month: '2-digit', 
          year: 'numeric' 
        }),
        time: date.toLocaleTimeString('vi-VN', { 
          hour: '2-digit', 
          minute: '2-digit' 
        })
      };
    } catch (e) {
      return {
        date: 'Ngày không hợp lệ',
        time: 'Giờ không hợp lệ'
      };
    }
  };

  const getImageUrl = (imagePath: string | null) => {
    if (!imagePath || imagePath.startsWith('http')) return imagePath;
    const baseUrl = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080/api';
    return `${baseUrl}/${imagePath.replace(/\\/g, '/')}`;
  };

  const formatWeekRange = () => {
    const endOfWeek = new Date(currentWeekStart);
    endOfWeek.setDate(currentWeekStart.getDate() + 6);
    return `${currentWeekStart.toLocaleDateString('vi-VN', { day: '2-digit', month: '2-digit' })} - ${endOfWeek.toLocaleDateString('vi-VN', { day: '2-digit', month: '2-digit' })}`;
  };

  const dayNames = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  if (!isAuthenticated) {
    return (
      <div className={styles.pageContainer}>
        <div className={styles.errorContainer}>
          <h3>🔒 Cần đăng nhập</h3>
          <p>Vui lòng đăng nhập để xem lịch trình coach.</p>
          <button onClick={() => navigate('/login')}>Đăng nhập ngay</button>
        </div>
      </div>
    );
  }

  if (loading) {
    return (
      <div className={styles.loadingContainer}>
        <div className={styles.loadingSpinner}></div>
      </div>
    );
  }

  if (error) {
    return (
      <div className={styles.errorContainer}>
        <p className={styles.errorMessage}>{error}</p>
      </div>
    );
  }

  if (!coachInfo) return null;

  const weekDates = getWeekDates();

  // Success page
  if (bookingStep === 'success') {
    return (
      <div className={styles.successContainer}>
        <div className={styles.successCard}>
          <div className={styles.successIconContainer}>
            <div className={styles.successIcon}>✅</div>
            <div className={styles.successCheckmark}>
              <div className={styles.checkmarkCircle}></div>
              <div className={styles.checkmarkStem}></div>
              <div className={styles.checkmarkKick}></div>
            </div>
          </div>
          
          <h2 className={styles.successTitle}>Đặt lịch thành công!</h2>
          <p className={styles.successMessage}>
            Bạn đã đặt lịch tư vấn với <strong>{coachInfo.account.name}</strong> thành công.
          </p>
          
          {selectedSlot && (
            <div className={styles.successDetails}>
              <div className={styles.successDetailItem}>
                <div className={styles.detailIcon}>📅</div>
                <div className={styles.detailContent}>
                  <span className={styles.detailLabel}>Ngày tư vấn</span>
                  <span className={styles.detailValue}>{formatDateTime(selectedSlot.startTime).date}</span>
                </div>
              </div>
              
              <div className={styles.successDetailItem}>
                <div className={styles.detailIcon}>⏰</div>
                <div className={styles.detailContent}>
                  <span className={styles.detailLabel}>Thời gian</span>
                  <span className={styles.detailValue}>
                    {formatDateTime(selectedSlot.startTime).time} - {formatDateTime(selectedSlot.endTime).time}
                  </span>
                </div>
              </div>
              
              <div className={styles.successDetailItem}>
                <div className={styles.detailIcon}>👨‍⚕️</div>
                <div className={styles.detailContent}>
                  <span className={styles.detailLabel}>Coach</span>
                  <span className={styles.detailValue}>{coachInfo.account.name}</span>
                </div>
              </div>
            </div>
          )}
          
          <div className={styles.successNote}>
            <div className={styles.noteIcon}>💡</div>
            <p>Thông tin chi tiết về buổi tư vấn sẽ được gửi qua email của bạn. Vui lòng kiểm tra hộp thư!</p>
          </div>
          
          <div className={styles.successButtons}>
            <button 
              onClick={() => {
                setBookingStep('select');
                setSelectedSlot(null);
                setShowConfirmation(false);
              }}
              className={styles.secondaryButton}
            >
              <span>📅</span>
              Đặt lịch khác
            </button>
            <button 
              onClick={() => navigate('/consultation')}
              className={styles.primaryButton}
            >
              <span>👥</span>
              Danh sách coach
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <>
      {/* Modal cảnh báo chưa có smoking log */}
      <ReactModal
        isOpen={showSmokingLogModal}
        onRequestClose={() => setShowSmokingLogModal(false)}
        ariaHideApp={false}
        style={{
          overlay: { backgroundColor: 'rgba(0,0,0,0.2)' },
          content: {
            top: '100px',
            left: '50%',
            right: 'auto',
            bottom: 'auto',
            transform: 'translateX(-50%)',
            maxWidth: 420,
            borderRadius: 16,
            padding: 0,
            border: 'none',
            boxShadow: '0 2px 16px rgba(0,0,0,0.12)'
          }
        }}
      >
        <div style={{ padding: 28, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 16 }}>
          <div style={{ fontSize: 38, color: '#e53935', marginBottom: 8 }}>⚠️</div>
          <h3 style={{ color: '#2580e6', fontWeight: 700, fontSize: 20, textAlign: 'center', marginBottom: 8 }}>Bạn chưa ghi nhận tình trạng hút thuốc</h3>
          <p style={{ textAlign: 'center', color: '#444', fontSize: 16, marginBottom: 0 }}>
            Vui lòng ghi nhận tình trạng hút thuốc để cá nhân hóa cho việc tư vấn của bạn.
          </p>
          <div style={{ display: 'flex', gap: 16, marginTop: 18, width: '100%', justifyContent: 'center' }}>
            <button onClick={() => setShowSmokingLogModal(false)} style={{ flex: 1, padding: '10px 0', borderRadius: 8, border: '1px solid #ccc', background: '#f3f4f6', color: '#222', fontWeight: 500, fontSize: 16, cursor: 'pointer' }}>Hủy</button>
            <button onClick={() => { setShowSmokingLogModal(false); navigate('/smoking-status'); }} style={{ flex: 1, padding: '10px 0', borderRadius: 8, border: 'none', background: '#2580e6', color: '#fff', fontWeight: 600, fontSize: 16, cursor: 'pointer' }}>Ghi nhận tình trạng hút thuốc</button>
          </div>
        </div>
      </ReactModal>
      <div className={styles.pageContainer}>
        {/* Coach Info */}
        <div className={styles.leftColumn}>
          <div className={styles.coachInfoCard}>
            <div className={styles.coachAvatar}>
              {coachInfo.account.image ? (
                <img src={getImageUrl(coachInfo.account.image) || undefined} alt={coachInfo.account.name} />
              ) : (
                <span>{coachInfo.account.name.charAt(0).toUpperCase()}</span>
              )}
            </div>
            <h2 className={styles.coachName}>{coachInfo.account.name}</h2>
            <p className={styles.coachSpecialty}>{coachInfo.specialty}</p>
            <p className={styles.coachExperience}>{coachInfo.experience}</p>
            
            <div className={styles.divider}></div>
            
            <div className={styles.statsContainer}>
              <div className={styles.statItem}>
                <span className={styles.statLabel}>Đánh giá:</span>
                <span className={`${styles.statValue} ${styles.rating}`}>⭐ 4.8/5</span>
              </div>
              <div className={styles.statItem}>
                <span className={styles.statLabel}>Tư vấn:</span>
                <span className={styles.statValue}>150+</span>
              </div>

            </div>
          </div>
        </div>

        {/* Schedule Table */}
        <div className={styles.rightColumn}>
          <div className={styles.scheduleContainer}>
            {/* Week Navigation */}
            <div className={styles.weekNav}>
              <h3>Lịch trình tuần: {formatWeekRange()}</h3>
              <div className={styles.navButtons}>
                <button onClick={goToPreviousWeek} className={styles.navButton}>⬅️ Tuần trước</button>
                <button onClick={goToCurrentWeek} className={styles.navButton}>📅 Hôm nay</button>
                <button onClick={goToNextWeek} className={styles.navButton}>Tuần sau ➡️</button>
              </div>
            </div>

            {/* Schedule Table */}
            <div className={styles.tableContainer}>
              <table className={styles.scheduleTable}>
                <thead>
                  <tr>
                    <th className={styles.timeHeader}>Giờ</th>
                    {weekDates.map((date, index) => (
                      <th key={date.toISOString()} className={styles.dayHeader}>
                        <div className={styles.dayHeaderContent}>
                          <div className={styles.dayName}>{dayNames[index]}</div>
                          <div className={styles.dayDate}>{date.getDate()}/{date.getMonth() + 1}</div>
                        </div>
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {timeSlots.map(timeSlot => (
                    <tr key={timeSlot}>
                      <td className={styles.timeCell}>{timeSlot}</td>
                      {weekDates.map(date => {
                        const slot = findSlot(timeSlot, date);
                        const isPastDate = isDateInPast(date);

                        // 1. Ẩn slot đã qua ngày (dù đã đặt hay chưa)
                        if (isPastDate) {
                          return <td key={`${timeSlot}-${date.toISOString()}`}></td>;
                        }

                        // 2. Slot đã đặt (còn trong tương lai)
                        if (slot && slot.booked) {
                          return (
                            <td key={`${timeSlot}-${date.toISOString()}`} className={styles.slotCell}>
                              <div style={{ color: '#e11d48', fontWeight: 700 }}>Đã đặt</div>
                            </td>
                          );
                        }

                        // 3. Slot trống (còn trong tương lai)
                        if (slot && !slot.booked) {
                          return (
                            <td key={`${timeSlot}-${date.toISOString()}`} className={styles.slotCell}>
                              <button
                                className={styles.bookButton}
                                onClick={() => handleSlotSelect(slot, date)}
                                disabled={bookingLoading === slot.id}
                              >
                                {bookingLoading === slot.id ? 'Đang đặt...' : 'Đặt lịch'}
                              </button>
                            </td>
                          );
                        }

                        // 4. Không có slot nào (giữ nguyên)
                        return <td key={`${timeSlot}-${date.toISOString()}`}></td>;
                      })}
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>

          {/* Help & Support Section */}
          <div className={styles.helpSection}>
            <div className={styles.helpCard}>
              <h3>🆘 Cần hỗ trợ?</h3>
              <p>Nếu bạn gặp khó khăn trong việc đặt lịch, vui lòng liên hệ:</p>
              <ul>
                <li>📞 Hotline: 1900-xxxx</li>
                <li>📧 Email: support@smokingcessation.com</li>
                <li>💬 Chat trực tuyến: 8h-22h hằng ngày</li>
              </ul>
            </div>
            
            <div className={styles.benefitsCard}>
              <h3>✅ Lợi ích tư vấn</h3>
              <ul>
                <li>✓ Kế hoạch cai thuốc cá nhân hóa</li>
                <li>✓ Hỗ trợ tâm lý chuyên nghiệp</li>
                <li>✓ Theo dõi tiến độ định kỳ</li>
                <li>✓ Tư vấn dinh dưỡng và sức khỏe</li>
              </ul>
            </div>
          </div>

          {/* Cancellation Policy */}
          <div className={styles.policySection}>
            <h3>📋 Chính sách hủy lịch</h3>
            <div className={styles.policyGrid}>
              <div className={styles.policyItem}>
                <h4>🕐 Hủy trước 24h</h4>
                <p>Hủy lịch dễ dàng mà không mất phí. Không ảnh hưởng đến tài khoản.</p>
              </div>
              <div className={styles.policyItem}>
                <h4>🕕 Hủy trước 2h</h4>
                <p>Có thể hủy lịch nhưng sẽ được ghi nhận để tránh lạm dụng.</p>
              </div>
              <div className={styles.policyItem}>
                <h4>⏰ Hủy trong 2h</h4>
                <p>Nên liên hệ trực tiếp với coach để thông báo lý do hủy đột xuất.</p>
              </div>
            </div>
          </div>

          {/* FAQ Section */}
          <div className={styles.faqSection}>
            <h3>❓ Câu hỏi thường gặp</h3>
            <details className={styles.faqItem}>
              <summary>Tôi có thể thay đổi lịch đã đặt không?</summary>
              <p>Có, bạn có thể thay đổi lịch hẹn trước 24 giờ mà không mất phí. Liên hệ hotline hoặc coach trực tiếp để đổi lịch.</p>
            </details>
            <details className={styles.faqItem}>
              <summary>Buổi tư vấn diễn ra như thế nào?</summary>
              <p>Buổi tư vấn có thể diễn ra trực tiếp tại phòng khám hoặc qua video call. Coach sẽ liên hệ xác nhận hình thức tư vấn trước 1 ngày.</p>
            </details>
            <details className={styles.faqItem}>
              <summary>Tôi cần chuẩn bị gì cho buổi tư vấn?</summary>
              <p>Hãy chuẩn bị thông tin về thói quen hút thuốc, sức khỏe hiện tại và mục tiêu cai thuốc. Mang theo giấy tờ tùy thân nếu tư vấn trực tiếp.</p>
            </details>
            <details className={styles.faqItem}>
              <summary>Có được bảo mật thông tin không?</summary>
              <p>Hoàn toàn được bảo mật. Mọi thông tin tư vấn đều được mã hóa và chỉ coach phụ trách mới có quyền truy cập.</p>
            </details>
          </div>
        </div>

        {/* Booking Confirmation Modal */}
        {showConfirmation && selectedSlot && bookingStep === 'confirm' && (
          <div className={styles.modalOverlay}>
            <div className={styles.confirmationModal}>
              <h2>Xác nhận thông tin đặt lịch</h2>
              
              <div className={styles.confirmationContent}>
                <div className={styles.consultationInfo}>
                  <h3>Thông tin tư vấn</h3>
                  <div className={styles.infoGrid}>
                    <div className={styles.infoItem}>
                      <span className={styles.infoLabel}>Coach:</span>
                      <span className={styles.infoValue}>{coachInfo.account.name}</span>
                    </div>
                    <div className={styles.infoItem}>
                      <span className={styles.infoLabel}>Chuyên môn:</span>
                      <span className={styles.infoValue}>{coachInfo.specialty}</span>
                    </div>
                    <div className={styles.infoItem}>
                      <span className={styles.infoLabel}>Ngày tư vấn:</span>
                      <span className={styles.infoValue}>{formatDateTime(selectedSlot.startTime).date}</span>
                    </div>
                    <div className={styles.infoItem}>
                      <span className={styles.infoLabel}>Thời gian:</span>
                      <span className={styles.infoValue}>
                        {formatDateTime(selectedSlot.startTime).time} - {formatDateTime(selectedSlot.endTime).time}
                      </span>
                    </div>
                  </div>
                </div>

                <div className={styles.importantNotes}>
                  <h4>Lưu ý quan trọng:</h4>
                  <ul>
                    <li>• Vui lòng có mặt đúng giờ đã hẹn</li>
                    <li>• Nếu cần hủy, vui lòng thông báo trước 24 giờ</li>
                    <li>• Thông tin tư vấn sẽ được gửi qua email</li>
                    <li>• Chuẩn bị sẵn thông tin về thói quen hút thuốc</li>
                  </ul>
                </div>

                <div className={styles.confirmationButtons}>
                  <button 
                    onClick={handleCancelBooking}
                    className={styles.cancelButton}
                  >
                    Quay lại
                  </button>
                  <button 
                    onClick={handleConfirmBooking}
                    disabled={bookingLoading === selectedSlot.id}
                    className={styles.confirmButton}
                  >
                    {bookingLoading === selectedSlot.id ? 'Đang đặt...' : 'Xác nhận đặt lịch'}
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </>
  );
};

export default CoachSchedulePage;