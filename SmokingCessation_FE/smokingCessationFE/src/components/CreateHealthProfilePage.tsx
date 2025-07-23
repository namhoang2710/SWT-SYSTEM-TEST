import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import apiClient from '../api/apiClient';
import { getMemberProfileForCoach } from '../api/services/userService';

const CreateHealthProfilePage = () => {
  const { memberId } = useParams();
  const navigate = useNavigate();
  const [form, setForm] = useState({
    healthInfo: '',
    lungCapacity: '',
    heartRate: '',
    bloodPressure: '',
    coachNotes: '',
  });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [memberInfo, setMemberInfo] = useState<any>(null);
  const [profileLoading, setProfileLoading] = useState(true);

  useEffect(() => {
    fetchMemberInfo();
    // eslint-disable-next-line
  }, [memberId]);

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

  const validate = () => {
    if (!form.healthInfo.trim()) return 'Vui lòng nhập thông tin sức khỏe.';
    const lung = Number(form.lungCapacity);
    if (isNaN(lung) || lung < 1000 || lung > 8000) return 'Dung tích phổi phải từ 1000 đến 8000 ml.';
    const heart = Number(form.heartRate);
    if (isNaN(heart) || heart < 40 || heart > 200) return 'Nhịp tim phải từ 40 đến 200 bpm.';
    if (!/^\d{2,3}\/\d{2,3}$/.test(form.bloodPressure)) return 'Huyết áp phải có format XXX/XX (VD: 120/80)';
    if (form.coachNotes.length > 2000) return 'Ghi chú không được quá 2000 ký tự.';
    return '';
  };
  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };
  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setError('');
    const err = validate();
    if (err) return setError(err);
    setLoading(true);
    (async () => {
      try {
        await apiClient.post(`/health-profile/account/${memberId}/create`, {
          healthInfo: form.healthInfo,
          lungCapacity: Number(form.lungCapacity),
          heartRate: Number(form.heartRate),
          bloodPressure: form.bloodPressure,
          coachNotes: form.coachNotes,
        });
        navigate(`/coach/member/${memberId}`);
      } catch {
        setError('Tạo hồ sơ sức khỏe thất bại!');
      } finally {
        setLoading(false);
      }
    })();
  };
  return (
    <div style={{
      minHeight: '100vh',
      width: '100vw',
      display: 'flex',
      alignItems: 'flex-start',
      justifyContent: 'center',
      background: `url('/images/non-smoking.jpg') center/cover no-repeat fixed, #e0f2fe`,
      position: 'relative',
      paddingTop: 60,
      gap: 40,
    }}>
      {/* Lớp phủ mờ background */}
      <div style={{
        position: 'fixed',
        top: 0,
        left: 0,
        width: '100vw',
        height: '100vh',
        background: 'rgba(255,255,255,0.75)',
        zIndex: 0,
        pointerEvents: 'none',
      }} />
      {/* Profile bên trái */}
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
        zIndex: 1,
      }}>
        {profileLoading ? (
          <div style={{ color: '#2563eb', fontWeight: 600 }}>Đang tải profile...</div>
        ) : memberInfo && memberInfo.account ? (
          <>
            <img src={memberInfo.account.image} alt={memberInfo.account.name} style={{
              width: 110, height: 110, borderRadius: '50%', objectFit: 'cover', border: '3px solid #2563eb', marginBottom: 18
            }} onError={e => { (e.target as HTMLImageElement).src = '/images/logo.png'; }} />
            <div style={{ fontWeight: 900, fontSize: 26, color: '#2563eb', marginBottom: 6, textAlign: 'center' }}>{memberInfo.account.name}</div>
            <div style={{ color: '#444', fontSize: 16, marginBottom: 8, textAlign: 'center' }}>{memberInfo.account.email}</div>
            <div style={{ color: '#666', fontSize: 15, marginBottom: 4 }}>Tuổi: {memberInfo.account.age}</div>
            <div style={{ color: '#666', fontSize: 15, marginBottom: 4 }}>Giới tính: {memberInfo.account.gender === 'Male' ? 'Nam' : 'Nữ'}</div>
          </>
        ) : (
          <div style={{ color: '#ef4444', fontWeight: 600 }}>Không thể tải profile</div>
        )}
      </div>
      {/* Form tạo hồ sơ bên phải */}
      <div style={{
        width: '100%',
        maxWidth: 1000,
        margin: '0 auto',
        background: '#fff',
        borderRadius: 18,
        boxShadow: '0 8px 32px #0002',
        padding: 48,
        minHeight: 400,
        zIndex: 1,
        position: 'relative',
      }}>
        <button type="button" onClick={() => navigate(`/coach/member/${memberId}`)} style={{ marginBottom: 18, background: 'none', border: 'none', fontSize: 22, color: '#2563eb', cursor: 'pointer', fontWeight: 700 }}>&larr; Quay lại</button>
        <h2 style={{ textAlign: 'center', color: '#2563eb', fontWeight: 900, fontSize: 32, marginBottom: 28, letterSpacing: 1, textShadow: '0 2px 8px #fff8' }}>Tạo hồ sơ sức khỏe</h2>
        {error && <div style={{ color: 'red', marginBottom: 16, textAlign: 'center', fontWeight: 600 }}>{error}</div>}
        <form onSubmit={handleSubmit} style={{ animation: 'slideUp 0.7s' }}>
          <div style={{ marginBottom: 18 }}>
            <label style={{ fontWeight: 700 }}>Thông tin sức khỏe:<br />
              <textarea name="healthInfo" value={form.healthInfo} onChange={handleChange} required rows={2} style={{ width: '100%', padding: 12, borderRadius: 8, border: '1px solid #cbd5e1', marginTop: 6, fontSize: 16 }} placeholder="Nhập thông tin sức khỏe chi tiết..." />
            </label>
          </div>
          <div style={{ marginBottom: 18, display: 'flex', gap: 16 }}>
            <label style={{ flex: 1, fontWeight: 700 }}>Dung tích phổi:<br />
              <input type="number" name="lungCapacity" value={form.lungCapacity} onChange={handleChange} required min={1000} max={8000} style={{ width: '100%', padding: 12, borderRadius: 8, border: '1px solid #cbd5e1', marginTop: 6, fontSize: 16 }} placeholder="ml (1000-8000)" />
            </label>
            <label style={{ flex: 1, fontWeight: 700 }}>Nhịp tim:<br />
              <input type="number" name="heartRate" value={form.heartRate} onChange={handleChange} required min={40} max={200} style={{ width: '100%', padding: 12, borderRadius: 8, border: '1px solid #cbd5e1', marginTop: 6, fontSize: 16 }} placeholder="lần/phút (40-200)" />
            </label>
          </div>
          <div style={{ marginBottom: 18 }}>
            <label style={{ fontWeight: 700 }}>Huyết áp:<br />
              <input name="bloodPressure" value={form.bloodPressure} onChange={handleChange} required pattern="^\d{2,3}/\d{2,3}$" style={{ width: '100%', padding: 12, borderRadius: 8, border: '1px solid #cbd5e1', marginTop: 6, fontSize: 16 }} placeholder="mmHg (VD: 120/80)" />
            </label>
          </div>
          <div style={{ marginBottom: 28 }}>
            <label style={{ fontWeight: 700 }}>Ghi chú của Coach:<br />
              <textarea name="coachNotes" value={form.coachNotes} onChange={handleChange} rows={2} maxLength={2000} style={{ width: '100%', padding: 12, borderRadius: 8, border: '1px solid #cbd5e1', marginTop: 6, fontSize: 16 }} placeholder="Nhập ghi chú... (tối đa 2000 ký tự)" />
            </label>
          </div>
          <button type="submit" disabled={loading} style={{ background: 'linear-gradient(90deg,#2563eb,#1d4ed8)', color: '#fff', border: 'none', borderRadius: 10, padding: '14px 0', fontWeight: 800, fontSize: 18, cursor: 'pointer', width: '100%', boxShadow: '0 2px 8px #2563eb22', textTransform: 'uppercase', letterSpacing: 1, transition: 'background 0.2s' }}>{loading ? 'Đang tạo...' : 'Tạo hồ sơ'}</button>
        </form>
        <style>{`
          @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
          @keyframes slideUp { from { transform: translateY(60px); opacity: 0; } to { transform: none; opacity: 1; } }
        `}</style>
      </div>
    </div>
  );
};
export default CreateHealthProfilePage; 