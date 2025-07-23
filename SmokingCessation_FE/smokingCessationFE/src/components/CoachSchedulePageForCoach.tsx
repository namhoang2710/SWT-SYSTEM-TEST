import React, { useEffect, useState, useRef } from 'react';
import apiClient from '../api/apiClient';
import endpoints from '../api/endpoints';
import styles from './CoachSchedulePage.module.css';
import bookingStyles from './BookingPage.module.css';
console.log('🔍 IMPORT CHECK - endpoints object:', endpoints);
console.log('🔍 IMPORT CHECK - deleteUnbookedSlotsForWeek:', endpoints.deleteUnbookedSlotsForWeek);

interface ConsultationSlot {
  id: number;
  startTime: string;
  endTime: string;
  booked: boolean;
  user?: {
    id: number;
    name: string;
    email: string;
    image?: string | null;
  };
}

const getMondayOfWeek = (date: Date): Date => {
  const monday = new Date(date);
  const dayOfWeek = monday.getDay(); // 0=Sunday, 1=Monday
  
  if (dayOfWeek === 0) {
    // 🔧 SỬA: Nếu là Sunday, lấy Monday tuần TRƯỚC (không phải tuần sau)
    monday.setDate(monday.getDate() - 6);
  } else {
    // Các ngày khác, lấy Monday cùng tuần
    monday.setDate(monday.getDate() - (dayOfWeek - 1));
  }
  
  monday.setHours(0, 0, 0, 0);
  return monday;
};

