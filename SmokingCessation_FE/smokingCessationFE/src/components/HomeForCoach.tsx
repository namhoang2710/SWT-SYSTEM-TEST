import React from 'react';
import { useAuth } from '../contexts/AuthContext';
import { useNavigate } from 'react-router-dom';
import apiClient from '../api/apiClient';
import styles from './MemberHomePage.module.css';
import { getAllMedals, assignMedalToUser, getUserMedalsByCoach, deleteUserMedalByCoach } from '../api/services/medalService';
import { toast } from 'react-toastify';
import { Dialog, DialogTitle, DialogActions, Button, Box } from '@mui/material';

interface MemberInfo {
  userId: number;
  userName: string;
  userEmail: string;
  userAge?: number;
  userGender?: string;
  image?: string;
  // Additional fields that might come from API
  joinDate?: string;
  phone?: string;
  address?: string;
  smokingHistory?: string;
  consultationCount?: number;
}

const HomeForCoach: React.FC = () => {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const [myMembers, setMyMembers] = React.useState<MemberInfo[]>([]);
  const [loadingMembers, setLoadingMembers] = React.useState(false);
  // Thêm state cho searchTerm
  const [searchTerm, setSearchTerm] = React.useState('');
  const [selectedMember, setSelectedMember] = React.useState<MemberInfo | null>(null);
  const [showMemberModal, setShowMemberModal] = React.useState(false);
  const [loadingMemberDetails, setLoadingMemberDetails] = React.useState(false);
  const [medalDialogOpen, setMedalDialogOpen] = React.useState(false);
  const [medalTarget, setMedalTarget] = React.useState<MemberInfo | null>(null);
  const [medals, setMedals] = React.useState<any[]>([]);
  const [selectedMedalId, setSelectedMedalId] = React.useState<number | null>(null);
  const [medalInfo, setMedalInfo] = React.useState('');
  const [memberMedals, setMemberMedals] = React.useState<any[]>([]);
  const [loadingMedals, setLoadingMedals] = React.useState(false);
  const [memberMedalsMap, setMemberMedalsMap] = React.useState<Record<number, any[]>>({});
  const [loadingMedalsMap, setLoadingMedalsMap] = React.useState<Record<number, boolean>>({});

  // Thêm filteredMembers để lọc theo searchTerm
  const filteredMembers = myMembers.filter(member =>
    member.userName?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  React.useEffect(() => {
    const fetchMyMembers = async () => {
      setLoadingMembers(true);
      try {
        const res = await apiClient.get('/coach/my-users');
        setMyMembers(res.data);
        // Gọi API lấy huy chương cho từng thành viên
        const medalsMap: Record<number, any[]> = {};
        const loadingMap: Record<number, boolean> = {};
        await Promise.all(
          (res.data || []).map(async (member: MemberInfo) => {
            loadingMap[member.userId] = true;
            try {
              const medals = await getUserMedalsByCoach(member.userId);
              medalsMap[member.userId] = medals || [];
            } catch {
              medalsMap[member.userId] = [];
            } finally {
              loadingMap[member.userId] = false;
            }
          })
        );
        setMemberMedalsMap(medalsMap);
        setLoadingMedalsMap(loadingMap);
      } catch (err) {
        setMyMembers([]);
      } finally {
        setLoadingMembers(false);
      }
    };
    fetchMyMembers();
  }, []);

  React.useEffect(() => {
    getAllMedals().then(setMedals).catch(() => setMedals([]));
  }, []);

  const handleMemberClick = async (member: MemberInfo) => {
    setSelectedMember(member);
    setShowMemberModal(true);
    setLoadingMemberDetails(true);
    setLoadingMedals(true);
    setMemberMedals([]);
    try {
      // Fetch detailed member info
      const response = await apiClient.get(`/member/${member.userId}`);
      const detailedMember = {
        ...member,
        ...response.data,
        joinDate: response.data.joinDate || new Date().toISOString(),
        consultationCount: response.data.consultations || 0
      };
      setSelectedMember(detailedMember);
      // Fetch member medals
      const medalsRes = await getUserMedalsByCoach(member.userId);
      setMemberMedals(medalsRes || []);
    } catch (error) {
      console.error('Failed to fetch member details or medals:', error);
      // Keep showing basic info if detailed fetch fails
    } finally {
      setLoadingMemberDetails(false);
      setLoadingMedals(false);
    }
  };

  const closeMemberModal = () => {
    setShowMemberModal(false);
    setSelectedMember(null);
    setLoadingMemberDetails(false);
  };


  const handleOpenMedalDialog = (member: MemberInfo) => {
    setMedalTarget(member);
    setSelectedMedalId(null);
    setMedalInfo('');
    setMedalDialogOpen(true);
  };
  const handleCloseMedalDialog = () => {
    setMedalDialogOpen(false);
    setMedalTarget(null);
    setSelectedMedalId(null);
    setMedalInfo('');
  };
  const handleAssignMedal = async () => {
    if (!medalTarget || !selectedMedalId) return;
    try {
      await assignMedalToUser(medalTarget.userId, selectedMedalId, medalInfo);
      toast.success('Trao huân chương thành công!');
      handleCloseMedalDialog();
    } catch {
      toast.error('Trao huân chương thất bại!');
    }
  };

  const handleDeleteMedal = async (member: MemberInfo, userMedalId: number) => {
    try {
      await deleteUserMedalByCoach(userMedalId);
      toast.success('Huỷ huân chương thành công!');
      // Reload lại huy chương cho thành viên này
      const medals = await getUserMedalsByCoach(member.userId);
      setMemberMedalsMap(prev => ({ ...prev, [member.userId]: medals || [] }));
    } catch {
      toast.error('Huỷ huân chương thất bại!');
    }
  };


  // Fake stats for demo
  const stats = {
    newRequests: 3,
    unreadMessages: 5,
    upcomingAppointments: 2,
    online: true,
    quickStats: {
      avgSessions: 5.2,
      rating: 4.8
    }
  };

  // Fake calendar data
  const calendarDays = Array.from({ length: 31 }, (_, i) => i + 1);
  const calendarEvents = [3, 7, 12, 15, 18, 22, 27]; // days with events

  const formatDate = (dateString?: string) => {
    if (!dateString) return 'Chưa cập nhật';
    try {
      return new Date(dateString).toLocaleDateString('vi-VN', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric'
      });
    } catch {
      return 'Chưa cập nhật';
    }
  };

  const getGenderDisplay = (gender?: string) => {
    if (!gender) return 'Chưa cập nhật';
    switch (gender.toLowerCase()) {
      case 'male':
      case 'nam':
        return 'Nam';
      case 'female':
      case 'nữ':
        return 'Nữ';
      default:
        return gender;
    }
  };

  const getImageUrl = (imagePath?: string) => {
    if (!imagePath) return '/images/default-avatar.png';
    if (imagePath.startsWith('http')) return imagePath;
    const baseUrl = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080/api';
    return `${baseUrl}/${imagePath.replace(/\\/g, '/')}`;
  };

  // Hàm chọn emoji theo loại huân chương (dựa vào medal.medal.type)
  const getMedalIcon = (type?: string) => {
    if (!type) return '🏅';
    const t = type.toLowerCase();
    if (t.includes('vàng') || t === 'gold') return '🥇';
    if (t.includes('bạc') || t === 'silver') return '🥈';
    if (t.includes('đồng') || t === 'bronze') return '🥉';
    return '🏅';
  };

  // Thêm hàm xử lý cho các nút trong sidebar
  const handleNavigate = (path: string) => {
    navigate(path);
  };

  const handleLogout = async () => {
    try {
      await logout();
      navigate('/login');
    } catch (error) {
      console.error('Logout failed:', error);
      toast.error('Đăng xuất thất bại. Vui lòng thử lại.');
    }
  };

  return (
    <div style={{ display: 'flex', minHeight: '100vh', background: '#f8fafc' }}>
      <style>{`
        @keyframes fadeInUp {
          from { opacity: 0; transform: translateY(32px); }
          to { opacity: 1; transform: translateY(0); }
        }
        .booking-card-anim {
          animation: fadeInUp 0.6s cubic-bezier(.4,2,.6,1) both;
          transition: box-shadow 0.2s, transform 0.2s;
        }
        .booking-card-anim:hover {
          box-shadow: 0 8px 32px #6366f122, 0 2px 8px #6366f111;
          transform: translateY(-2px) scale(1.02);
          background: #f1f5fa;
        }
      `}</style>
      {/* Sidebar */}
      <aside style={{
        width: 260,
        background: '#1e293b',
        color: '#fff',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        padding: '36px 0 0 0',
        minHeight: '100vh',
      }}>
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', marginBottom: 32 }}>
          <div style={{ width: 72, height: 72, borderRadius: '50%', background: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 28, fontWeight: 700, marginBottom: 16, overflow: 'hidden' }}>
            {user?.image ? <img src={user.image} alt="Coach Avatar" style={{ width: '100%', height: '100%', borderRadius: '50%', objectFit: 'cover' }} /> : (user?.name ? user.name.charAt(0).toUpperCase() : 'C')}
          </div>
          <div style={{ fontWeight: 900, fontSize: 22, textAlign: 'center', lineHeight: 1.2 }}>{user?.name || 'Coach'}</div>
          <div style={{ fontSize: 15, color: '#cbd5e1', marginTop: 2, fontWeight: 500, textAlign: 'center' }}>Coach</div>
        </div>
        <div style={{ width: '100%', marginBottom: 18 }}>
          <div style={{ fontWeight: 700, fontSize: 16, color: '#a5b4fc', textAlign: 'center', marginBottom: 18 }}>Bảng điều khiển</div>
          <ul style={{ listStyle: 'none', padding: 0, margin: 0, width: '100%' }}>
            <li 
              style={{ marginBottom: 18, cursor: 'pointer', color: '#fff', fontWeight: 700, fontSize: 17, textAlign: 'center' }}
              onClick={() => handleNavigate('/home')}
            >
              Dashboard
            </li>
            <li 
              style={{ marginBottom: 18, cursor: 'pointer', color: '#fff', fontWeight: 700, fontSize: 17, textAlign: 'center' }}
              onClick={() => handleNavigate('/coach-schedule')}
            >
              Lịch trình
            </li>
            <li 
              style={{ marginBottom: 18, cursor: 'pointer', color: '#fff', fontWeight: 700, fontSize: 17, textAlign: 'center' }}
              onClick={() => handleNavigate('/coach-members')}
            >
              Khách hàng của tôi
            </li>
            <li 
              style={{ marginBottom: 18, cursor: 'pointer', color: '#fff', fontWeight: 700, fontSize: 17, textAlign: 'center' }}
              onClick={() => handleNavigate('/coach-statistics')}
            >
              Thống kê
            </li>
            <li 
              style={{ marginBottom: 0, cursor: 'pointer', color: '#fff', fontWeight: 700, fontSize: 17, textAlign: 'center' }}
              onClick={handleLogout}
            >
              Đăng xuất
            </li>
          </ul>
        </div>
      </aside>

      {/* Main Content */}
      <main style={{ flex: 1, padding: 36, background: '#f8fafc' }}>
        {/* Stats Row */}
        <div style={{ display: 'flex', gap: 24, marginBottom: 32 }}>
          <div style={{ flex: 1, background: '#fff', borderRadius: 12, padding: 24, boxShadow: '0 2px 8px rgba(0,0,0,0.04)', display: 'flex', flexDirection: 'column', alignItems: 'flex-start' }}>
            <div style={{ fontWeight: 600, color: '#2563eb', marginBottom: 8 }}>Yêu cầu tư vấn mới</div>
            <div style={{ fontSize: 28, fontWeight: 700, color: '#2563eb' }}>{stats.newRequests}</div>
          </div>
          <div style={{ flex: 1, background: '#fff', borderRadius: 12, padding: 24, boxShadow: '0 2px 8px rgba(0,0,0,0.04)', display: 'flex', flexDirection: 'column', alignItems: 'flex-start' }}>
            <div style={{ fontWeight: 600, color: '#64748b', marginBottom: 8 }}>Tin nhắn chưa đọc</div>
            <div style={{ fontSize: 28, fontWeight: 700, color: '#64748b' }}>{stats.unreadMessages}</div>
          </div>
          <div style={{ flex: 1, background: '#fff', borderRadius: 12, padding: 24, boxShadow: '0 2px 8px rgba(0,0,0,0.04)', display: 'flex', flexDirection: 'column', alignItems: 'flex-start' }}>
            <div style={{ fontWeight: 600, color: '#0ea5e9', marginBottom: 8 }}>Cuộc hẹn sắp tới</div>
            <div style={{ fontSize: 28, fontWeight: 700, color: '#0ea5e9' }}>{stats.upcomingAppointments}</div>
          </div>
          <div style={{ flex: 1, background: '#fff', borderRadius: 12, padding: 24, boxShadow: '0 2px 8px rgba(0,0,0,0.04)', display: 'flex', flexDirection: 'column', alignItems: 'flex-start' }}>
            <div style={{ fontWeight: 600, color: '#22c55e', marginBottom: 8 }}>Trạng thái</div>
            <div style={{ fontSize: 22, fontWeight: 700, color: stats.online ? '#22c55e' : '#f87171' }}>{stats.online ? 'Online' : 'Offline'}</div>
          </div>
        </div>

        {/* My Members & Calendar Row */}
        <div style={{ display: 'flex', gap: 24 }}>
          {/* My Members */}
          <div style={{ flex: 2, background: '#fff', borderRadius: 12, padding: 24, boxShadow: '0 2px 8px rgba(0,0,0,0.04)' }}>
            <div style={{ fontWeight: 700, fontSize: 20, marginBottom: 18, color: '#2563eb' }}>Thành viên đang tư vấn</div>
            {/* Ô tìm kiếm */}
            <input
              type="text"
              placeholder="Tìm kiếm theo tên..."
              value={searchTerm}
              onChange={e => setSearchTerm(e.target.value)}
              style={{ width: '100%', padding: 10, borderRadius: 8, border: '1px solid #e5e7eb', marginBottom: 18, fontSize: 15 }}
            />
            {loadingMembers ? (
              <div>Đang tải...</div>
            ) : filteredMembers.length === 0 ? (
              <div>Không tìm thấy thành viên nào.</div>
            ) : (
              <ul style={{ listStyle: 'none', padding: 0, margin: 0 }}>
                {filteredMembers.map((member, idx) => {
                  const medals = memberMedalsMap[member.userId] || [];
                  const hasMedal = medals.length > 0;
                  return (
                    <li key={member.userId || idx} style={{ display: 'flex', alignItems: 'center', marginBottom: 18, paddingBottom: 12, borderBottom: '1px solid #f1f5f9' }}>
                      <img src={member.image || '/public/images/logo.png'} alt={member.userName || 'avatar'} style={{ width: 48, height: 48, borderRadius: '50%', objectFit: 'cover', marginRight: 18, cursor: 'pointer' }} onClick={() => navigate(`/coach/member/${member.userId}`)} />
                      <div style={{ flex: 1, cursor: 'pointer' }} onClick={() => navigate(`/coach/member/${member.userId}`)}>
                        <div style={{ fontWeight: 600, color: '#0a66c2', fontSize: 16 }}>{member.userName || ''}</div>
                        <div style={{ fontSize: 13, color: '#666' }}>{member.userEmail || ''}</div>
                        <div style={{ fontSize: 13, color: '#888' }}>
                          {member.userAge ? `Tuổi: ${member.userAge}` : ''}
                          {member.userGender ? ` • ${member.userGender === 'male' ? 'Nam' : member.userGender === 'female' ? 'Nữ' : member.userGender}` : ''}
                        </div>
                        {/* Hiển thị huy chương nếu có */}
                        <div style={{ marginTop: 4 }}>
                          {loadingMedalsMap[member.userId] ? (
                            <span style={{ fontSize: 12, color: '#aaa' }}>Đang tải huy chương...</span>
                          ) : hasMedal ? (
                            <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
                              {medals.map((medalObj, mIdx) => {
                                const medal = medalObj.medal || medalObj;
                                return (
                                  <span key={medalObj.userMedalId || medalObj.userMedalID || medal.id || mIdx} style={{ fontSize: 13, color: '#f59e42', background: '#fff7ed', borderRadius: 8, padding: '2px 8px', display: 'flex', alignItems: 'center', gap: 4 }}>
                                    {getMedalIcon(medal.type)} {medal.name}
                                  </span>
                                );
                              })}
                            </div>
                          ) : null}
                        </div>
                      </div>
                      <span style={{ fontSize: 13, color: '#22c55e', fontWeight: 600, marginRight: 12 }}>Đang tư vấn</span>
                      {hasMedal ? (
                        <Button
                          variant="outlined"
                          color="error"
                          size="small"
                          onClick={() => handleDeleteMedal(member, medals[0].userMedalId || medals[0].userMedalID)}
                        >
                          Huỷ huân chương
                        </Button>
                      ) : (
                        <Button
                          variant="outlined"
                          color="primary"
                          size="small"
                          onClick={() => handleOpenMedalDialog(member)}
                        >
                          Trao huân chương
                        </Button>
                      )}
                    </li>
                  );
                })}
              </ul>
            )}
          </div>

          {/* Calendar & Quick Stats */}
          <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 24 }}>
            {/* Mini Calendar */}
            <div style={{ background: '#fff', borderRadius: 12, padding: 18, boxShadow: '0 2px 8px rgba(0,0,0,0.04)' }}>
              <div style={{ fontWeight: 700, fontSize: 16, marginBottom: 10, color: '#0ea5e9' }}>Lịch tư vấn</div>
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7, 1fr)', gap: 4, fontSize: 13, color: '#64748b', marginBottom: 6 }}>
                {['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'].map(d => <div key={d} style={{ textAlign: 'center' }}>{d}</div>)}
              </div>
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7, 1fr)', gap: 4 }}>
                {calendarDays.map(day => (
                  <div key={day} style={{ textAlign: 'center', padding: 4, borderRadius: 6, background: calendarEvents.includes(day) ? '#2563eb' : 'transparent', color: calendarEvents.includes(day) ? '#fff' : '#64748b', fontWeight: calendarEvents.includes(day) ? 700 : 400 }}>
                    {day}
                  </div>
                ))}
              </div>
            </div>
            {/* Quick Stats */}
            <div style={{ background: '#fff', borderRadius: 12, padding: 18, boxShadow: '0 2px 8px rgba(0,0,0,0.04)' }}>
              <div style={{ fontWeight: 700, fontSize: 16, marginBottom: 10, color: '#f59e42' }}>Quick Stats</div>
              <div style={{ fontSize: 15, color: '#64748b', marginBottom: 6 }}>Số buổi tư vấn TB/tháng: <span style={{ color: '#0a66c2', fontWeight: 600 }}>{stats.quickStats.avgSessions}</span></div>
              <div style={{ fontSize: 15, color: '#64748b' }}>Đánh giá trung bình: <span style={{ color: '#f59e42', fontWeight: 700 }}>{stats.quickStats.rating} ★</span></div>
            </div>
          </div>
        </div>
      </main>

      {/* Member Details Modal */}
      {showMemberModal && selectedMember && (
        <div style={{
          position: 'fixed',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          backgroundColor: 'rgba(0, 0, 0, 0.5)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          zIndex: 1000,
          padding: 20
        }}>
          <div style={{
            backgroundColor: 'white',
            borderRadius: 16,
            maxWidth: 500,
            width: '100%',
            maxHeight: '90vh',
            overflow: 'auto',
            boxShadow: '0 20px 60px rgba(0, 0, 0, 0.3)',
            animation: 'slideIn 0.3s ease-out'
          }}>
            {/* Modal Header */}
            <div style={{
              padding: '24px 24px 0 24px',
              borderBottom: '1px solid #e5e7eb',
              marginBottom: 24
            }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <h2 style={{ color: '#1f2937', margin: 0, fontSize: 20, fontWeight: 700 }}>
                  Thông tin thành viên
                </h2>
                <button 
                  onClick={closeMemberModal}
                  style={{
                    background: 'none',
                    border: 'none',
                    fontSize: 24,
                    cursor: 'pointer',
                    color: '#6b7280',
                    padding: 4,
                    borderRadius: 4
                  }}
                  onMouseEnter={(e) => e.currentTarget.style.backgroundColor = '#f3f4f6'}
                  onMouseLeave={(e) => e.currentTarget.style.backgroundColor = 'transparent'}
                >
                  ×
                </button>
              </div>
            </div>

            {/* Modal Content */}
            <div style={{ padding: '0 24px 24px 24px' }}>
              {/* Huy chương của thành viên */}
              <div style={{ marginBottom: 16 }}>
                <div style={{ fontWeight: 600, color: '#f59e42', marginBottom: 6, fontSize: 15 }}>Huy chương đã nhận:</div>
                {loadingMedals ? (
                  <div>Đang tải huy chương...</div>
                ) : memberMedals.length === 0 ? (
                  <div style={{ color: '#888', fontSize: 14 }}>Chưa có huy chương nào.</div>
                ) : (
                  <ul style={{ paddingLeft: 18, margin: 0 }}>
                    {memberMedals.map((medal, idx) => (
                      <li key={medal.userMedalId || medal.id || idx} style={{ marginBottom: 6, color: '#f59e42', fontWeight: 500, fontSize: 14 }}>
                        🏅 {medal.medalName || medal.name} <span style={{ color: '#64748b', fontWeight: 400 }}>({medal.medalType || medal.type})</span>
                        {medal.description && <span style={{ color: '#888', fontWeight: 400 }}> - {medal.description}</span>}
                        {medal.date && <span style={{ color: '#888', fontWeight: 400 }}> ({new Date(medal.date).toLocaleDateString('vi-VN')})</span>}
                      </li>
                    ))}
                  </ul>
                )}
              </div>
              {loadingMemberDetails ? (
                <div style={{ 
                  display: 'flex', 
                  justifyContent: 'center', 
                  alignItems: 'center', 
                  minHeight: 200,
                  flexDirection: 'column',
                  gap: 12
                }}>
                  <div style={{
                    width: 40,
                    height: 40,
                    border: '4px solid #e5e7eb',
                    borderTopColor: '#3b82f6',
                    borderRadius: '50%',
                    animation: 'spin 1s linear infinite'
                  }}></div>
                  <span style={{ color: '#6b7280' }}>Đang tải thông tin...</span>
                </div>
              ) : (
                <>
                  {/* Member Avatar & Basic Info */}
                  <div style={{ display: 'flex', alignItems: 'center', marginBottom: 24 }}>
                    <div style={{
                      width: 80,
                      height: 80,
                      borderRadius: '50%',
                      overflow: 'hidden',
                      marginRight: 20,
                      border: '3px solid #e5e7eb',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      backgroundColor: '#3b82f6',
                      color: 'white',
                      fontSize: 24,
                      fontWeight: 'bold'
                    }}>
                      {selectedMember.image ? (
                        <img
                          src={getImageUrl(selectedMember.image)}
                          alt={selectedMember.userName}
                          style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                          onError={(e) => {
                            const target = e.target as HTMLImageElement;
                            target.style.display = 'none';
                            if (target.parentElement) {
                              target.parentElement.textContent = selectedMember.userName?.charAt(0).toUpperCase() || 'U';
                            }
                          }}
                        />
                      ) : (
                        selectedMember.userName?.charAt(0).toUpperCase() || 'U'
                      )}
                    </div>
                    <div>
                      <h3 style={{ 
                        fontSize: 22, 
                        fontWeight: 'bold', 
                        color: '#1f2937',
                        marginBottom: 4,
                        margin: 0
                      }}>
                        {selectedMember.userName || 'Chưa cập nhật'}
                      </h3>
                      <p style={{ color: '#6b7280', fontSize: 14, margin: '4px 0' }}>
                        {selectedMember.userEmail || 'Chưa cập nhật email'}
                      </p>
                      <div style={{
                        display: 'inline-block',
                        backgroundColor: '#dcfce7',
                        color: '#166534',
                        padding: '4px 8px',
                        borderRadius: 12,
                        fontSize: 12,
                        fontWeight: 500
                      }}>
                        Đang tư vấn
                      </div>
                    </div>
                  </div>

                  {/* Member Details Grid */}
                  <div style={{
                    display: 'grid',
                    gridTemplateColumns: '1fr 1fr',
                    gap: 16,
                    marginBottom: 20
                  }}>
                    <div style={{
                      padding: 16,
                      backgroundColor: '#f8fafc',
                      borderRadius: 8,
                      border: '1px solid #e2e8f0'
                    }}>
                      <div style={{ fontSize: 12, color: '#64748b', fontWeight: 500, marginBottom: 4 }}>
                        TUỔI
                      </div>
                      <div style={{ fontSize: 16, fontWeight: 600, color: '#1f2937' }}>
                        {selectedMember.userAge ? `${selectedMember.userAge} tuổi` : 'Chưa cập nhật'}
                      </div>
                    </div>

                    <div style={{
                      padding: 16,
                      backgroundColor: '#f8fafc',
                      borderRadius: 8,
                      border: '1px solid #e2e8f0'
                    }}>
                      <div style={{ fontSize: 12, color: '#64748b', fontWeight: 500, marginBottom: 4 }}>
                        GIỚI TÍNH
                      </div>
                      <div style={{ fontSize: 16, fontWeight: 600, color: '#1f2937' }}>
                        {getGenderDisplay(selectedMember.userGender)}
                      </div>
                    </div>

                    <div style={{
                      padding: 16,
                      backgroundColor: '#f8fafc',
                      borderRadius: 8,
                      border: '1px solid #e2e8f0'
                    }}>
                      <div style={{ fontSize: 12, color: '#64748b', fontWeight: 500, marginBottom: 4 }}>
                        SỐ ĐIỆN THOẠI
                      </div>
                      <div style={{ fontSize: 16, fontWeight: 600, color: '#1f2937' }}>
                        {selectedMember.phone || 'Chưa cập nhật'}
                      </div>
                    </div>

                    <div style={{
                      padding: 16,
                      backgroundColor: '#f8fafc',
                      borderRadius: 8,
                      border: '1px solid #e2e8f0'
                    }}>
                      <div style={{ fontSize: 12, color: '#64748b', fontWeight: 500, marginBottom: 4 }}>
                        SỐ BUỔI TƯ VẤN
                      </div>
                      <div style={{ fontSize: 16, fontWeight: 600, color: '#1f2937' }}>
                        {selectedMember.consultationCount || 0} buổi
                      </div>
                    </div>
                  </div>

                  {/* Additional Info */}
                  <div style={{
                    padding: 16,
                    backgroundColor: '#fefce8',
                    borderRadius: 8,
                    border: '1px solid #fbbf24',
                    marginBottom: 20
                  }}>
                    <div style={{ fontSize: 12, color: '#92400e', fontWeight: 500, marginBottom: 4 }}>
                      NGÀY THAM GIA
                    </div>
                    <div style={{ fontSize: 14, fontWeight: 500, color: '#92400e' }}>
                      {formatDate(selectedMember.joinDate)}
                    </div>
                  </div>

                  {selectedMember.address && (
                    <div style={{
                      padding: 16,
                      backgroundColor: '#eff6ff',
                      borderRadius: 8,
                      border: '1px solid #3b82f6',
                      marginBottom: 20
                    }}>
                      <div style={{ fontSize: 12, color: '#1e40af', fontWeight: 500, marginBottom: 4 }}>
                        ĐỊA CHỈ
                      </div>
                      <div style={{ fontSize: 14, fontWeight: 500, color: '#1e40af' }}>
                        {selectedMember.address}
                      </div>
                    </div>
                  )}

                  {/* Action Buttons */}
                  <div style={{ display: 'flex', gap: 12, justifyContent: 'flex-end' }}>
                    <button 
                      onClick={closeMemberModal}
                      style={{
                        padding: '10px 20px',
                        backgroundColor: '#6b7280',
                        color: 'white',
                        border: 'none',
                        borderRadius: 8,
                        cursor: 'pointer',
                        fontSize: 14,
                        fontWeight: 500,
                        transition: 'background-color 0.2s'
                      }}
                      onMouseEnter={(e) => e.currentTarget.style.backgroundColor = '#4b5563'}
                      onMouseLeave={(e) => e.currentTarget.style.backgroundColor = '#6b7280'}
                    >
                      Đóng
                    </button>
                    <button 
                      onClick={() => {
                        // You can add navigation to member's detailed page here
                        console.log('Navigate to member details page:', selectedMember.userId);
                      }}
                      style={{
                        padding: '10px 20px',
                        backgroundColor: '#3b82f6',
                        color: 'white',
                        border: 'none',
                        borderRadius: 8,
                        cursor: 'pointer',
                        fontSize: 14,
                        fontWeight: 500,
                        transition: 'background-color 0.2s'
                      }}
                      onMouseEnter={(e) => e.currentTarget.style.backgroundColor = '#2563eb'}
                      onMouseLeave={(e) => e.currentTarget.style.backgroundColor = '#3b82f6'}
                    >
                      Xem chi tiết
                    </button>
                  </div>
                </>
              )}
            </div>
          </div>
        </div>
      )}

      <Dialog open={medalDialogOpen} onClose={handleCloseMedalDialog}>
        <DialogTitle>Trao huân chương cho thành viên</DialogTitle>
        <DialogActions sx={{ flexDirection: 'column', alignItems: 'stretch', gap: 2, p: 2 }}>
          <select
            value={selectedMedalId ?? ''}
            onChange={e => setSelectedMedalId(Number(e.target.value))}
            style={{ padding: 8, borderRadius: 6, fontSize: 16 }}
          >
            <option value="" disabled>Chọn huân chương</option>
            {medals.map(medal => (
              <option key={medal.medalID || medal.id} value={medal.medalID || medal.id}>
                {medal.name} ({medal.type})
              </option>
            ))}
          </select>
          <input
            type="text"
            placeholder="Mô tả lý do trao (tuỳ chọn)"
            value={medalInfo}
            onChange={e => setMedalInfo(e.target.value)}
            style={{ padding: 8, borderRadius: 6, fontSize: 16, marginTop: 8 }}
          />
          <Box sx={{ display: 'flex', justifyContent: 'flex-end', gap: 2, mt: 2 }}>
            <Button onClick={handleCloseMedalDialog}>Hủy</Button>
            <Button onClick={handleAssignMedal} variant="contained" color="primary" disabled={!selectedMedalId}>Trao</Button>
          </Box>
        </DialogActions>
      </Dialog>

      <style>{`
        @keyframes slideIn {
          from {
            opacity: 0;
            transform: translateY(50px) scale(0.9);
          }
          to {
            opacity: 1;
            transform: translateY(0) scale(1);
          }
        }

        @keyframes spin {
          to { transform: rotate(360deg); }
        }
      `}</style>
    </div>
  );
};

export default HomeForCoach;