import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import apiClient from '../api/apiClient';
import dayjs from 'dayjs';
import { getMemberProfileForCoach } from '../api/services/userService';
import { toast } from 'react-toastify';
import ReactModal from 'react-modal';

ReactModal.setAppElement('#root');

interface Plan {
  planId: number;
  title: string;
  description: string;
  accountId: number;
  accountName: string;
  startDate: string;
  goalDate: string;
  initialCigarettesPerDay: number | null;
  targetCigarettesPerDay: number;
  initialCostPerPack: number | null;
  status: string;
}

const CreatePlanPage = () => {
  const { memberId } = useParams();
  const navigate = useNavigate();
  const [form, setForm] = useState({
    title: '',
    description: '',
    startDate: '',
    goalDate: '',
  });
  const [formError, setFormError] = useState('');
  const [formLoading, setFormLoading] = useState(false);
  // State cho danh sách tuần
  const [weeks, setWeeks] = useState<any[]>([]);
  const [weekFormError, setWeekFormError] = useState('');
  const [weekSuccess, setWeekSuccess] = useState('');
  const [expandedWeek, setExpandedWeek] = useState<number | null>(null);
  const [currentPlan, setCurrentPlan] = useState<any>(null);
  const [currentWeeks, setCurrentWeeks] = useState<any[]>([]);
  const [showCreateForm, setShowCreateForm] = useState(true);

  // Thêm state cho editForm, editWeeks, editError, editSuccess, editLoading
  const [editForm, setEditForm] = useState({ title: '', description: '', startDate: '', goalDate: '' });
  const [editWeeks, setEditWeeks] = useState<any[]>([]);
  const [editError, setEditError] = useState('');
  const [editSuccess, setEditSuccess] = useState('');
  const [editLoading, setEditLoading] = useState(false);

  // Tính ngày bắt đầu/kết thúc cho tuần mới
  const getNextWeekDates = () => {
    if (!form.startDate || !form.goalDate) return { startDate: '', endDate: '' };
    const start = new Date(form.startDate);
    const goal = new Date(form.goalDate);
    let weekStart = new Date(start);
    if (weeks.length > 0) {
      weekStart = new Date(weeks[weeks.length - 1].endDate);
      weekStart.setDate(weekStart.getDate() + 1);
    }
    let weekEnd = new Date(weekStart);
    weekEnd.setDate(weekEnd.getDate() + 6);
    if (weekEnd > goal) weekEnd = new Date(goal);
    if (weekStart > goal) return { startDate: '', endDate: '' };
    return {
      startDate: weekStart.toISOString().slice(0, 10),
      endDate: weekEnd.toISOString().slice(0, 10),
    };
  };

  // Thêm tuần mới
  const handleAddWeek = () => {
    const { startDate, endDate } = getNextWeekDates();
    if (!startDate || !endDate) return;
    setWeeks([
      ...weeks,
      {
        startDate,
        endDate,
        targetCigarettesPerDay: 0,
        weeklyContent: '',
      },
    ]);
    setExpandedWeek(weeks.length); // Mở accordion tuần mới
  };

  // Xử lý thay đổi input trong tuần
  const handleWeekInputChange = (idx: number, field: string, value: any) => {
    setWeeks(weeks.map((w, i) => i === idx ? { ...w, [field]: value } : w));
  };

  // Accordion toggle
  const handleAccordionToggle = (idx: number) => {
    setExpandedWeek(expandedWeek === idx ? null : idx);
  };

  // Thêm hàm chia tuần tự động
  function splitIntoWeeks(startDateStr: string, endDateStr: string) {
    if (!startDateStr || !endDateStr) return [];
    const weeks = [];
    let start = new Date(startDateStr);
    const end = new Date(endDateStr);
    let weekIndex = 1;
    while (start <= end) {
      const weekStart = new Date(start);
      const weekEnd = new Date(start);
      weekEnd.setDate(weekEnd.getDate() + 6);
      if (weekEnd > end) weekEnd.setTime(end.getTime());
      weeks.push({
        startDate: weekStart.toISOString().slice(0, 10),
        endDate: weekEnd.toISOString().slice(0, 10),
        targetCigarettesPerDay: 0,
        weeklyContent: '',
        weekNumber: weekIndex,
      });
      start.setDate(start.getDate() + 7);
      weekIndex++;
    }
    return weeks;
  }

  // State cho form tạo tuần
  const [memberInfo, setMemberInfo] = useState<any>(null);
  const [profileLoading, setProfileLoading] = useState(true);
  const [editMode, setEditMode] = useState(false);
  const [updatingStatus, setUpdatingStatus] = useState(false);
  const [showActivePlanModal, setShowActivePlanModal] = useState(false);
  const [currentWeekIndex, setCurrentWeekIndex] = useState(0);

  useEffect(() => {
    fetchMemberInfo();
    checkExistingPlan();
    // eslint-disable-next-line
  }, [memberId]);

  useEffect(() => {
    if (form.startDate && form.goalDate) {
      setWeeks(splitIntoWeeks(form.startDate, form.goalDate));
    } else {
      setWeeks([]);
    }
  }, [form.startDate, form.goalDate]);

  // Reset currentWeekIndex khi số tuần thay đổi:
  useEffect(() => { setCurrentWeekIndex(0); }, [weeks.length, editWeeks.length, currentWeeks.length, editMode, showCreateForm]);

  // Tự động chia lại tuần khi cập nhật kế hoạch tổng
  useEffect(() => {
    if (editMode && editForm.startDate && editForm.goalDate) {
      // Nếu số tuần cũ khác số tuần mới, hoặc ngày thay đổi thì reset lại các tuần
      const newWeeks = splitIntoWeeks(editForm.startDate, editForm.goalDate);
      // Nếu số tuần không đổi, giữ lại dữ liệu mục tiêu/ngày và nội dung tuần cũ
      setEditWeeks(prevWeeks => {
        return newWeeks.map((w, idx) => ({
          ...w,
          // Giữ lại dữ liệu cũ nếu có
          targetCigarettesPerDay: prevWeeks[idx]?.targetCigarettesPerDay || 0,
          weeklyContent: prevWeeks[idx]?.weeklyContent || '',
          planDetailId: prevWeeks[idx]?.planDetailId,
        }));
      });
    }
    // eslint-disable-next-line
  }, [editForm.startDate, editForm.goalDate, editMode]);

  const fetchMemberInfo = async () => {
    setProfileLoading(true);
    try {
      const info = await getMemberProfileForCoach(Number(memberId));
      setMemberInfo(info);
    } catch {
      setMemberInfo(null);
    } finally {
      setProfileLoading(false);
    }
  };

  // Hàm kiểm tra member đã có kế hoạch chưa
  const checkExistingPlan = async () => {
    try {
      // Gọi API lấy danh sách kế hoạch của member
      const res = await apiClient.get(`/plans/account/${memberId}/plans`);
      if (Array.isArray(res.data) && res.data.length > 0) {
        // Lọc lấy kế hoạch có ngày tạo gần nhất (mới nhất)
        const latestPlan = res.data
          .slice()
          .sort((a: any, b: any) => {
            const dateB = new Date(b.createdDate || b.startDate).getTime();
            const dateA = new Date(a.createdDate || a.startDate).getTime();
            return dateB - dateA;
          })[0];
        setCurrentPlan(latestPlan);
        const weeksRes = await apiClient.get(`/plans/${latestPlan.planId}/weeks`);
        setCurrentWeeks(weeksRes.data);
        setShowCreateForm(false);
      } else {
        setCurrentPlan(null);
        setCurrentWeeks([]);
        setShowCreateForm(true);
      }
    } catch (err) {
      setCurrentPlan(null);
      setCurrentWeeks([]);
      setShowCreateForm(true);
    }
  };

  const validate = () => {
    if (!form.title.trim()) return 'Tiêu đề không được để trống';
    if (form.title.length > 255) return 'Tiêu đề không quá 255 ký tự';
    if (!form.description.trim()) return 'Mô tả không được để trống';
    if (!form.startDate) return 'Ngày bắt đầu không được để trống';
    if (!form.goalDate) return 'Ngày mục tiêu không được để trống';
    if (weeks.length === 0) return 'Bạn phải thêm ít nhất 1 tuần';
    return '';
  };
  // Validate từng tuần
  const validateWeeks = () => {
    for (let i = 0; i < weeks.length; i++) {
      if (Number(weeks[i].targetCigarettesPerDay) < 0) return `Mục tiêu số điếu tuần ${i + 1} không được âm`;
      if (!weeks[i].weeklyContent.trim()) return `Nội dung tuần ${i + 1} không được để trống`;
    }
    return '';
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const fetchPlanAndWeeks = async (planId: number) => {
    try {
      const planRes = await apiClient.get(`/plans/${planId}`);
      setCurrentPlan(planRes.data);
      const weeksRes = await apiClient.get(`/plans/${planId}/weeks`);
      setCurrentWeeks(weeksRes.data);
    } catch (err) {
      setCurrentPlan(null);
      setCurrentWeeks([]);
    }
  };

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setFormError('');
    setWeekFormError('');
    setWeekSuccess('');
    const err1 = validate();
    const err2 = validateWeeks();
    if (err1) return setFormError(err1);
    if (err2) return setWeekFormError(err2);
    setFormLoading(true);
    try {
      // 1. Gọi API tạo kế hoạch tổng
      const res = await apiClient.post(`/plans/account/${memberId}/create`, {
        title: form.title,
        description: form.description,
        startDate: form.startDate,
        goalDate: form.goalDate,
      });
      const planId = res.data?.planId || res.data?.id;
      // 2. Gọi API tạo tuần cho từng tuần
      for (const w of weeks) {
        await apiClient.post(`/plans/${planId}/weeks`, {
          startDate: w.startDate,
          endDate: w.endDate,
          targetCigarettesPerDay: Number(w.targetCigarettesPerDay),
          weeklyContent: w.weeklyContent,
        });
      }
      setForm({ title: '', description: '', startDate: '', goalDate: '' });
      setWeeks([]);
      setWeekSuccess('Tạo kế hoạch và các tuần thành công!');
      // Lấy lại kế hoạch vừa tạo và các tuần
      await fetchPlanAndWeeks(planId);
      setShowCreateForm(false);
    } catch (err: any) {
      setFormError('Tạo kế hoạch hoặc tuần thất bại!');
    } finally {
      setFormLoading(false);
    }
  };

  let middleColumn = null;
  const weeksToShow = editMode ? editWeeks : (showCreateForm ? weeks : currentWeeks);

  if (editMode) {
    middleColumn = (
      <div style={{ flex: 1, maxWidth: 500, background: '#fff', borderRadius: 18, boxShadow: '0 4px 24px #0001', padding: 32, marginBottom: 32, zIndex: 1, minWidth: 350 }}>
        <h3 style={{ color: '#2563eb', fontWeight: 800, fontSize: 22, marginBottom: 18, textAlign: 'center' }}>CẬP NHẬT CÁC TUẦN KẾ HOẠCH</h3>
        {weeksToShow.length === 0 ? (
          <div style={{ color: '#888', textAlign: 'center', marginBottom: 18 }}>Chưa có tuần nào.</div>
        ) : (
          <div>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 12 }}>
              <button
                onClick={() => setCurrentWeekIndex(i => Math.max(0, i - 1))}
                disabled={currentWeekIndex === 0}
                style={{ padding: '6px 18px', borderRadius: 8, border: 'none', background: '#e0e7ff', color: '#2563eb', fontWeight: 700, cursor: currentWeekIndex === 0 ? 'not-allowed' : 'pointer' }}
              >← Tuần trước</button>
              <span style={{ fontWeight: 700, color: '#2563eb', fontSize: 18 }}>
                Tuần {weeksToShow[currentWeekIndex].weekNumber || currentWeekIndex + 1} / {weeksToShow.length}
              </span>
              <button
                onClick={() => setCurrentWeekIndex(i => Math.min(weeksToShow.length - 1, i + 1))}
                disabled={currentWeekIndex === weeksToShow.length - 1}
                style={{ padding: '6px 18px', borderRadius: 8, border: 'none', background: '#e0e7ff', color: '#2563eb', fontWeight: 700, cursor: currentWeekIndex === weeksToShow.length - 1 ? 'not-allowed' : 'pointer' }}
              >Tuần sau →</button>
            </div>
            {/* Hiển thị tuần hiện tại */}
            <div key={weeksToShow[currentWeekIndex].planDetailId || currentWeekIndex} style={{ marginBottom: 18, borderRadius: 10, boxShadow: '0 2px 8px #2563eb22', border: '1px solid #2563eb', background: '#e3f0fa' }}>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', background: '#2196f3', color: '#fff', borderRadius: '10px 10px 0 0', padding: '12px 18px' }}>
                <span style={{ fontWeight: 700, fontSize: 18 }}>🗓️ Tuần {weeksToShow[currentWeekIndex].weekNumber || currentWeekIndex + 1}: {weeksToShow[currentWeekIndex].startDate} - {weeksToShow[currentWeekIndex].endDate}</span>
              </div>
              <div style={{ padding: 18, background: '#f6fbff', borderRadius: '0 0 10px 10px' }}>
                <div style={{ marginBottom: 12 }}>
                  <label style={{ fontWeight: 700 }}>Mục tiêu số điếu/ngày:<br />
                    <input type="number" value={weeksToShow[currentWeekIndex].targetCigarettesPerDay} onChange={e => setEditWeeks(ws => ws.map((ww, i) => i === currentWeekIndex ? { ...ww, targetCigarettesPerDay: e.target.value } : ww))} min={0} required style={{ width: '100%', padding: 10, borderRadius: 8, border: '1px solid #cbd5e1', marginTop: 6, fontSize: 16 }} placeholder="0" />
                  </label>
                </div>
                <div style={{ marginBottom: 12 }}>
                  <label style={{ fontWeight: 700 }}>Nội dung tuần:<br />
                    <textarea value={weeksToShow[currentWeekIndex].weeklyContent} onChange={e => setEditWeeks(ws => ws.map((ww, i) => i === currentWeekIndex ? { ...ww, weeklyContent: e.target.value } : ww))} required rows={4} style={{ width: '100%', padding: 10, borderRadius: 8, border: '1px solid #cbd5e1', marginTop: 6, fontSize: 16, minHeight: 60 }} placeholder="Nhập nội dung tuần..." />
                  </label>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    );
  } else {
    middleColumn = (
      <div style={{ flex: 1, maxWidth: 500, background: '#fff', borderRadius: 18, boxShadow: '0 4px 24px #0001', padding: 32, marginBottom: 32, zIndex: 1, minWidth: 350 }}>
        <h3 style={{ color: '#2563eb', fontWeight: 800, fontSize: 22, marginBottom: 18, textAlign: 'center' }}>CÁC TUẦN KẾ HOẠCH</h3>
        {weeksToShow.length === 0 ? (
          <div style={{ color: '#888', textAlign: 'center', marginBottom: 18 }}>Chưa có tuần nào.</div>
        ) : (
          <div>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 12 }}>
              <button
                onClick={() => setCurrentWeekIndex(i => Math.max(0, i - 1))}
                disabled={currentWeekIndex === 0}
                style={{ padding: '6px 18px', borderRadius: 8, border: 'none', background: '#e0e7ff', color: '#2563eb', fontWeight: 700, cursor: currentWeekIndex === 0 ? 'not-allowed' : 'pointer' }}
              >← Tuần trước</button>
              <span style={{ fontWeight: 700, color: '#2563eb', fontSize: 18 }}>
                Tuần {weeksToShow[currentWeekIndex].weekNumber || currentWeekIndex + 1} / {weeksToShow.length}
              </span>
              <button
                onClick={() => setCurrentWeekIndex(i => Math.min(weeksToShow.length - 1, i + 1))}
                disabled={currentWeekIndex === weeksToShow.length - 1}
                style={{ padding: '6px 18px', borderRadius: 8, border: 'none', background: '#e0e7ff', color: '#2563eb', fontWeight: 700, cursor: currentWeekIndex === weeksToShow.length - 1 ? 'not-allowed' : 'pointer' }}
              >Tuần sau →</button>
            </div>
            {/* Hiển thị tuần hiện tại */}
            <div key={weeksToShow[currentWeekIndex].planDetailId || currentWeekIndex} style={{ marginBottom: 18, borderRadius: 10, boxShadow: '0 2px 8px #2563eb22', border: '1px solid #2563eb', background: '#e3f0fa' }}>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', background: '#2196f3', color: '#fff', borderRadius: '10px 10px 0 0', padding: '12px 18px' }}>
                <span style={{ fontWeight: 700, fontSize: 18 }}>🗓️ Tuần {weeksToShow[currentWeekIndex].weekNumber || currentWeekIndex + 1}: {weeksToShow[currentWeekIndex].startDate} - {weeksToShow[currentWeekIndex].endDate}</span>
              </div>
              <div style={{ padding: 18, background: '#f6fbff', borderRadius: '0 0 10px 10px' }}>
                <div style={{ marginBottom: 12 }}>
                  <span style={{ fontWeight: 700 }}>Mục tiêu số điếu/ngày: {weeksToShow[currentWeekIndex].targetCigarettesPerDay}</span>
                </div>
                <div style={{ marginBottom: 12 }}>
                  <span style={{ fontWeight: 700 }}>Nội dung tuần: {weeksToShow[currentWeekIndex].weeklyContent}</span>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    );
  }

  return (
    <div style={{ minHeight: '100vh', width: '100vw', display: 'flex', alignItems: 'flex-start', justifyContent: 'center', background: `url('/images/non-smoking.jpg') center/cover no-repeat fixed, #e0f2fe`, position: 'relative', paddingTop: 60, gap: 40 }}>
      <div style={{ position: 'fixed', top: 0, left: 0, width: '100vw', height: '100vh', background: 'rgba(255,255,255,0.75)', zIndex: 0, pointerEvents: 'none' }} />
      {/* Cột trái: Thông tin member */}
      <div style={{ flex: '0 0 320px', background: '#fff', borderRadius: 18, boxShadow: '0 4px 24px #0001', padding: 32, display: 'flex', flexDirection: 'column', alignItems: 'center', minWidth: 280, marginBottom: 32, height: '100%', zIndex: 1 }}>
        {profileLoading ? (
          <div style={{ color: '#2563eb', fontWeight: 600 }}>Đang tải profile...</div>
        ) : memberInfo ? (
          memberInfo.account ? (
            <>
              <img src={memberInfo.account.image || '/public/images/non-smoking.jpg'} alt="avatar" style={{ width: 100, height: 100, borderRadius: '50%', objectFit: 'cover', marginBottom: 16 }} />
              <div style={{ fontWeight: 900, fontSize: 24, color: '#2563eb', marginBottom: 8 }}>{memberInfo.account.name || memberInfo.account.email || 'Member'}</div>
              <div style={{ color: '#666', marginBottom: 4 }}>{memberInfo.account.email}</div>
              <div style={{ color: '#888', marginBottom: 4 }}>Tuổi: {memberInfo.account.age || '-'}</div>
              <div style={{ color: '#888', marginBottom: 4 }}>Giới tính: {memberInfo.account.gender === 'Male' ? 'Nam' : memberInfo.account.gender === 'Female' ? 'Nữ' : '-'}</div>
            </>
          ) : (
            <>
              <img src={memberInfo.avatarUrl || memberInfo.image || '/public/images/non-smoking.jpg'} alt="avatar" style={{ width: 100, height: 100, borderRadius: '50%', objectFit: 'cover', marginBottom: 16 }} />
              <div style={{ fontWeight: 900, fontSize: 24, color: '#2563eb', marginBottom: 8 }}>{memberInfo.fullName || memberInfo.name || memberInfo.email || 'Member'}</div>
              <div style={{ color: '#666', marginBottom: 4 }}>{memberInfo.email}</div>
              <div style={{ color: '#888', marginBottom: 4 }}>Tuổi: {memberInfo.age || '-'}</div>
              <div style={{ color: '#888', marginBottom: 4 }}>Giới tính: {memberInfo.gender || '-'}</div>
            </>
          )
        ) : (
          <div style={{ color: '#ef4444', fontWeight: 600 }}>Không thể tải thông tin member</div>
        )}
        </div>
        {/* Cột giữa: Các tuần kế hoạch */}
        {middleColumn}
        {/* Cột phải: Form tổng kế hoạch hoặc thông tin tổng */}
        <div style={{ flex: 1, maxWidth: 500, background: '#fff', borderRadius: 18, boxShadow: '0 4px 24px #0001', padding: 32, marginBottom: 32, zIndex: 1, minWidth: 350 }}>
          {showCreateForm ? (
            <>
              <h2 style={{ fontSize: 28, fontWeight: 900, color: '#22c55e', marginBottom: 24, textAlign: 'center', letterSpacing: 1 }}>TẠO KẾ HOẠCH CAI THUỐC</h2>
              <form onSubmit={handleSubmit}>
                <div style={{ marginBottom: 18 }}>
                  <label style={{ fontWeight: 700 }}>Tiêu đề:<br />
                    <input name="title" value={form.title} onChange={handleChange} maxLength={255} required style={{ width: '100%', padding: 12, borderRadius: 8, border: '1px solid #cbd5e1', marginTop: 6, fontSize: 16 }} placeholder="Nhập tiêu đề..." />
                  </label>
                </div>
                <div style={{ marginBottom: 18 }}>
                  <label style={{ fontWeight: 700 }}>Mô tả:<br />
                    <textarea name="description" value={form.description} onChange={handleChange} required rows={6} style={{ width: '100%', padding: 12, borderRadius: 8, border: '1px solid #cbd5e1', marginTop: 6, fontSize: 16, minHeight: 100 }} placeholder="Nhập mô tả..." />
                  </label>
                </div>
                <div style={{ marginBottom: 18, display: 'flex', gap: 16 }}>
                  <label style={{ flex: 1, fontWeight: 700 }}>Ngày bắt đầu:<br />
                    <input type="date" name="startDate" value={form.startDate} onChange={handleChange} required style={{ width: '100%', padding: 12, borderRadius: 8, border: '1px solid #cbd5e1', marginTop: 6, fontSize: 16 }} />
                  </label>
                  <label style={{ flex: 1, fontWeight: 700 }}>Ngày mục tiêu:<br />
                    <input type="date" name="goalDate" value={form.goalDate} onChange={handleChange} required style={{ width: '100%', padding: 12, borderRadius: 8, border: '1px solid #cbd5e1', marginTop: 6, fontSize: 16 }} />
                  </label>
                </div>
                {formError && <div style={{ color: 'red', marginBottom: 14, textAlign: 'center', fontWeight: 600 }}>{formError}</div>}
                <div style={{ display: 'flex', gap: 16, marginTop: 32 }}>
                  <button type="submit" disabled={formLoading} style={{ flex: 1, background: 'linear-gradient(90deg,#22c55e,#16a34a)', color: '#fff', border: 'none', borderRadius: 10, padding: '14px 0', fontWeight: 800, fontSize: 18, cursor: 'pointer', boxShadow: '0 2px 8px #22c55e22', textTransform: 'uppercase', letterSpacing: 1, transition: 'background 0.2s' }}>{formLoading ? 'Đang tạo...' : 'Tạo kế hoạch'}</button>
                </div>
              </form>
            </>
          ) : currentPlan ? (
            editMode ? (
              <>
                <h2 style={{ fontSize: 28, fontWeight: 900, color: '#2563eb', marginBottom: 24, textAlign: 'center', letterSpacing: 1 }}>CẬP NHẬT KẾ HOẠCH</h2>
                <form
                  onSubmit={async e => {
                    e.preventDefault();
                    setEditError('');
                    setEditSuccess('');
                    setEditLoading(true);
                    try {
                      // PUT kế hoạch tổng
                      await apiClient.put(`/plans/${currentPlan.planId}`, {
                        title: editForm.title,
                        description: editForm.description,
                        startDate: editForm.startDate,
                        goalDate: editForm.goalDate,
                      });
                      // PUT từng tuần (nếu có planDetailId thì PUT, nếu chưa có thì POST)
                      await Promise.all(
                        editWeeks.map(w =>
                          w.planDetailId
                            ? apiClient.put(`/plans/weeks/${w.planDetailId}`, {
                                startDate: w.startDate,
                                endDate: w.endDate,
                                targetCigarettesPerDay: Number(w.targetCigarettesPerDay),
                                weeklyContent: w.weeklyContent,
                              })
                            : apiClient.post(`/plans/${currentPlan.planId}/weeks`, {
                                startDate: w.startDate,
                                endDate: w.endDate,
                                targetCigarettesPerDay: Number(w.targetCigarettesPerDay),
                                weeklyContent: w.weeklyContent,
                              })
                        )
                      );
                      setEditSuccess('Cập nhật kế hoạch thành công!');
                      await fetchPlanAndWeeks(currentPlan.planId);
                      setEditMode(false);
                    } catch (err) {
                      setEditError('Cập nhật kế hoạch thất bại!');
                    } finally {
                      setEditLoading(false);
                    }
                  }}
                >
                  <div style={{ marginBottom: 18 }}>
                    <label style={{ fontWeight: 700 }}>Tiêu đề:<br />
                      <input name="title" value={editForm.title} onChange={e => setEditForm(f => ({ ...f, title: e.target.value }))} required maxLength={255} style={{ width: '100%', padding: 12, borderRadius: 8, border: '1px solid #cbd5e1', marginTop: 6, fontSize: 16 }} placeholder="Nhập tiêu đề..." />
                    </label>
                  </div>
                  <div style={{ marginBottom: 18 }}>
                    <label style={{ fontWeight: 700 }}>Mô tả:<br />
                      <textarea name="description" value={editForm.description} onChange={e => setEditForm(f => ({ ...f, description: e.target.value }))} required rows={6} style={{ width: '100%', padding: 12, borderRadius: 8, border: '1px solid #cbd5e1', marginTop: 6, fontSize: 16, minHeight: 100 }} placeholder="Nhập mô tả..." />
                    </label>
                  </div>
                  <div style={{ marginBottom: 18, display: 'flex', gap: 16 }}>
                    <label style={{ flex: 1, fontWeight: 700 }}>Ngày bắt đầu:<br />
                      <input type="date" name="startDate" value={editForm.startDate} onChange={e => setEditForm(f => ({ ...f, startDate: e.target.value }))} required style={{ width: '100%', padding: 12, borderRadius: 8, border: '1px solid #cbd5e1', marginTop: 6, fontSize: 16 }} />
                    </label>
                    <label style={{ flex: 1, fontWeight: 700 }}>Ngày mục tiêu:<br />
                      <input type="date" name="goalDate" value={editForm.goalDate} onChange={e => setEditForm(f => ({ ...f, goalDate: e.target.value }))} required style={{ width: '100%', padding: 12, borderRadius: 8, border: '1px solid #cbd5e1', marginTop: 6, fontSize: 16 }} />
                    </label>
                  </div>
                  <div style={{ display: 'flex', gap: 16, marginTop: 32 }}>
                    <button type="submit" disabled={editLoading} style={{ flex: 1, background: 'linear-gradient(90deg,#22c55e,#16a34a)', color: '#fff', border: 'none', borderRadius: 10, padding: '14px 0', fontWeight: 800, fontSize: 18, cursor: 'pointer', boxShadow: '0 2px 8px #22c55e22', textTransform: 'uppercase', letterSpacing: 1, transition: 'background 0.2s' }}>{editLoading ? 'Đang lưu...' : 'Lưu cập nhật'}</button>
                    <button type="button" onClick={() => setEditMode(false)} style={{ flex: 1, background: 'linear-gradient(90deg,#64748b,#94a3b8)', color: '#fff', border: 'none', borderRadius: 10, padding: '14px 0', fontWeight: 800, fontSize: 18, cursor: 'pointer', boxShadow: '0 2px 8px #64748b22', textTransform: 'uppercase', letterSpacing: 1, transition: 'background 0.2s' }}>Hủy</button>
                  </div>
                </form>
              </>
            ) : (
              <>
                <h2 style={{ fontSize: 28, fontWeight: 900, color: '#2563eb', marginBottom: 24, textAlign: 'center', letterSpacing: 1 }}>KẾ HOẠCH ĐÃ TẠO</h2>
                <div style={{ marginBottom: 18 }}><b>Tiêu đề:</b> {currentPlan.title}</div>
                <div style={{ marginBottom: 18 }}><b>Mô tả:</b> {currentPlan.description}</div>
                <div style={{ marginBottom: 18 }}><b>Ngày bắt đầu:</b> {currentPlan.startDate}</div>
                <div style={{ marginBottom: 18 }}><b>Ngày mục tiêu:</b> {currentPlan.goalDate}</div>
                <div style={{ marginBottom: 18 }}><b>Trạng thái:</b> {currentPlan.status}</div>
                <button
                  style={{ marginTop: 24, background: '#22c55e', color: '#fff', border: 'none', borderRadius: 8, padding: '12px 32px', fontWeight: 700, fontSize: 18, cursor: 'pointer', width: '100%' }}
                  onClick={() => {
                    setEditMode(true);
                    setEditForm({
                      title: currentPlan.title,
                      description: currentPlan.description,
                      startDate: currentPlan.startDate,
                      goalDate: currentPlan.goalDate,
                    });
                    setEditWeeks(currentWeeks.map(w => ({ ...w })));
                  }}
                >Cập nhật kế hoạch</button>
              </>
            )
          ) : null}
        </div>
      </div>
    );
}

export default CreatePlanPage;