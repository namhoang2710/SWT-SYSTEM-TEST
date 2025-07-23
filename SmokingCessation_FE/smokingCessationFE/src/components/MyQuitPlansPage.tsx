import React, { useEffect, useState } from 'react';
import apiClient from '../api/apiClient';
import { useAuth } from '../contexts/AuthContext';
import { toast } from 'react-toastify';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { Tooltip as ReactTooltip } from 'react-tooltip';
import { FaCrown, FaCalendarAlt, FaRunning, FaSmile, FaFire, FaCheckCircle, FaRegEdit, FaUserCircle, FaChevronLeft, FaChevronRight, FaRegCalendarCheck, FaRegCalendarTimes, FaRegCalendarPlus } from 'react-icons/fa';
import styles from './ProgressForm.module.css';

interface QuitPlan {
  planId: number;
  title: string;
  description: string;
  startDate: string;
  goalDate: string;
  targetCigarettesPerDay: number;
  status: string;
  createdDate: string; // Added createdDate
}

interface PlanWeek {
  planDetailId: number;
  planId: number;
  weekNumber: number;
  startDate: string;
  endDate: string;
  targetCigarettesPerDay: number;
  weeklyContent: string;
  createdAt: string;
}

const encouragements = [
  "Bạn đang làm rất tốt, hãy tiếp tục cố gắng nhé!",
  "Mỗi ngày không hút thuốc là một chiến thắng!",
  "Hãy tự hào về bản thân, bạn đã tiến bộ rồi!",
  "Đừng bỏ cuộc, hành trình này xứng đáng!",
  "Bạn mạnh mẽ hơn bạn nghĩ, tiếp tục nhé!",
  "Mỗi bước nhỏ đều quan trọng, cố lên!",
  "Bạn đang tiến gần hơn tới mục tiêu!",
  "Hãy nhớ lý do bạn bắt đầu, bạn sẽ làm được!"
];

