import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import apiClient from '../api/apiClient';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, BarChart, Bar, ReferenceArea } from 'recharts';
import { getUserProfile, UserProfile, getMemberProfileForCoach } from '../api/services/userService';
import dayjs from 'dayjs';

interface HealthProfile {
  healthProfileId: number;
  accountId: number;
  coachId: number;
  startDate: string;
  healthInfo: string;
  lungCapacity: number;
  heartRate: number;
  bloodPressure: string;
  healthScore?: number;
  coachNotes: string;
}

const CoachMemberDetailPage = () => {
  const { memberId } = useParams();
  const navigate = useNavigate();
  const [healthProfiles, setHealthProfiles] = useState<HealthProfile[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [openId, setOpenId] = useState<number | null>(null);
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState({
    startDate: '',
    healthInfo: '',
    lungCapacity: '',
    heartRate: '',
    bloodPressure: '',
    coachNotes: ''
  });
  const [editingId, setEditingId] = useState<number | null>(null);
  const [memberInfo, setMemberInfo] = useState<any>(null);
  const [formError, setFormError] = useState<string | null>(null);
  const [showPlanModal, setShowPlanModal] = useState(false);
  const [planForm, setPlanForm] = useState({
    title: '',
    description: '',
    startDate: '',
    goalDate: '',
  });
  const [planFormError, setPlanFormError] = useState<string | null>(null);
  const [planLoading, setPlanLoading] = useState(false);

  useEffect(() => {
    fetchHealthHistory();
    fetchMemberInfo();
  }, [memberId]);

  const fetchHealthHistory = async () => {
    setLoading(true);
    try {
      const res = await apiClient.get(`/health-profile/account/${memberId}/history`);
      setHealthProfiles(res.data);
    } catch (e) {
      setError('Không thể tải lịch sử sức khỏe');
      setHealthProfiles([]);
    } finally {
      setLoading(false);
    }
  };

  const fetchMemberInfo = async () => {
    if (!memberId) return;
    try {
      const info = await getMemberProfileForCoach(Number(memberId));
      setMemberInfo(info);
    } catch (e) {
      setMemberInfo(null);
    }
  };

  const handleEdit = (profile: HealthProfile) => {
    setEditingId(profile.healthProfileId);
    setForm({
      startDate: profile.startDate,
      healthInfo: profile.healthInfo,
      lungCapacity: profile.lungCapacity.toString(),
      heartRate: profile.heartRate.toString(),
      bloodPressure: profile.bloodPressure,
      coachNotes: profile.coachNotes || ''
    });
    setShowForm(true);
  };

  const handleDelete = async (healthProfileId: number) => {
    if (!window.confirm('Bạn có chắc muốn xóa health profile này?')) return;
    try {
      await apiClient.delete(`/health-profile/delete/${healthProfileId}`);
      fetchHealthHistory();
      if (openId === healthProfileId) setOpenId(null);
    } catch (e) {
      setError('Xóa health profile thất bại');
    }
  };

  const handleCreate = () => {
    setEditingId(null);
    setForm({ startDate: '', healthInfo: '', lungCapacity: '', heartRate: '', bloodPressure: '', coachNotes: '' });
    setShowForm(true);
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const validateForm = () => {
    if (!form.healthInfo.trim()) return 'Vui lòng nhập thông tin sức khỏe.';
    const lung = Number(form.lungCapacity);
    if (isNaN(lung) || lung < 1000 || lung > 8000) return 'Dung tích phổi phải từ 1000 đến 8000 ml.';
    const heart = Number(form.heartRate);
    if (isNaN(heart) || heart < 40 || heart > 200) return 'Nhịp tim phải từ 40 đến 200 bpm.';
    if (!/^\d{2,3}\/\d{2,3}$/.test(form.bloodPressure)) return 'Huyết áp phải có format XXX/XX (VD: 120/80)';
    if (form.coachNotes.length > 2000) return 'Ghi chú không được quá 2000 ký tự.';
    return null;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setFormError(null);
    const errorMsg = validateForm();
    if (errorMsg) {
      setFormError(errorMsg);
      return;
    }
    try {
      if (editingId) {
      await apiClient.put(`/health-profile/update/${editingId}`, {
        ...form,
        lungCapacity: Number(form.lungCapacity),
        heartRate: Number(form.heartRate)
      });
      } else {
        await apiClient.post(`/health-profile/account/${memberId}/create`, {
          healthInfo: form.healthInfo,
          lungCapacity: Number(form.lungCapacity),
          heartRate: Number(form.heartRate),
          bloodPressure: form.bloodPressure,
          coachNotes: form.coachNotes
        });
        // Sau khi tạo hồ sơ mới, cập nhật lại memberInfo để số lần khám thay đổi ngay
        fetchMemberInfo();
      }
      setShowForm(false);
      setEditingId(null);
      setForm({ startDate: '', healthInfo: '', lungCapacity: '', heartRate: '', bloodPressure: '', coachNotes: '' });
      fetchHealthHistory();
    } catch (e) {
      setError(editingId ? 'Cập nhật health profile thất bại' : 'Tạo health profile thất bại');
    }
  };

  const validateWeekForm = () => {
    if (!weekForm.startDate) return 'Ngày bắt đầu không được để trống';
    if (!weekForm.endDate) return 'Ngày kết thúc không được để trống';
    if (Number(weekForm.targetCigarettesPerDay) < 0) return 'Mục tiêu số điếu không được âm';
    if (!weekForm.weeklyContent.trim()) return 'Nội dung tuần không được để trống';
    return null;
  };

  const handleCreateWeek = async (e: React.FormEvent) => {
    e.preventDefault();
    setWeekFormError(null);
    const errorMsg = validateWeekForm();
    if (errorMsg) {
      setWeekFormError(errorMsg);
      return;
    }
    setWeekLoading(true);
    try {
      // Giả sử đã có planId, nếu chưa có cần truyền vào
      const planId = /* lấy planId phù hợp từ props, state hoặc context */ '';
      await apiClient.post(`/api/plans/${planId}/weeks`, {
        startDate: weekForm.startDate,
        endDate: weekForm.endDate,
        targetCigarettesPerDay: Number(weekForm.targetCigarettesPerDay),
        weeklyContent: weekForm.weeklyContent,
      });
      setWeekForm({ startDate: '', endDate: '', targetCigarettesPerDay: 0, weeklyContent: '' });
      setWeekFormError(null);
      alert('Tạo tuần thành công!');
    } catch (err: any) {
      setWeekFormError('Tạo tuần thất bại!');
    } finally {
      setWeekLoading(false);
    }
  };

  return (
    <div style={{
      display: 'flex',
      gap: 32,
      maxWidth: 1400,
      margin: '40px auto',
      alignItems: 'flex-start',
      flexWrap: 'wrap',
      justifyContent: 'center',
    }}>
      {/* Panel trái: Thông tin cá nhân */}
      <div style={{
        flex: '0 0 320px',
        background: '#fff',
        borderRadius: 18,
        boxShadow: '0 4px 24px #0001',
        padding: 32,
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        minWidth: 280,
        marginBottom: 32,
        height: '100%',
      }}>
        {memberInfo && memberInfo.account && (
          <>
            <img src={memberInfo.account.image} alt={memberInfo.account.name} style={{
              width: 110, height: 110, borderRadius: '50%', objectFit: 'cover', border: '3px solid #2563eb', marginBottom: 18
            }} />
            <div style={{ fontWeight: 900, fontSize: 26, color: '#2563eb', marginBottom: 6, textAlign: 'center' }}>{memberInfo.account.name}</div>
            <div style={{ color: '#444', fontSize: 16, marginBottom: 8, textAlign: 'center' }}>{memberInfo.account.email}</div>
            <div style={{ color: '#666', fontSize: 15, marginBottom: 4 }}>Tuổi: {memberInfo.account.age}</div>
            <div style={{ color: '#666', fontSize: 15, marginBottom: 4 }}>Giới tính: {memberInfo.account.gender === 'Male' ? 'Nam' : 'Nữ'}</div>
            <div style={{ color: '#2563eb', fontSize: 15, marginBottom: 4, fontWeight: 700 }}>Số lần khám sức khỏe: {memberInfo.account.healthCheckups}</div>
            <div style={{ color: '#2563eb', fontSize: 15, marginBottom: 4, fontWeight: 700 }}>Số lần tư vấn: {memberInfo.account.consultations}</div>
          </>
        )}
        {/* List layout chứa 2 nút action */}
        <div style={{
          width: '100%',
          marginTop: 28,
          background: '#f8fafc',
          borderRadius: 14,
          boxShadow: '0 2px 8px #0001',
          padding: '18px 0',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          gap: 16,
          border: '1px solid #e5e7eb',
        }}>
          <button onClick={() => navigate(`/coach/member/${memberId}/create-plan`)} style={{
            background: '#22c55e', color: '#fff', border: 'none', borderRadius: 8, padding: '10px 28px',
            fontWeight: 700, fontSize: 17, cursor: 'pointer', width: '80%', marginBottom: 0
          }}>Tạo kế hoạch cai thuốc</button>
          <button onClick={() => navigate(`/coach/member/${memberId}/create-health-profile`)} style={{
            background: '#2563eb', color: '#fff', border: 'none', borderRadius: 8, padding: '10px 28px',
            fontWeight: 700, fontSize: 17, cursor: 'pointer', width: '80%', marginBottom: 0
          }}>Tạo hồ sơ mới</button>
        </div>
      </div>
      {/* Panel giữa: Lịch sử & lịch khám sức khỏe */}
      <div style={{ flex: 1, minWidth: 340, maxWidth: 440 }}>
        <div style={{
          background: '#fff',
          borderRadius: 18,
          boxShadow: '0 4px 24px #0001',
          padding: 32,
          marginBottom: 32
        }}>
          <h2 style={{ fontSize: 26, fontWeight: 900, color: '#2563eb', marginBottom: 18, textAlign: 'center', letterSpacing: 1 }}>LỊCH KHÁM SỨC KHỎE</h2>
          {error && <div style={{ color: 'red', marginBottom: 16, textAlign: 'center', fontWeight: 600 }}>{error}</div>}
          {loading ? <div style={{ textAlign: 'center', color: '#2563eb', fontWeight: 600 }}>Đang tải dữ liệu...</div> : (
            <ul style={{ listStyle: 'none', padding: 0, margin: 0 }}>
              {healthProfiles.length === 0 ? <div style={{ textAlign: 'center', color: '#888', fontSize: 18 }}>Chưa có hồ sơ sức khỏe nào.</div> : (
                healthProfiles.map(profile => (
                  <li key={profile.healthProfileId} style={{
                    background: '#f8fafc', borderRadius: 14, marginBottom: 18, boxShadow: '0 2px 8px #0001', padding: '18px 28px',
                    fontWeight: 700, fontSize: 18, color: '#222', cursor: 'pointer', transition: 'box-shadow 0.2s', position: 'relative'
                  }}
                    onClick={() => setOpenId(openId === profile.healthProfileId ? null : profile.healthProfileId)}
                  >
                    {profile.startDate}
                    {openId === profile.healthProfileId && (
                      <div style={{
                        marginTop: 18, background: '#fff', borderRadius: 18, boxShadow: '0 8px 32px #0002', padding: 32, position: 'relative',
                        animation: 'slideDown 0.4s', fontSize: 17, fontWeight: 500, color: '#333', overflow: 'hidden'
                      }}>
                        {/* Họa tiết góc trái */}
                        <div style={{ position: 'absolute', left: -18, top: 18, width: 40, height: 40, background: '#fbbf24', borderRadius: '50%', opacity: 0.15, zIndex: 0 }} />
                        {/* Họa tiết góc phải */}
                        <div style={{ position: 'absolute', right: -18, top: 18, width: 40, height: 40, background: '#2563eb', borderRadius: '50%', opacity: 0.10, zIndex: 0 }} />
                        <div style={{ fontWeight: 900, fontSize: 22, marginBottom: 18, color: '#2563eb', textAlign: 'center', letterSpacing: 1 }}>THÔNG TIN CHI TIẾT</div>
                        <div style={{ marginBottom: 10 }}><b>Thông tin sức khỏe:</b> {profile.healthInfo}</div>
                        <div style={{ marginBottom: 10 }}><b>Dung tích phổi:</b> {profile.lungCapacity} ml</div>
                        <div style={{ marginBottom: 10 }}><b>Nhịp tim:</b> {profile.heartRate} lần/phút</div>
                        <div style={{ marginBottom: 10 }}><b>Huyết áp:</b> {profile.bloodPressure} mmHg</div>
                        <div style={{ marginBottom: 10 }}><b>Ghi chú của Coach:</b> {profile.coachNotes}</div>
                        <div style={{ display: 'flex', gap: 16, justifyContent: 'flex-end', marginTop: 18 }}>
                          <button
                            onClick={e => { e.stopPropagation(); handleEdit(profile); }}
                            style={{
                              background: 'linear-gradient(90deg,#6366f1,#2563eb)',
                              color: '#fff',
                              border: 'none',
                              borderRadius: 8,
                              padding: '8px 24px',
                              cursor: 'pointer',
                              fontWeight: 700,
                              fontSize: 15,
                              textTransform: 'uppercase',
                              letterSpacing: 1,
                              transition: 'background 0.2s, box-shadow 0.2s, transform 0.18s',
                            }}
                            onMouseOver={e => {
                              e.currentTarget.style.background = '#1e40af';
                              e.currentTarget.style.boxShadow = '0 4px 20px #6366f199';
                              e.currentTarget.style.transform = 'scale(1.07)';
                            }}
                            onMouseOut={e => {
                              e.currentTarget.style.background = 'linear-gradient(90deg,#6366f1,#2563eb)';
                              e.currentTarget.style.boxShadow = 'none';
                              e.currentTarget.style.transform = 'scale(1)';
                            }}
                          >Sửa</button>
                          <button
                            onClick={e => { e.stopPropagation(); handleDelete(profile.healthProfileId); }}
                            style={{
                              background: 'linear-gradient(90deg,#ef4444,#f87171)',
                              color: '#fff',
                              border: 'none',
                              borderRadius: 8,
                              padding: '8px 24px',
                              cursor: 'pointer',
                              fontWeight: 700,
                              fontSize: 15,
                              textTransform: 'uppercase',
                              letterSpacing: 1,
                              transition: 'background 0.2s, box-shadow 0.2s, transform 0.18s',
                            }}
                            onMouseOver={e => {
                              e.currentTarget.style.background = '#b91c1c';
                              e.currentTarget.style.boxShadow = '0 4px 20px #ef444499';
                              e.currentTarget.style.transform = 'scale(1.07)';
                            }}
                            onMouseOut={e => {
                              e.currentTarget.style.background = 'linear-gradient(90deg,#ef4444,#f87171)';
                              e.currentTarget.style.boxShadow = 'none';
                              e.currentTarget.style.transform = 'scale(1)';
                            }}
                          >Xóa</button>
                        </div>
                      </div>
                    )}
                  </li>
                ))
              )}
            </ul>
          )}
        </div>
      </div>
      {/* Panel phải: Biểu đồ sức khỏe */}
      <div style={{ flex: 1, minWidth: 340, maxWidth: 440 }}>
        <div style={{
          background: '#fff',
          borderRadius: 18,
          boxShadow: '0 4px 24px #0001',
          padding: 32,
          marginBottom: 32,
        }}>
          <h3 style={{ fontWeight: 700, fontSize: 20, color: '#2563eb', marginBottom: 18, textAlign: 'center' }}>Biểu đồ sức khỏe</h3>
          {healthProfiles.length > 0 ? (
            <>
              <div style={{ marginBottom: 32 }}>
                <div style={{ fontWeight: 700, color: '#2563eb', fontSize: 17, marginBottom: 8 }}>Dung tích phổi (ml) <span style={{ color: '#22c55e', fontWeight: 500, fontSize: 14 }}>(Bình thường: 5.000-6.000ml)</span></div>
                <ResponsiveContainer width="100%" height={220}>
                  <BarChart data={healthProfiles.map(p => ({ date: p.startDate, value: p.lungCapacity }))}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="date" />
                    <YAxis />
                    <Tooltip />
                    <Legend />
                    {/* Vùng bình thường: 5000-6000 ml */}
                    <ReferenceArea y1={5000} y2={6000} fill="#22c55e" fillOpacity={0.15} label="Bình thường" />
                    <Bar dataKey="value" fill="#2563eb" name="Dung tích phổi" />
                  </BarChart>
                </ResponsiveContainer>
              </div>
              <div style={{ marginBottom: 32 }}>
                <div style={{ fontWeight: 700, color: '#f59e42', fontSize: 17, marginBottom: 8 }}>Nhịp tim (lần/phút) <span style={{ color: '#22c55e', fontWeight: 500, fontSize: 14 }}>(Bình thường: 60-100)</span></div>
                <ResponsiveContainer width="100%" height={220}>
                  <BarChart data={healthProfiles.map(p => ({ date: p.startDate, value: p.heartRate }))}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="date" />
                    <YAxis />
                    <Tooltip />
                    <Legend />
                    {/* Vùng bình thường: 60-100 bpm */}
                    <ReferenceArea y1={60} y2={100} fill="#22c55e" fillOpacity={0.15} label="Bình thường" />
                    <Bar dataKey="value" fill="#f59e42" name="Nhịp tim" />
                  </BarChart>
                </ResponsiveContainer>
              </div>
              <div>
                <div style={{ fontWeight: 700, color: '#ef4444', fontSize: 17, marginBottom: 8 }}>Huyết áp (mmHg) <span style={{ color: '#22c55e', fontWeight: 500, fontSize: 14 }}>(Bình thường: dưới 120/80)</span></div>
                <ResponsiveContainer width="100%" height={220}>
                  <BarChart data={healthProfiles.map(p => ({
                    date: p.startDate,
                    sys: Number((p.bloodPressure || '').split('/')[0]) || 0,
                    dia: Number((p.bloodPressure || '').split('/')[1]) || 0
                  }))}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="date" />
                    <YAxis />
                    <Tooltip />
                    <Legend />
                    {/* Vùng bình thường: sys < 120, dia < 80 */}
                    <ReferenceArea y1={0} y2={120} fill="#22c55e" fillOpacity={0.10} label="Tâm thu bình thường" />
                    <ReferenceArea y1={0} y2={80} fill="#2563eb" fillOpacity={0.10} label="Tâm trương bình thường" />
                    <Bar dataKey="sys" fill="#ef4444" name="Tâm thu" />
                    <Bar dataKey="dia" fill="#2563eb" name="Tâm trương" />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </>
          ) : <div style={{ textAlign: 'center', color: '#888', fontSize: 18 }}>Chưa có dữ liệu sức khỏe.</div>}
        </div>
      </div>
      {/* Modal tạo/sửa hồ sơ sức khỏe */}
      {showForm && (
        <div style={{
          position: 'fixed', left: 0, top: 0, width: '100vw', height: '100vh', background: 'rgba(0,0,0,0.18)', zIndex: 1000,
          display: 'flex', alignItems: 'center', justifyContent: 'center'
        }}>
          <form onSubmit={handleSubmit} style={{ background: '#fff', borderRadius: 18, boxShadow: '0 8px 32px #0002', padding: 36, minWidth: 340, maxWidth: 480, position: 'relative' }}>
            <button type="button" onClick={() => { setShowForm(false); setEditingId(null); }} style={{ position: 'absolute', top: 12, right: 16, background: 'none', border: 'none', fontSize: 22, color: '#888', cursor: 'pointer' }}>×</button>
            <h3 style={{ fontSize: 22, fontWeight: 800, marginBottom: 22, color: '#2563eb', textAlign: 'center', letterSpacing: 1 }}>{editingId ? 'Cập nhật hồ sơ sức khỏe' : 'Tạo mới hồ sơ sức khỏe'}</h3>
            {formError && <div style={{ color: 'red', marginBottom: 14, textAlign: 'center', fontWeight: 600 }}>{formError}</div>}
            {/* Ẩn trường ngày khám khi tạo mới */}
            {editingId && (
              <div style={{ marginBottom: 18 }}>
                <label style={{ fontWeight: 700 }}>Ngày khám (YYYY-MM-DD):<br />
                  <input type="date" name="startDate" value={form.startDate} onChange={handleInputChange} required style={{ width: '100%', padding: 12, borderRadius: 8, border: '1px solid #cbd5e1', marginTop: 6, fontSize: 16 }} placeholder="Chọn ngày khám" />
                </label>
              </div>
            )}
            <div style={{ marginBottom: 18 }}>
              <label style={{ fontWeight: 700 }}>Thông tin sức khỏe:<br />
                <textarea name="healthInfo" value={form.healthInfo} onChange={handleInputChange} required rows={2} style={{ width: '100%', padding: 12, borderRadius: 8, border: '1px solid #cbd5e1', marginTop: 6, fontSize: 16 }} placeholder="Nhập thông tin sức khỏe chi tiết..." />
              </label>
            </div>
            <div style={{ marginBottom: 18, display: 'flex', gap: 16 }}>
              <label style={{ flex: 1, fontWeight: 700 }}>Dung tích phổi:<br />
                <input type="number" name="lungCapacity" value={form.lungCapacity} onChange={handleInputChange} required min={1000} max={8000} style={{ width: '100%', padding: 12, borderRadius: 8, border: '1px solid #cbd5e1', marginTop: 6, fontSize: 16 }} placeholder="ml (1000-8000)" />
              </label>
              <label style={{ flex: 1, fontWeight: 700 }}>Nhịp tim:<br />
                <input type="number" name="heartRate" value={form.heartRate} onChange={handleInputChange} required min={40} max={200} style={{ width: '100%', padding: 12, borderRadius: 8, border: '1px solid #cbd5e1', marginTop: 6, fontSize: 16 }} placeholder="lần/phút (40-200)" />
              </label>
            </div>
            <div style={{ marginBottom: 18 }}>
              <label style={{ fontWeight: 700 }}>Huyết áp:<br />
                <input name="bloodPressure" value={form.bloodPressure} onChange={handleInputChange} required pattern="^\d{2,3}/\d{2,3}$" style={{ width: '100%', padding: 12, borderRadius: 8, border: '1px solid #cbd5e1', marginTop: 6, fontSize: 16 }} placeholder="mmHg (VD: 120/80)" />
              </label>
            </div>
            <div style={{ marginBottom: 22 }}>
              <label style={{ fontWeight: 700 }}>Ghi chú của Coach:<br />
                <textarea name="coachNotes" value={form.coachNotes} onChange={handleInputChange} rows={2} maxLength={2000} style={{ width: '100%', padding: 12, borderRadius: 8, border: '1px solid #cbd5e1', marginTop: 6, fontSize: 16 }} placeholder="Nhập ghi chú... (tối đa 2000 ký tự)" />
              </label>
            </div>
            <div style={{ display: 'flex', gap: 16, justifyContent: 'flex-end' }}>
              <button type="submit" style={{ background: 'linear-gradient(90deg,#6366f1,#2563eb)', color: '#fff', border: 'none', borderRadius: 10, padding: '12px 32px', fontWeight: 800, fontSize: 17, cursor: 'pointer', boxShadow: '0 2px 8px #6366f122', textTransform: 'uppercase', letterSpacing: 1 }}>{editingId ? 'Lưu thay đổi' : 'Thêm mới'}</button>
              <button type="button" onClick={() => { setShowForm(false); setEditingId(null); }} style={{ background: 'linear-gradient(90deg,#64748b,#94a3b8)', color: '#fff', border: 'none', borderRadius: 10, padding: '12px 32px', fontWeight: 800, fontSize: 17, cursor: 'pointer', boxShadow: '0 2px 8px #64748b22', textTransform: 'uppercase', letterSpacing: 1 }}>Hủy</button>
            </div>
          </form>
        </div>
      )}
      {/* Modal tạo kế hoạch cai thuốc */}
      {showPlanModal && (
        <div style={{
          position: 'fixed', left: 0, top: 0, width: '100vw', height: '100vh', background: 'rgba(0,0,0,0.18)', zIndex: 1100,
          display: 'flex', alignItems: 'center', justifyContent: 'center'
        }}>
          <form onSubmit={handleCreatePlan} style={{ background: '#fff', borderRadius: 18, boxShadow: '0 8px 32px #0002', padding: 36, minWidth: 340, maxWidth: 480, position: 'relative' }}>
            <button type="button" onClick={() => { setShowPlanModal(false); }} style={{ position: 'absolute', top: 12, right: 16, background: 'none', border: 'none', fontSize: 22, color: '#888', cursor: 'pointer' }}>×</button>
            <h3 style={{ fontSize: 22, fontWeight: 800, marginBottom: 22, color: '#22c55e', textAlign: 'center', letterSpacing: 1 }}>Tạo kế hoạch cai thuốc</h3>
            {planFormError && <div style={{ color: 'red', marginBottom: 14, textAlign: 'center', fontWeight: 600 }}>{planFormError}</div>}
            <div style={{ marginBottom: 18 }}>
              <label style={{ fontWeight: 700 }}>Tiêu đề kế hoạch:<br />
                <input name="title" value={planForm.title} onChange={handlePlanInputChange} required maxLength={255} style={{ width: '100%', padding: 12, borderRadius: 8, border: '1px solid #cbd5e1', marginTop: 6, fontSize: 16 }} placeholder="Nhập tiêu đề..." />
              </label>
            </div>
            <div style={{ marginBottom: 18 }}>
              <label style={{ fontWeight: 700 }}>Mô tả kế hoạch:<br />
                <textarea name="description" value={planForm.description} onChange={handlePlanInputChange} required rows={2} style={{ width: '100%', padding: 12, borderRadius: 8, border: '1px solid #cbd5e1', marginTop: 6, fontSize: 16 }} placeholder="Nhập mô tả..." />
              </label>
            </div>
            <div style={{ marginBottom: 18, display: 'flex', gap: 16 }}>
              <label style={{ flex: 1, fontWeight: 700 }}>Ngày bắt đầu:<br />
                <input type="date" name="startDate" value={planForm.startDate} onChange={handlePlanInputChange} required style={{ width: '100%', padding: 12, borderRadius: 8, border: '1px solid #cbd5e1', marginTop: 6, fontSize: 16 }} />
              </label>
              <label style={{ flex: 1, fontWeight: 700 }}>Ngày mục tiêu:<br />
                <input type="date" name="goalDate" value={planForm.goalDate} onChange={handlePlanInputChange} required style={{ width: '100%', padding: 12, borderRadius: 8, border: '1px solid #cbd5e1', marginTop: 6, fontSize: 16 }} />
              </label>
            </div>
            <div style={{ marginBottom: 22 }}>
              <label style={{ fontWeight: 700 }}>Mục tiêu số điếu/ngày:<br />
                <input type="number" name="targetCigarettesPerDay" value={weekForm.targetCigarettesPerDay} onChange={handleWeekInputChange} min={0} required style={{ width: '100%', padding: 12, borderRadius: 8, border: '1px solid #cbd5e1', marginTop: 6, fontSize: 16 }} placeholder="0" />
              </label>
            </div>
            <div style={{ display: 'flex', gap: 16, justifyContent: 'flex-end' }}>
              <button type="submit" disabled={planLoading} style={{ background: 'linear-gradient(90deg,#22c55e,#16a34a)', color: '#fff', border: 'none', borderRadius: 10, padding: '12px 32px', fontWeight: 800, fontSize: 17, cursor: 'pointer', boxShadow: '0 2px 8px #22c55e22', textTransform: 'uppercase', letterSpacing: 1 }}>{planLoading ? 'Đang tạo...' : 'Tạo kế hoạch'}</button>
              <button type="button" onClick={() => setShowPlanModal(false)} style={{ background: 'linear-gradient(90deg,#64748b,#94a3b8)', color: '#fff', border: 'none', borderRadius: 10, padding: '12px 32px', fontWeight: 800, fontSize: 17, cursor: 'pointer', boxShadow: '0 2px 8px #64748b22', textTransform: 'uppercase', letterSpacing: 1 }}>Hủy</button>
            </div>
          </form>
        </div>
      )}
    </div>
  );
};

export default CoachMemberDetailPage; 