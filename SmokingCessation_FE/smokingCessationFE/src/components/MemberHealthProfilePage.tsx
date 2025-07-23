import React, { useEffect, useState } from 'react';
import apiClient from '../api/apiClient';
import { useAuth } from '../contexts/AuthContext';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, ReferenceArea } from 'recharts';

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

const MemberHealthProfilePage = () => {
  const { user } = useAuth();
  const [healthProfiles, setHealthProfiles] = useState<HealthProfile[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [openId, setOpenId] = useState<number | null>(null);

  useEffect(() => {
    fetchHealthHistory();
    // eslint-disable-next-line
  }, [user]);

  const fetchHealthHistory = async () => {
    setLoading(true);
    try {
      const res = await apiClient.get(`/user/consultation/my-history`);
      setHealthProfiles(res.data);
    } catch (e) {
      setError('Không thể tải lịch sử sức khỏe');
      setHealthProfiles([]);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{
      minHeight: '100vh',
      width: '100%',
      background: 'linear-gradient(120deg, #e0e7ff 0%, #f8fafc 100%)',
      padding: '40px 0',
    }}>
      <div style={{
        display: 'flex',
        gap: 32,
        maxWidth: 1400,
        margin: '0 auto',
        alignItems: 'flex-start',
        flexWrap: 'wrap',
        justifyContent: 'center',
      }}>
        {/* Cột trái: Thông tin cá nhân */}
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
          {user && (
            <>
              <img src={user.image} alt={user.name} style={{
                width: 110, height: 110, borderRadius: '50%', objectFit: 'cover', border: '3px solid #2563eb', marginBottom: 18
              }} />
              <div style={{ fontWeight: 900, fontSize: 26, color: '#2563eb', marginBottom: 6, textAlign: 'center' }}>{user.name}</div>
              <div style={{ color: '#444', fontSize: 16, marginBottom: 8, textAlign: 'center' }}>{user.email}</div>
              <div style={{ color: '#666', fontSize: 15, marginBottom: 4 }}>Tuổi: {user.age}</div>
              <div style={{ color: '#666', fontSize: 15, marginBottom: 4 }}>Giới tính: {user.gender === 'Male' ? 'Nam' : 'Nữ'}</div>
            </>
          )}
        </div>
        {/* Cột giữa: Danh sách health profile */}
        <div style={{
          flex: '1 1 400px',
          minWidth: 350,
          maxWidth: 500,
          background: 'rgba(255,255,255,0.95)',
          borderRadius: 18,
          boxShadow: '0 4px 24px #0001',
          padding: 32,
        }}>
          <h2 style={{ fontSize: 26, fontWeight: 900, color: '#2563eb', marginBottom: 18, textAlign: 'center', letterSpacing: 1 }}>HỒ SƠ SỨC KHỎE CỦA BẠN</h2>
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
                        <div style={{ fontWeight: 900, fontSize: 22, marginBottom: 18, color: '#2563eb', textAlign: 'center', letterSpacing: 1 }}>THÔNG TIN CHI TIẾT</div>
                        <div style={{ marginBottom: 10 }}><b>Thông tin sức khỏe:</b> {profile.healthInfo}</div>
                        <div style={{ marginBottom: 10 }}><b>Dung tích phổi:</b> {profile.lungCapacity} ml</div>
                        <div style={{ marginBottom: 10 }}><b>Nhịp tim:</b> {profile.heartRate} lần/phút</div>
                        <div style={{ marginBottom: 10 }}><b>Huyết áp:</b> {profile.bloodPressure} mmHg</div>
                        <div style={{ marginBottom: 10 }}><b>Ghi chú của Coach:</b> {profile.coachNotes}</div>
                      </div>
                    )}
                  </li>
                ))
              )}
            </ul>
          )}
        </div>
        {/* Cột phải: Biểu đồ sức khỏe */}
        <div style={{
          flex: '1 1 400px',
          minWidth: 350,
          maxWidth: 500,
          background: '#fff',
          borderRadius: 18,
          boxShadow: '0 4px 24px #0001',
          padding: 32,
          marginTop: 0,
        }}>
          <h3 style={{ fontWeight: 700, fontSize: 20, color: '#2563eb', marginBottom: 18, textAlign: 'center' }}>Biểu đồ sức khỏe</h3>
          {healthProfiles.length > 0 ? (
            <>
              {/* Dung tích phổi */}
              <div style={{ marginBottom: 32 }}>
                <div style={{ fontWeight: 700, color: '#2563eb', fontSize: 17, marginBottom: 8 }}>Dung tích phổi (ml) <span style={{ color: '#22c55e', fontWeight: 500, fontSize: 14 }}>(Bình thường: 5.000-6.000ml)</span></div>
                <ResponsiveContainer width="100%" height={180}>
                  <BarChart data={healthProfiles.map(p => ({ date: p.startDate, value: p.lungCapacity }))}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="date" />
                    <YAxis />
                    <Tooltip />
                    <Legend />
                    <ReferenceArea y1={5000} y2={6000} fill="#22c55e" fillOpacity={0.15} label="Bình thường" />
                    <Bar dataKey="value" fill="#2563eb" name="Dung tích phổi" />
                  </BarChart>
                </ResponsiveContainer>
              </div>
              {/* Nhịp tim */}
              <div style={{ marginBottom: 32 }}>
                <div style={{ fontWeight: 700, color: '#f59e42', fontSize: 17, marginBottom: 8 }}>Nhịp tim (lần/phút) <span style={{ color: '#22c55e', fontWeight: 500, fontSize: 14 }}>(Bình thường: 60-100)</span></div>
                <ResponsiveContainer width="100%" height={180}>
                  <BarChart data={healthProfiles.map(p => ({ date: p.startDate, value: p.heartRate }))}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="date" />
                    <YAxis />
                    <Tooltip />
                    <Legend />
                    <ReferenceArea y1={60} y2={100} fill="#22c55e" fillOpacity={0.15} label="Bình thường" />
                    <Bar dataKey="value" fill="#f59e42" name="Nhịp tim" />
                  </BarChart>
                </ResponsiveContainer>
              </div>
              {/* Huyết áp */}
              <div>
                <div style={{ fontWeight: 700, color: '#ef4444', fontSize: 17, marginBottom: 8 }}>Huyết áp (mmHg) <span style={{ color: '#22c55e', fontWeight: 500, fontSize: 14 }}>(Bình thường: dưới 120/80)</span></div>
                <ResponsiveContainer width="100%" height={180}>
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
    </div>
  );
};
export default MemberHealthProfilePage; 