const MyQuitPlansPage = () => {
  const { user } = useAuth();
  const [plans, setPlans] = useState<QuitPlan[]>([]);
  const [weeks, setWeeks] = useState<PlanWeek[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [currentWeekIndex, setCurrentWeekIndex] = useState(0);
  const [showProgressForm, setShowProgressForm] = useState(false);
  const [progressForm, setProgressForm] = useState({
    date: new Date().toISOString().slice(0, 10),
    cigarettesSmoked: '',
    cravingLevel: '',
    moodLevel: '',
    exerciseMinutes: '',
    notes: ''
  });
  const [progressLoading, setProgressLoading] = useState(false);
  const [progressError, setProgressError] = useState('');
  const [progressSuccess, setProgressSuccess] = useState('');
  const [encouragement, setEncouragement] = useState("");
  const [progressList, setProgressList] = useState<any[]>([]);
  const [progressLoadingTable, setProgressLoadingTable] = useState(false);
  const [progressWeekIndex, setProgressWeekIndex] = useState(0); // Thêm state để quản lý tuần trong bảng tiến độ

  useEffect(() => {
    setCurrentWeekIndex(0);
  }, [weeks.length]);

  useEffect(() => {
    fetchPlans();
  }, []);

  // Lấy kế hoạch mới nhất (theo ngày tạo)
  const latestPlan = plans.slice().sort((a, b) => {
    const dateB = new Date(b.createdDate || b.startDate).getTime();
    const dateA = new Date(a.createdDate || a.startDate).getTime();
    return dateB - dateA;
  })[0];

  // Đưa fetchProgress ra ngoài useEffect để có thể gọi lại ở nhiều nơi
  const fetchProgress = async () => {
    if (!latestPlan?.planId) return;
    setProgressLoadingTable(true);
    try {
      const res = await apiClient.get(`/progress/plan/${latestPlan.planId}`);
      setProgressList(Array.isArray(res.data) ? res.data : []);
    } catch {
      setProgressList([]);
    } finally {
      setProgressLoadingTable(false);
    }
  };

  // Lấy tiến độ khi có latestPlan
  useEffect(() => {
    fetchProgress();
  }, [latestPlan?.planId]);

  const fetchPlans = async () => {
    setLoading(true);
    try {
      const res = await apiClient.get('/plans/member/my-plans');
      setPlans(res.data);
      if (Array.isArray(res.data) && res.data.length > 0) {
        // Lấy kế hoạch mới nhất
        const sortedPlans = res.data.slice().sort((a, b) => {
          const dateB = new Date(b.createdDate || b.startDate).getTime();
          const dateA = new Date(a.createdDate || a.startDate).getTime();
          return dateB - dateA;
        });
        const latest = sortedPlans[0];
        // Lấy tuần cho kế hoạch mới nhất
        const weeksRes = await apiClient.get(`/plans/${latest.planId}/weeks/member`);
        setWeeks(weeksRes.data);
      } else {
        setWeeks([]);
      }
    } catch (e) {
      setError('Không thể tải kế hoạch cai thuốc');
      setPlans([]);
      setWeeks([]);
    } finally {
      setLoading(false);
    }
  };

  // Hàm tính các tuần từ progressList
  const getWeeks = () => {
    if (!progressList.length) return [];
    // Lấy tất cả các ngày, sort tăng dần
    const allDates = progressList.map(p => new Date(p.date)).sort((a, b) => a.getTime() - b.getTime());
    if (!allDates.length) return [];
    // Tìm ngày đầu tiên là thứ 2 (hoặc lùi về thứ 2 gần nhất)
    const firstDate = new Date(allDates[0]);
    const firstMonday = new Date(firstDate);
    firstMonday.setDate(firstMonday.getDate() - ((firstMonday.getDay() + 6) % 7));
    // Tìm ngày cuối cùng là chủ nhật (hoặc tiến tới chủ nhật gần nhất)
    const lastDate = new Date(allDates[allDates.length - 1]);
    const lastSunday = new Date(lastDate);
    lastSunday.setDate(lastSunday.getDate() + (7 - lastSunday.getDay()) % 7);
    // Tạo mảng các tuần
    const weeks = [];
    let start = new Date(firstMonday);
    while (start <= lastSunday) {
      const week = [];
      for (let i = 0; i < 7; i++) {
        const d = new Date(start);
        d.setDate(start.getDate() + i);
        week.push(new Date(d));
      }
      weeks.push(week);
      start.setDate(start.getDate() + 7);
    }
    return weeks;
  };
  const progressWeeks = getWeeks();
  const currentWeek = progressWeeks[progressWeekIndex] || [];

  // Auto chọn tuần hiện tại khi có dữ liệu progressWeeks
  useEffect(() => {
    if (!progressWeeks.length) return;
    const today = new Date();
    const weekIdx = progressWeeks.findIndex(weekArr =>
      weekArr.some(day =>
        day.getFullYear() === today.getFullYear() &&
        day.getMonth() === today.getMonth() &&
        day.getDate() === today.getDate()
      )
    );
    if (weekIdx !== -1) setProgressWeekIndex(weekIdx);
  }, [progressWeeks.length]);

  const rowLabels = [
    'Số điếu',
    'Thèm thuốc',
    'Tâm trạng',
    'Thể dục (phút)',
    'Hoạt động',
    'Phản hồi HLV'
  ];
  const rowFields = [
    'cigarettesSmoked',
    'cravingLevel',
    'moodLevel',
    'exerciseMinutes',
    'notes',
    'coachFeedback'
  ];

  React.useEffect(() => {
    const link = document.createElement('link');
    link.href = 'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;900&display=swap';
    link.rel = 'stylesheet';
    document.head.appendChild(link);
    return () => { document.head.removeChild(link); };
  }, []);

  return (
    <div style={{ minHeight: '100vh', width: '100%', background: 'linear-gradient(120deg, #e0e7ff 0%, #f8fafc 100%)', padding: '48px 0', position: 'relative', overflowX: 'hidden', fontFamily: 'Inter, Arial, sans-serif', letterSpacing: 0, lineHeight: 1.7 }}>
      <style>{`
        body, .plan-fadein, .plan-card-anim, .week-card, .progress-table, .chart-area, .glass-modal {
          font-family: 'Inter', Arial, sans-serif !important;
          letter-spacing: 0;
          line-height: 1.7;
          color: #222;
        }
        h1, h2, h3, h4, h5, h6 {
          font-family: 'Inter', Arial, sans-serif !important;
          font-weight: 900;
          letter-spacing: 0.01em;
          color: #1e293b;
          text-transform: uppercase;
          margin-bottom: 0.5em;
        }
        .plan-card-anim, .week-card, .glass-modal {
          font-size: 17px;
          font-weight: 500;
          color: #374151;
          background: rgba(255,255,255,0.96);
          border-radius: 28px;
          box-shadow: 0 6px 32px #2563eb13;
          border: 1.5px solid #e0e7ff;
          padding: 32px 28px;
          margin-bottom: 18px;
        }
        .plan-card-anim {
          border: 2.5px solid;
          border-image: linear-gradient(90deg,#2563eb 0%,#22c55e 100%) 1;
          box-shadow: 0 8px 32px #2563eb22;
        }
        .plan-card-anim:hover, .week-card:hover {
          box-shadow: 0 12px 36px #2563eb22, 0 2px 8px #22c55e22;
          transform: translateY(-2px) scale(1.025);
          border-color: #2563eb;
        }
        .week-card {
          background: linear-gradient(90deg,#f8fafc 60%,#e0e7ff 100%);
          border-radius: 28px;
          color: #222;
          border: 1.5px solid #e0e7ff;
          box-shadow: 0 2px 12px #2563eb11;
          padding: 24px 22px;
        }
        .week-card-active {
          border: 2.5px solid #22c55e;
          box-shadow: 0 4px 18px #22c55e22;
          background: linear-gradient(90deg,#f0fdf4 60%,#e0e7ff 100%);
        }
        .progress-table {
          background: #f8fafc;
          border-radius: 28px;
          box-shadow: 0 2px 12px #2563eb11;
          padding: 18px 0 8px 0;
          margin-bottom: 24px;
        }
        .progress-table th {
          background: linear-gradient(90deg,#2563eb 60%,#38bdf8 100%);
          color: #fff;
          border-radius: 18px 18px 0 0;
          font-size: 16px;
          font-weight: 800;
          letter-spacing: 0.01em;
          position: sticky;
          top: 0;
          z-index: 2;
          border-bottom: 2px solid #e0e7ff;
        }
        .progress-table td {
          font-size: 15px;
          font-weight: 600;
          color: #374151;
          background: #f1f5f9;
          border-bottom: 1px solid #e0e7ff;
        }
        .progress-table tr:hover td {
          background: #e0e7ff;
        }
        .chart-area {
          background: #f8fafc;
          border-radius: 28px;
          box-shadow: 0 2px 12px #2563eb11;
          padding: 32px 24px;
          margin-bottom: 24px;
        }
        .plan-tab, .plan-tab-active {
          font-family: 'Inter', Arial, sans-serif !important;
          font-weight: 700;
          letter-spacing: 0.01em;
          font-size: 16px;
          color: #2563eb;
          background: #e0e7ff;
          border-radius: 14px;
          padding: 10px 22px;
          margin: 0 8px;
          border: none;
          transition: background 0.18s, color 0.18s, box-shadow 0.18s;
          box-shadow: 0 2px 8px #2563eb11;
        }
        .plan-tab-active {
          background: linear-gradient(90deg,#2563eb 60%,#22c55e 100%);
          color: #fff !important;
          box-shadow: 0 2px 8px #2563eb22;
        }
        label, .glass-modal label {
          font-size: 15px;
          font-weight: 600;
          color: #2563eb;
          letter-spacing: 0.01em;
          margin-bottom: 6px;
        }
        button, .glass-modal .formButton {
          font-family: 'Inter', Arial, sans-serif !important;
          font-weight: 700;
          letter-spacing: 0.01em;
          font-size: 17px;
          border-radius: 16px;
          padding: 12px 32px;
          background: linear-gradient(90deg,#2563eb 60%,#22c55e 100%);
          color: #fff;
          border: none;
          box-shadow: 0 2px 8px #2563eb22;
          transition: background 0.18s, transform 0.18s;
          display: flex;
          align-items: center;
          gap: 8px;
        }
        button:active, .glass-modal .formButton:active {
          transform: scale(0.98);
        }
        .avatar-pro {
          border-radius: 50%;
          border: 4px solid;
          border-image: linear-gradient(135deg,#2563eb 40%,#22c55e 100%) 1;
          box-shadow: 0 4px 18px #2563eb22;
          width: 120px;
          height: 120px;
          object-fit: cover;
          margin-bottom: 18px;
          position: relative;
        }
        .badge-status {
          display: inline-flex;
          align-items: center;
          gap: 6px;
          font-size: 14px;
          font-weight: 700;
          border-radius: 8px;
          padding: 3px 12px;
          background: #e0e7ff;
          color: #2563eb;
          margin-left: 8px;
        }
        .badge-status.active { background: #e7fbe9; color: #22c55e; }
        .badge-status.inactive { background: #ffeaea; color: #ef4444; }
        .badge-status.pending { background: #fef9c3; color: #eab308; }
        .glass-modal {
          background: rgba(255,255,255,0.96);
          backdrop-filter: blur(16px);
          border-radius: 32px;
          box-shadow: 0 12px 48px #2563eb33;
          padding: 40px 32px;
          max-width: 440px;
          margin: 0 auto;
          position: relative;
          animation: fadeInUpPlan 0.5s cubic-bezier(.4,2,.6,1) both;
        }
        .glass-modal .closeBtn {
          position: absolute;
          top: 12px;
          right: 18px;
          font-size: 32px;
          color: #ef4444;
          background: none;
          border: none;
          cursor: pointer;
          font-weight: 900;
        }
        .glass-modal input, .glass-modal textarea {
          width: 100%;
          border-radius: 12px;
          border: 1.5px solid #e0e7ff;
          padding: 12px 14px;
          margin-bottom: 14px;
          font-size: 16px;
          background: #f8fafc;
          transition: border 0.18s;
        }
        .glass-modal input:focus, .glass-modal textarea:focus {
          border: 1.5px solid #2563eb;
          outline: none;
        }
        .glass-modal .formButton {
          width: 100%;
          margin-top: 10px;
        }
        .glass-modal .formError { color: #ef4444; font-weight: 700; margin-bottom: 8px; }
        .glass-modal .formSuccess { color: #22c55e; font-weight: 700; margin-bottom: 8px; }
        .encouragement-anim { animation: fadeInUpPlan 0.7s cubic-bezier(.4,2,.6,1) both; font-size: 18px; color: #22c55e; font-weight: 700; margin-top: 12px; text-align: center; }
        @media (max-width: 1100px) {
          .plan-fadein { flex-direction: column !important; gap: 24px !important; }
        }
        @media (max-width: 700px) {
          .plan-fadein { flex-direction: column !important; gap: 18px !important; }
          .plan-card-anim, .week-card, .glass-modal, .progress-table, .chart-area { padding: 18px 8px !important; border-radius: 16px !important; }
        }
      `}</style>
      <div className="plan-fadein" style={{ display: 'flex', gap: 32, maxWidth: 1600, margin: '0 auto', alignItems: 'flex-start', flexWrap: 'nowrap', justifyContent: 'center' }}>
        {/* Cột 1: Profile + kế hoạch tổng */}
        <div style={{ flex: '0 0 260px', minWidth: 200, maxWidth: 280, display: 'flex', flexDirection: 'column', gap: 18 }}>
          {/* Profile */}
          <div className="plan-card-anim" style={{ background: '#fff', borderRadius: 22, boxShadow: '0 4px 24px #2563eb22', padding: 24, display: 'flex', flexDirection: 'column', alignItems: 'center', marginBottom: 0, animationDelay: '0.05s' }}>
            {user && (
              <>
                <img src={user.image} alt={user.name} style={{ width: 110, height: 110, borderRadius: '50%', objectFit: 'cover', border: '3px solid #22c55e', marginBottom: 18, boxShadow: '0 2px 12px #22c55e22' }} />
                <div style={{ fontWeight: 900, fontSize: 26, color: '#2563eb', marginBottom: 6, textAlign: 'center', letterSpacing: 1 }}>{user.name}</div>
                <div style={{ color: '#444', fontSize: 16, marginBottom: 8, textAlign: 'center' }}>{user.email}</div>
                <div style={{ color: '#666', fontSize: 15, marginBottom: 4 }}>Tuổi: {user.age}</div>
                <div style={{ color: '#666', fontSize: 15, marginBottom: 4 }}>Giới tính: {user.gender === 'Male' ? 'Nam' : 'Nữ'}</div>
              </>
            )}
          </div>
          {/* Kế hoạch tổng */}
          <div className="plan-card-anim" style={{ background: '#fff', borderRadius: 22, boxShadow: '0 4px 24px #2563eb22', padding: 22, animationDelay: '0.12s' }}>
            <h2 style={{ fontSize: 22, fontWeight: 900, color: '#22c55e', marginBottom: 18, textAlign: 'center', letterSpacing: 1 }}>Kế hoạch cai thuốc của bạn</h2>
            {error && <div style={{ color: 'red', marginBottom: 12, textAlign: 'center', fontWeight: 600 }}>{error}</div>}
            {loading ? <div style={{ textAlign: 'center', color: '#2563eb', fontWeight: 600 }}>Đang tải dữ liệu...</div> : (
              !latestPlan ? <div style={{ textAlign: 'center', color: '#888', fontSize: 18 }}>Chưa có kế hoạch nào.</div> : (
                <div style={{ background: '#f8fafc', borderRadius: 14, boxShadow: '0 2px 8px #0001', padding: '16px 18px', fontWeight: 700, fontSize: 17, color: '#222' }}>
                  <div style={{ fontWeight: 900, fontSize: 22, marginBottom: 10, color: '#2563eb' }}>{latestPlan.title}</div>
                  <div style={{ marginBottom: 8, whiteSpace: 'pre-line' }}><b>Mô tả:</b> {latestPlan.description}</div>
                  <div style={{ marginBottom: 8 }}><b>Ngày bắt đầu:</b> {latestPlan.startDate}</div>
                  <div style={{ marginBottom: 8 }}><b>Ngày mục tiêu:</b> {latestPlan.goalDate}</div>
                  <div style={{ marginBottom: 8 }}>
                    <b>Trạng thái:</b>
                    <span style={{ marginLeft: 8, padding: '2px 12px', borderRadius: 8, background: latestPlan.status === 'ACTIVE' ? '#e7fbe9' : '#ffeaea', color: latestPlan.status === 'ACTIVE' ? '#22c55e' : '#ef4444', fontWeight: 800, textTransform: 'uppercase' }}>{latestPlan.status}</span>
                  </div>
                </div>
              )
            )}
          </div>
        </div>
        {/* Cột 2: Các tuần kế hoạch + cập nhật tiến độ */}
        <div style={{ flex: 1.3, minWidth: 320, maxWidth: 500, display: 'flex', flexDirection: 'column', gap: 16, border: '2px solid #e0e7ff', background: '#fff', borderRadius: 18, boxShadow: '0 4px 24px #2563eb22', padding: 0 }}>
          <div style={{
            background: 'transparent',
            borderRadius: 18,
            boxShadow: 'none',
            padding: 18,
            marginBottom: 0,
            transition: 'box-shadow 0.2s',
          }}>
            <h3 style={{ color: '#2563eb', fontWeight: 900, fontSize: 22, marginBottom: 18, textAlign: 'center', letterSpacing: 1 }}>Các tuần kế hoạch</h3>
            {loading ? <div style={{ textAlign: 'center', color: '#2563eb', fontWeight: 600 }}>Đang tải dữ liệu...</div> : (
              weeks.length === 0 ? <div style={{ textAlign: 'center', color: '#888', fontSize: 18 }}>Chưa có tuần nào.</div> : (
                <div>
                  <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 12 }}>
                    <button
                      onClick={() => setCurrentWeekIndex(i => Math.max(0, i - 1))}
                      disabled={currentWeekIndex === 0}
                      style={{ padding: '6px 18px', borderRadius: 8, border: 'none', background: '#e0e7ff', color: '#2563eb', fontWeight: 700, cursor: currentWeekIndex === 0 ? 'not-allowed' : 'pointer' }}
                    >← Tuần trước</button>
                    <span style={{ fontWeight: 700, color: '#2563eb', fontSize: 18 }}>
                      Tuần {weeks[currentWeekIndex].weekNumber} / {weeks.length}
                    </span>
                    <button
                      onClick={() => setCurrentWeekIndex(i => Math.min(weeks.length - 1, i + 1))}
                      disabled={currentWeekIndex === weeks.length - 1}
                      style={{ padding: '6px 18px', borderRadius: 8, border: 'none', background: '#e0e7ff', color: '#2563eb', fontWeight: 700, cursor: currentWeekIndex === weeks.length - 1 ? 'not-allowed' : 'pointer' }}
                    >Tuần sau →</button>
                  </div>
                  <div style={{
                    background: '#f8fafc', borderRadius: 14, marginBottom: 18, boxShadow: '0 2px 8px #0001', padding: '18px 24px',
                    fontWeight: 700, fontSize: 18, color: '#222', borderLeft: '6px solid #22c55e'
                  }}>
                    <div style={{ fontWeight: 800, fontSize: 20, marginBottom: 8, color: '#2563eb' }}>
                      Tuần {weeks[currentWeekIndex].weekNumber}: {weeks[currentWeekIndex].startDate} - {weeks[currentWeekIndex].endDate}
                    </div>
                    <div style={{ marginBottom: 8 }}>
                      <span style={{ background: '#e0f7fa', color: '#16a34a', borderRadius: 6, padding: '2px 10px', fontWeight: 700 }}>
                        🎯 {weeks[currentWeekIndex].targetCigarettesPerDay} điếu/ngày
                      </span>
                    </div>
                    <div style={{ marginBottom: 8, color: '#444' }}>
                      <b>Nội dung:</b> {weeks[currentWeekIndex].weeklyContent}
                    </div>
                  </div>
                  <button
                    style={{ marginTop: 8, background: '#22c55e', color: '#fff', border: 'none', borderRadius: 8, padding: '12px 32px', fontWeight: 700, fontSize: 18, cursor: 'pointer' }}
                    onClick={() => setShowProgressForm(true)}
                  >
                    Cập nhật tiến độ cai thuốc
                  </button>
                  {showProgressForm && (
                    <div className={styles.formOverlay}>
                      <form
                        onSubmit={async e => {
                          e.preventDefault();
                          setProgressLoading(true);
                          setProgressError('');
                          setProgressSuccess('');
                          setEncouragement('');
                          try {
                            const params = new URLSearchParams({
                              planId: latestPlan.planId.toString(),
                              date: progressForm.date,
                              cigarettesSmoked: progressForm.cigarettesSmoked.toString(),
                              cravingLevel: progressForm.cravingLevel.toString(),
                              moodLevel: progressForm.moodLevel.toString(),
                              exerciseMinutes: progressForm.exerciseMinutes.toString(),
                              notes: progressForm.notes,
                            });
                            await apiClient.post(`/progress/daily?${params.toString()}`, null);
                            setProgressSuccess('Cập nhật tiến độ thành công!');
                            const randomMsg = encouragements[Math.floor(Math.random() * encouragements.length)];
                            setEncouragement(randomMsg);
                            // Fetch lại tiến độ mới nhất
                            await fetchProgress();
                            toast.success(<div><div style={{fontWeight:700}}>Cập nhật tiến độ thành công!</div><div style={{marginTop:6, fontStyle:'italic', color:'#2563eb'}}>{randomMsg}</div></div>, {
                              position: 'top-center',
                              autoClose: 3500,
                              closeOnClick: true,
                              pauseOnHover: true,
                              style: { minWidth: 320, fontSize: 17, borderRadius: 12, fontWeight: 500 }
                            });
                            setShowProgressForm(false);
                          } catch (err) {
                            setProgressError('Cập nhật tiến độ thất bại!');
                          } finally {
                            setProgressLoading(false);
                          }
                        }}
                        className={styles.formContainer}
                      >
                        <button type="button" onClick={() => setShowProgressForm(false)} className={styles.closeBtn}>×</button>
                        <div className={styles.formTitle}>Cập nhật tiến độ cai thuốc</div>
                        <label className={styles.formLabel}>Ngày:
                          <input type="date" value={progressForm.date} onChange={e => setProgressForm(f => ({ ...f, date: e.target.value }))} required className={styles.formInput} />
                        </label>
                        <label className={styles.formLabel}>Số điếu đã hút:
                          <input type="number" value={progressForm.cigarettesSmoked} onChange={e => setProgressForm(f => ({ ...f, cigarettesSmoked: e.target.value }))} required className={styles.formInput} />
                        </label>
                        <label className={styles.formLabel}>Mức độ thèm:
                          <input type="number" min={1} max={10} value={progressForm.cravingLevel} onChange={e => setProgressForm(f => ({ ...f, cravingLevel: e.target.value }))} className={styles.formInput} />
                        </label>
                        <label className={styles.formLabel}>Tâm trạng:
                          <input type="number" min={1} max={10} value={progressForm.moodLevel} onChange={e => setProgressForm(f => ({ ...f, moodLevel: e.target.value }))} className={styles.formInput} />
                        </label>
                        <label className={styles.formLabel}>Phút vận động:
                          <input type="number" value={progressForm.exerciseMinutes} onChange={e => setProgressForm(f => ({ ...f, exerciseMinutes: e.target.value }))} className={styles.formInput} />
                        </label>
                        <label className={styles.formLabel}>Ghi chú:
                          <textarea value={progressForm.notes} onChange={e => setProgressForm(f => ({ ...f, notes: e.target.value }))} className={styles.formTextarea} placeholder="Nhập hoạt động, mẹo, cảm xúc..." />
                        </label>
                        {progressError && <div className={styles.formError}>{progressError}</div>}
                        {progressSuccess && <div className={styles.formSuccess}>{progressSuccess}</div>}
                        <button type="submit" disabled={progressLoading} className={styles.formButton}>
                          {progressLoading ? 'Đang gửi...' : 'Lưu tiến độ'}
                        </button>
                      </form>
                    </div>
                  )}
                </div>
              )
            )}
          </div>
        </div>
        {/* Cột 3: Bảng tiến độ */}
        <div style={{ flex: 1, minWidth: 320, maxWidth: 700, display: 'flex', flexDirection: 'column', gap: 16, border: '2px solid #e0e7ff', background: '#fff', borderRadius: 18, boxShadow: '0 4px 24px #2563eb22', padding: 0 }}>
          <div style={{
            width: '100%',
            background: 'transparent',
            borderRadius: 18,
            boxShadow: 'none',
            padding: 18,
            margin: '0 auto',
            maxWidth: '100%',
            overflowX: 'auto',
          }}>
            <h3 style={{ color: '#1976d2', fontWeight: 900, fontSize: 22, marginBottom: 18, textAlign: 'center', letterSpacing: 1 }}>Tiến độ cai thuốc theo tuần</h3>
            {/* Nút chuyển tuần */}
            <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', gap: 16, marginBottom: 12 }}>
              <button onClick={() => setProgressWeekIndex(i => Math.max(0, i - 1))} disabled={progressWeekIndex === 0} style={{ padding: '6px 18px', borderRadius: 8, border: 'none', background: '#e0e7ff', color: '#2563eb', fontWeight: 700, cursor: progressWeekIndex === 0 ? 'not-allowed' : 'pointer' }}>← Tuần trước</button>
              <span style={{ fontWeight: 700, color: '#2563eb', fontSize: 18 }}>
                Tuần {progressWeekIndex + 1} / {progressWeeks.length}
              </span>
              <button onClick={() => setProgressWeekIndex(i => Math.min(progressWeeks.length - 1, i + 1))} disabled={progressWeekIndex === progressWeeks.length - 1} style={{ padding: '6px 18px', borderRadius: 8, border: 'none', background: '#e0e7ff', color: '#2563eb', fontWeight: 700, cursor: progressWeekIndex === progressWeeks.length - 1 ? 'not-allowed' : 'pointer' }}>Tuần sau →</button>
            </div>
            {progressLoadingTable ? (
              <div style={{ textAlign: 'center', color: '#1976d2', fontWeight: 600 }}>Đang tải tiến độ...</div>
            ) : (
              <div style={{ overflowX: 'auto' }}>
                <table style={{ width: '100%', borderCollapse: 'collapse', background: '#f8fafc', borderRadius: 12, overflow: 'hidden', fontSize: 16, margin: '0 auto' }}>
                  <thead style={{ background: '#1976d2', color: '#fff' }}>
                    <tr>
                      <th style={{ padding: 12, textAlign: 'left', minWidth: 120, background: '#1976d2' }}></th>
                      {currentWeek.map((d, idx) => (
                        <th key={idx} style={{ padding: 12, textAlign: 'center' }}>
                          <span style={{ fontWeight: 700 }}>{d.getDate().toString().padStart(2, '0')}/{(d.getMonth()+1).toString().padStart(2, '0')}</span>
                        </th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {rowFields.map((field, idx) => (
                      <tr key={field}>
                        <td style={{
                          fontWeight: 700,
                          background: '#e0f2fe',
                          minWidth: 120,
                          textAlign: 'left',
                          padding: 10
                        }}>{rowLabels[idx]}</td>
                        {currentWeek.map((d, colIdx) => {
                          const item = progressList.find(p => {
                            const pd = new Date(p.date);
                            return pd.getFullYear() === d.getFullYear() && pd.getMonth() === d.getMonth() && pd.getDate() === d.getDate();
                          });
                          let value = '-';
                          if (item) {
                            value = item[field] !== undefined && item[field] !== null ? item[field] : '-';
                          }
                          // Nếu là cột Hoạt động (notes), dùng react-tooltip chuẩn
                          if (field === 'notes') {
                            return (
                              <td
                                key={colIdx}
                                style={{
                                  padding: 10,
                                  textAlign: 'center',
                                  maxWidth: 120,
                                  maxHeight: 40,
                                  overflow: 'hidden',
                                  textOverflow: 'ellipsis',
                                  whiteSpace: 'nowrap',
                                  cursor: value !== '-' ? 'pointer' : 'default',
                                  position: 'relative',
                                }}
                                data-tooltip-id="activity-tooltip"
                                data-tooltip-content={value !== '-' ? value : ''}
                              >
                                {value}
                              </td>
                            );
                          }
                          // Các cột khác giữ nguyên
                          return (
                            <td key={colIdx} style={{
                              padding: 10,
                              textAlign: 'center',
                              wordBreak: 'break-word',
                              maxWidth: field === 'notes' ? 180 : undefined,
                              whiteSpace: field === 'notes' ? 'pre-line' : undefined
                            }}>{value}</td>
                          );
                        })}
                      </tr>
                    ))}
                  </tbody>
                  <tfoot>
                    <tr>
                      <td colSpan={8} style={{ textAlign: 'left', padding: 8, fontStyle: 'italic', color: '#888', background: '#f1f5f9' }}>
                        <b>Ghi chú:</b> "Hoạt động" là các việc bạn đã làm được trong ngày, có thể rất dài. Các ô trống là chưa có dữ liệu cho ngày đó.
                      </td>
                    </tr>
                  </tfoot>
                </table>
              </div>
            )}
          </div>
          {/* Biểu đồ số điếu thuốc */}
          <div style={{ width: '100%', height: 260, background: '#f8fafc', borderRadius: 12, boxShadow: '0 2px 8px #0001', padding: 12, marginTop: 8 }}>
            <h4 style={{ color: '#1976d2', fontWeight: 800, fontSize: 18, marginBottom: 8, textAlign: 'center' }}>Biểu đồ số điếu thuốc theo thời gian</h4>
            <ResponsiveContainer width="100%" height={200}>
              <LineChart data={progressList.map(p => ({ date: p.date, cigarettes: Number(p.cigarettesSmoked) }))} margin={{ top: 10, right: 20, left: 0, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="date" tick={{ fontSize: 12 }} />
                <YAxis allowDecimals={false} tick={{ fontSize: 12 }} />
                <Tooltip formatter={(value) => `${value} điếu`} labelFormatter={label => `Ngày: ${label}`} />
                <Line type="monotone" dataKey="cigarettes" stroke="#1976d2" strokeWidth={3} dot={{ r: 4 }} activeDot={{ r: 6 }} />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>
      <ReactTooltip
        id="activity-tooltip"
        place="top"
        style={{
          maxWidth: 300,
          whiteSpace: 'pre-line',
          fontSize: 15,
          borderRadius: 8,
          background: '#222',
          color: '#fff',
          padding: '10px 16px',
          zIndex: 9999,
        }}
      />
    </div>
  );
};

export default MyQuitPlansPage; 