const CoachSchedulePageForCoach: React.FC = () => {
  const [slots, setSlots] = useState<ConsultationSlot[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [coachId, setCoachId] = useState<number | null>(null);
  const [actionLoading, setActionLoading] = useState<string | null>(null);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);
  const [popupUser, setPopupUser] = useState<null | { name: string; email: string; image?: string | null }>(null);
  const [hoveredSlotInfo, setHoveredSlotInfo] = useState<any>(null);
  const [hoveredSlotId, setHoveredSlotId] = useState<number | null>(null);
  const tooltipTimeout = useRef<NodeJS.Timeout | null>(null);

  // Week navigation
  const [currentWeekStart, setCurrentWeekStart] = useState<Date>(() => {
    const today = new Date();
    const monday = getMondayOfWeek(today);
    console.log('🔍 Initial Monday:', monday, 'Day of week:', monday.getDay());
    return monday;
  });

  // Time slots for table rows
  const timeSlots = ['08:00', '09:00', '10:00', '11:00', '13:00', '14:00', '15:00', '16:00'];

  // Thêm state coachId
  const [creating, setCreating] = useState(false);

  useEffect(() => {
    const fetchSchedule = async () => {
      setLoading(true);
      setError(null);
      try {
        // Lấy profile coach để lấy coachId
        const profileRes = await apiClient.get(`/${endpoints.getMyCoachProfile}`);

        const fetchedCoachId = profileRes.data.coachId;
        if (!fetchedCoachId) throw new Error('Không tìm thấy coachId');
        
        setCoachId(fetchedCoachId);
        

        // Lấy lịch trình bằng coachId
        const scheduleRes = await apiClient.get(`/${endpoints.getCoachSchedule}`, { params: { coachId: fetchedCoachId } });
        setSlots(scheduleRes.data || []);
      } catch (err: any) {
        setError('Không thể tải lịch trình. ' + (err?.message || ''));
      } finally {
        setLoading(false);
      }
    };
    fetchSchedule();
  }, [currentWeekStart]);

  // Function tạo lịch tuần mới
  const handleCreateWeeklySlots = async () => {
    if (!coachId) {
      setError('Không tìm thấy coachId');
      return;
    }
    
    // 🔧 THÊM: Debug để verify Monday
    console.log('🔍 currentWeekStart:', currentWeekStart);
    console.log('🔍 Day of week (1=Monday):', currentWeekStart.getDay());
    
    // 🔧 SỬA: Format date theo local timezone thay vì UTC
    const year = currentWeekStart.getFullYear();
    const month = String(currentWeekStart.getMonth() + 1).padStart(2, '0');
    const day = String(currentWeekStart.getDate()).padStart(2, '0');
    const weekStartFormatted = `${year}-${month}-${day}`;
    
    // 🔧 THÊM: Debug weekStart gửi đi
    console.log('🔍 Sending weekStart:', weekStartFormatted);
    
    setActionLoading('create');
    setError(null);
    setSuccessMessage(null);

    try {
      const response = await apiClient.post(`/${endpoints.addWeeklySlots}`, null, {
        params: { coachId , weekStart: weekStartFormatted}
      });
      
      // 🔧 SỬA: Fix template string
      setSuccessMessage(`Các ca tư vấn cho tuần ${formatWeekRange()} đã được tạo!`);
      
      // Refresh lịch trình
      const scheduleRes = await apiClient.get(`/${endpoints.getCoachSchedule}`, { params: { coachId } });
      setSlots(scheduleRes.data || []);
      
    } catch (err: any) {
      // 🔧 SỬA: Fix error handling để match backend response
      const errorMessage = err?.response?.data?.errorMessage || err?.response?.data?.message || err?.message || 'Unknown error';
      setError('Lỗi khi tạo lịch: ' + errorMessage);
    } finally {
      setActionLoading(null);
    }
  };

  // Function xóa ca trống
  const handleDeleteUnbookedSlotsForWeek = async () => {
    console.log('🔍 Full endpoints object:', endpoints);
    console.log('🔍 deleteUnbookedSlotsForWeek value:', endpoints.deleteUnbookedSlotsForWeek);
    console.log('🔍 Type of value:', typeof endpoints.deleteUnbookedSlotsForWeek);
    
    if (!coachId) {
      setError('Không tìm thấy coachId');
      return;
    }
    
    // 🔧 THÊM: Debug để verify Monday
    console.log('🔍 currentWeekStart for delete:', currentWeekStart);
    console.log('🔍 Day of week (1=Monday):', currentWeekStart.getDay());
    
    // 🔧 SỬA: Format date theo local timezone thay vì UTC
    const year = currentWeekStart.getFullYear();
    const month = String(currentWeekStart.getMonth() + 1).padStart(2, '0');
    const day = String(currentWeekStart.getDate()).padStart(2, '0');
    const weekStartFormatted = `${year}-${month}-${day}`;
    
    // 🔧 THÊM: Debug weekStart gửi đi
    console.log('🔍 Sending weekStart for delete:', weekStartFormatted);
    
    // 🔧 SỬA: Fix template string
    const isConfirmed = window.confirm(`Bạn có chắc chắn muốn xóa các ca TRỐNG trong tuần ${formatWeekRange()}? (Các ca đã đặt sẽ được giữ lại)`);
    if (!isConfirmed) return;

    setActionLoading('deleteWeek');
    setError(null);
    setSuccessMessage(null);

    try {
      const finalUrl = `/${endpoints.deleteUnbookedSlotsForWeek}`;
      console.log('🔍 Final URL:', finalUrl);
      console.log('🔍 Full request URL will be:', `${apiClient.defaults.baseURL}${finalUrl}`);
      
      const response = await apiClient.delete(`/${endpoints.deleteUnbookedSlotsForWeek}`, {
        params: { coachId, weekStart: weekStartFormatted }
      });
      
      // 🔧 SỬA: Fix success message
      setSuccessMessage(`Đã xóa các ca trống trong tuần ${formatWeekRange()}!`);
      
      // Refresh lịch trình
      const scheduleRes = await apiClient.get(`/${endpoints.getCoachSchedule}`, { params: { coachId } });
      setSlots(scheduleRes.data || []);
      
    } catch (err: any) {
      console.error('🚨 ERROR Full object:', err);
      console.error('🚨 ERROR Response:', err?.response);
      console.error('🚨 ERROR Config:', err?.config);
      
      // 🔧 SỬA: Fix error handling để match backend response
      let errorMessage = 'Unknown error';
      if (err?.response?.data?.errorMessage) {
        errorMessage = err.response.data.errorMessage;
      } else if (err?.response?.data?.message) {
        errorMessage = err.response.data.message;
      } else if (err?.message) {
        errorMessage = err.message;
      }
      
      setError('Lỗi khi xóa ca trống: ' + errorMessage);
    } finally {
      setActionLoading(null);
    }
  };

  // Week navigation functions
  const goToPreviousWeek = () => {
    const newWeekStart = new Date(currentWeekStart);
    newWeekStart.setDate(currentWeekStart.getDate() - 7);
    const mondayOfPrevWeek = getMondayOfWeek(newWeekStart);
    console.log('🔍 Previous week Monday:', mondayOfPrevWeek, 'Day of week:', mondayOfPrevWeek.getDay());
    setCurrentWeekStart(mondayOfPrevWeek);
  };

  const goToNextWeek = () => {
    const newWeekStart = new Date(currentWeekStart);
    newWeekStart.setDate(currentWeekStart.getDate() + 7);
    const mondayOfNextWeek = getMondayOfWeek(newWeekStart);
    console.log('🔍 Next week Monday:', mondayOfNextWeek, 'Day of week:', mondayOfNextWeek.getDay());
    setCurrentWeekStart(mondayOfNextWeek);
  };

  const goToCurrentWeek = () => {
    const today = new Date();
    const mondayOfCurrentWeek = getMondayOfWeek(today);
    console.log('🔍 Current week Monday:', mondayOfCurrentWeek, 'Day of week:', mondayOfCurrentWeek.getDay());
    setCurrentWeekStart(mondayOfCurrentWeek);
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
    today.setHours(0, 0, 0, 0);
    const checkDate = new Date(date);
    checkDate.setHours(0, 0, 0, 0);
    return checkDate < today;
  };

  const formatWeekRange = () => {
    const endOfWeek = new Date(currentWeekStart);
    endOfWeek.setDate(currentWeekStart.getDate() + 6);
    return `${currentWeekStart.toLocaleDateString('vi-VN', { day: '2-digit', month: '2-digit' })} - ${endOfWeek.toLocaleDateString('vi-VN', { day: '2-digit', month: '2-digit' })}`;
  };

  const dayNames = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
  const weekDates = getWeekDates();

  return (
    <div className={styles.pageContainer}>
      <div className={styles.rightColumn}>
        <div className={styles.scheduleContainer}>
          <div className={styles.weekNav}>
            <h3>Lịch trình tuần: {formatWeekRange()}</h3>
            <div className={styles.navButtons}>
              <button onClick={goToPreviousWeek} className={styles.navButton}>⬅️ Tuần trước</button>
              <button onClick={goToCurrentWeek} className={styles.navButton}>📅 Hôm nay</button>
              <button onClick={goToNextWeek} className={styles.navButton}>Tuần sau ➡️</button>
              {/* Nút tạo lịch tuần */}
              <button onClick={handleCreateWeeklySlots} className={styles.navButton} disabled={creating || !coachId}>
                {creating ? 'Đang tạo...' : 'Tạo lịch tuần này'}
              </button>
            </div>
          </div>

          {/* Section quản lý lịch trình */}
          <div className={styles.scheduleActions} style={{ 
            marginBottom: '20px', 
            display: 'flex', 
            gap: '10px', 
            justifyContent: 'center',
            padding: '15px',
            backgroundColor: '#f8f9fa',
            borderRadius: '8px',
            border: '1px solid #e9ecef'
          }}>
            <button 
              onClick={handleCreateWeeklySlots}
              disabled={actionLoading === 'create' || !coachId}
              style={{
                padding: '10px 20px',
                backgroundColor: '#28a745',
                color: 'white',
                border: 'none',
                borderRadius: '5px',
                cursor: actionLoading === 'create' ? 'not-allowed' : 'pointer',
                opacity: actionLoading === 'create' ? 0.6 : 1,
                fontSize: '14px',
                fontWeight: '500'
              }}
            >
              {actionLoading === 'create' ? '⏳ Đang tạo...' : '➕ Tạo lịch tuần mới'}
            </button>

            <button 
              onClick={handleDeleteUnbookedSlotsForWeek}
              disabled={actionLoading === 'deleteWeek' || !coachId}
              style={{
                padding: '12px 24px',
                backgroundColor: '#fd7e14',
                color: 'white',
                border: 'none',
                borderRadius: '6px',
                cursor: actionLoading === 'deleteWeek' ? 'not-allowed' : 'pointer',
                opacity: actionLoading === 'deleteWeek' ? 0.6 : 1,
                fontSize: '14px',
                fontWeight: '500',
                minWidth: '200px'
              }}
            >
              {actionLoading === 'deleteWeek' ? '⏳ Đang xóa...' : `🧹 Xóa ca trống tuần ${formatWeekRange()}`}
            </button>
          </div>

          {/* Success/Error messages */}
          {successMessage && (
            <div style={{ 
              padding: '10px', 
              backgroundColor: '#d4edda', 
              color: '#155724', 
              border: '1px solid #c3e6cb', 
              borderRadius: '5px', 
              marginBottom: '15px' 
            }}>
              ✅ {successMessage}
            </div>
          )}

          {loading && <div>Đang tải lịch trình...</div>}
          {error && <div style={{ color: 'red', padding: '10px', backgroundColor: '#f8d7da', border: '1px solid #f5c6cb', borderRadius: '5px', marginBottom: '15px' }}>❌ {error}</div>}
          
          {/* Schedule Table (giao diện giống booking user) */}
          <div style={{ background: '#fff', borderRadius: 12, padding: 24, boxShadow: '0 4px 24px rgba(0,0,0,0.08)', marginTop: 24 }}>
            <table className={styles.scheduleTable} style={{ width: '100%', borderCollapse: 'collapse' }}>
              <thead>
                <tr>
                  <th className={styles.timeHeader}>Giờ</th>
                  {getWeekDates().map((date, index) => (
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
                      // Ẩn slot đã qua (không render gì)
                      if (isPastDate) {
                        return <td key={`${timeSlot}-${date.toISOString()}`}></td>;
                      }
                      // Slot đã đặt (còn trong tương lai)
                      if (slot && slot.booked) {
                        return (
                          <td key={`${timeSlot}-${date.toISOString()}`} className={styles.slotCell}>
                            <div
                              className={styles.bookedTooltipContainer}
                              onMouseEnter={async () => {
                                if (tooltipTimeout.current) clearTimeout(tooltipTimeout.current);
                                setHoveredSlotId(slot.id);
                                try {
                                  const res = await apiClient.get(`/Booking/slot/${slot.id}/booking-info`);
                                  setHoveredSlotInfo(res.data);
                                } catch {
                                  setHoveredSlotInfo(null);
                                }
                              }}
                              onMouseLeave={() => {
                                if (tooltipTimeout.current) clearTimeout(tooltipTimeout.current);
                                setHoveredSlotId(null);
                                setHoveredSlotInfo(null);
                              }}
                              onClick={async (e) => {
                                e.stopPropagation();
                                try {
                                  const res = hoveredSlotInfo && hoveredSlotId === slot.id ? { data: hoveredSlotInfo } : await apiClient.get(`/Booking/slot/${slot.id}/booking-info`);
                                  if (res.data && res.data.googleMeetLink) {
                                    window.open(res.data.googleMeetLink, '_blank');
                                  }
                                } catch {}
                              }}
                              style={{ position: 'relative', cursor: 'pointer' }}
                            >
                              <span className={styles.bookedText}>Đã đặt</span>
                              {/* Tooltip */}
                              {hoveredSlotId === slot.id && (
                                <div className={styles.slotTooltip} style={{ position: 'absolute', top: '110%', left: '50%', transform: 'translateX(-50%)', zIndex: 10, background: '#fff', border: '1px solid #e5e7eb', borderRadius: 10, boxShadow: '0 4px 16px #0002', padding: 18, minWidth: 240, minHeight: 120, color: '#222', fontSize: 15 }}>
                                  {!hoveredSlotInfo || !hoveredSlotInfo.user ? (
                                    <div style={{ color: '#888', textAlign: 'center', padding: 16 }}>Đang tải...</div>
                                  ) : (
                                    <>
                                      <div style={{ display: 'flex', alignItems: 'center', gap: 14, marginBottom: 8 }}>
                                        <img src={hoveredSlotInfo.user.image || '/images/default-avatar.png'} alt={hoveredSlotInfo.user.name} style={{ width: 48, height: 48, borderRadius: '50%', objectFit: 'cover', border: '2px solid #2563eb' }} />
                                        <div>
                                          <div style={{ fontWeight: 700, fontSize: 18 }}>{hoveredSlotInfo.user.name}</div>
                                          <div style={{ color: '#666', fontSize: 14 }}>{hoveredSlotInfo.user.email}</div>
                                        </div>
                                      </div>
                                      <div style={{ color: '#2563eb', fontWeight: 600, marginBottom: 2 }}>Số lần khám: {hoveredSlotInfo.user.healthCheckups}</div>
                                      <div style={{ color: '#2563eb', fontWeight: 600 }}>Số lần tư vấn: {hoveredSlotInfo.user.consultations}</div>
                                      <div style={{ color: '#888', fontSize: 13, marginTop: 8 }}><i>Click để mở Google Meet</i></div>
                                    </>
                                  )}
                                </div>
                              )}
                            </div>
                          </td>
                        );
                      }
                      // Slot còn trống (còn trong tương lai)
                      if (slot && !slot.booked) {
                        return (
                          <td key={`${timeSlot}-${date.toISOString()}`} className={styles.slotCell}>
                            <div style={{ color: '#22c55e', fontWeight: 700 }}>Trống</div>
                          </td>
                        );
                      }
                      // Không có slot nào
                      return <td key={`${timeSlot}-${date.toISOString()}`}></td>;
                    })}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
      {/* Popup thông tin người đặt */}
      {popupUser && (
        <div className={styles.popupOverlay} onClick={() => setPopupUser(null)}>
          <div className={styles.popupCard} onClick={e => e.stopPropagation()}>
            {popupUser.image && (
              <img src={popupUser.image} alt={popupUser.name} className={styles.popupAvatar} />
            )}
            <div className={styles.popupName}>{popupUser.name}</div>
            <div className={styles.popupEmail}>{popupUser.email}</div>
            <button className={styles.popupClose} onClick={() => setPopupUser(null)}>Đóng</button>
          </div>
        </div>
      )}
    </div>
  );
};

export default CoachSchedulePageForCoach;