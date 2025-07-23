import React, { useEffect, useState } from 'react';
import apiClient from '../api/apiClient';
import { useNavigate } from 'react-router-dom';
import { LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';

const ProgressPlanPage: React.FC = () => {
  const [loading, setLoading] = useState(true);
  const [progress, setProgress] = useState<any>(null);
  const [error, setError] = useState<string | null>(null);
  const navigate = useNavigate();

  useEffect(() => {
    const fetchProgress = async () => {
      setLoading(true);
      setError(null);
      try {
        // Lấy planId active
        const plansRes = await apiClient.get('/plans/member/my-plans');
        const activePlan = Array.isArray(plansRes.data)
          ? plansRes.data.find((p: any) => p.status === 'ACTIVE')
          : null;
        if (!activePlan) {
          setError('Bạn chưa có kế hoạch cai thuốc đang hoạt động.');
          setLoading(false);
          return;
        }
        const planId = activePlan.planId;
        // Gọi API tiến độ
        const res = await apiClient.get(`/progress/plan/${planId}`);
        setProgress(res.data);
      } catch (e) {
        setError('Không lấy được tiến độ cai thuốc.');
      } finally {
        setLoading(false);
      }
    };
    fetchProgress();
  }, []);

  return (
    <div style={{ maxWidth: 1200, margin: '40px auto', padding: 32, background: '#fff', borderRadius: 16, boxShadow: '0 4px 24px rgba(0,0,0,0.08)' }}>
      <button onClick={() => navigate(-1)} style={{ marginBottom: 16, color: '#1976d2', background: 'none', border: 'none', fontWeight: 600, cursor: 'pointer' }}>&larr; Quay lại</button>
      <h2 style={{ fontSize: 24, fontWeight: 700, marginBottom: 24, color: '#1976d2', textAlign: 'center' }}>Tiến độ cai thuốc</h2>
      {loading && <div>Đang tải tiến độ...</div>}
      {error && <div style={{ color: '#d32f2f', fontWeight: 600 }}>{error}</div>}
      {progress && Array.isArray(progress) && progress.length > 0 && (
        <div style={{ marginBottom: 40, background: '#f8fafc', borderRadius: 16, boxShadow: '0 2px 12px #1976d211', padding: 32 }}>
          <h3 style={{ fontWeight: 700, fontSize: 20, color: '#1976d2', marginBottom: 18, textAlign: 'center' }}>Biểu đồ tiến độ cai thuốc</h3>
          <div style={{ display: 'flex', gap: 32, flexWrap: 'wrap', justifyContent: 'center', marginBottom: 32 }}>
            <div style={{ flex: '1 1 400px', minWidth: 320, maxWidth: 600 }}>
              <div style={{ fontWeight: 600, color: '#1976d2', marginBottom: 8, textAlign: 'center' }}>Số điếu hút mỗi ngày</div>
              <ResponsiveContainer width="100%" height={220}>
                <LineChart data={progress} margin={{ top: 16, right: 24, left: 0, bottom: 0 }}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="date" />
                  <YAxis allowDecimals={false} />
                  <Tooltip />
                  <Legend />
                  <Line type="monotone" dataKey="cigarettesSmoked" stroke="#1976d2" strokeWidth={3} name="Số điếu" dot={{ r: 5 }} />
                </LineChart>
              </ResponsiveContainer>
            </div>
            <div style={{ flex: '1 1 400px', minWidth: 320, maxWidth: 600 }}>
              <div style={{ fontWeight: 600, color: '#f59e42', marginBottom: 8, textAlign: 'center' }}>Mức độ thèm thuốc</div>
              <ResponsiveContainer width="100%" height={220}>
                <BarChart data={progress} margin={{ top: 16, right: 24, left: 0, bottom: 0 }}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="date" />
                  <YAxis allowDecimals={false} />
                  <Tooltip />
                  <Legend />
                  <Bar dataKey="cravingLevel" fill="#f59e42" name="Thèm thuốc" radius={[8,8,0,0]} />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>
          <div style={{ display: 'flex', gap: 32, flexWrap: 'wrap', justifyContent: 'center' }}>
            <div style={{ flex: '1 1 400px', minWidth: 320, maxWidth: 600 }}>
              <div style={{ fontWeight: 600, color: '#43a047', marginBottom: 8, textAlign: 'center' }}>Tâm trạng mỗi ngày</div>
              <ResponsiveContainer width="100%" height={220}>
                <LineChart data={progress} margin={{ top: 16, right: 24, left: 0, bottom: 0 }}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="date" />
                  <YAxis allowDecimals={false} />
                  <Tooltip />
                  <Legend />
                  <Line type="monotone" dataKey="moodLevel" stroke="#43a047" strokeWidth={3} name="Tâm trạng" dot={{ r: 5 }} />
                </LineChart>
              </ResponsiveContainer>
            </div>
            <div style={{ flex: '1 1 400px', minWidth: 320, maxWidth: 600 }}>
              <div style={{ fontWeight: 600, color: '#1e88e5', marginBottom: 8, textAlign: 'center' }}>Thời gian tập thể dục (phút)</div>
              <ResponsiveContainer width="100%" height={220}>
                <BarChart data={progress} margin={{ top: 16, right: 24, left: 0, bottom: 0 }}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="date" />
                  <YAxis allowDecimals={false} />
                  <Tooltip />
                  <Legend />
                  <Bar dataKey="exerciseMinutes" fill="#1e88e5" name="Tập thể dục" radius={[8,8,0,0]} />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>
        </div>
      )}
      {progress && Array.isArray(progress) && progress.length > 0 && (
        <div style={{ marginTop: 24, overflowX: 'auto' }}>
          <table style={{ width: '100%', minWidth: 900, borderCollapse: 'collapse', background: '#f8fafc', borderRadius: 12, overflow: 'hidden', fontSize: 16, margin: '0 auto' }}>
            <thead style={{ background: '#1976d2', color: '#fff' }}>
              <tr>
                <th style={{ padding: 12, textAlign: 'center' }}>Ngày</th>
                <th style={{ padding: 12, textAlign: 'center' }}>Số điếu</th>
                <th style={{ padding: 12, textAlign: 'center' }}>Thèm thuốc</th>
                <th style={{ padding: 12, textAlign: 'center' }}>Tâm trạng</th>
                <th style={{ padding: 12, textAlign: 'center' }}>Thể dục (phút)</th>
                <th style={{ padding: 12, textAlign: 'center' }}>Ghi chú</th>
                <th style={{ padding: 12, textAlign: 'center' }}>Phản hồi HLV</th>
              </tr>
            </thead>
            <tbody>
              {progress.map((item: any) => (
                <tr key={item.progressId} style={{ background: '#fff', borderBottom: '1px solid #e5e7eb' }}>
                  <td style={{ padding: 10, textAlign: 'center' }}>{item.date}</td>
                  <td style={{ padding: 10, textAlign: 'center' }}>{item.cigarettesSmoked}</td>
                  <td style={{ padding: 10, textAlign: 'center' }}>{item.cravingLevel}</td>
                  <td style={{ padding: 10, textAlign: 'center' }}>{item.moodLevel}</td>
                  <td style={{ padding: 10, textAlign: 'center' }}>{item.exerciseMinutes}</td>
                  <td style={{ padding: 10, textAlign: 'center' }}>{item.notes || '-'}</td>
                  <td style={{ padding: 10, textAlign: 'center' }}>{item.coachFeedback || '-'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
      {/* Nếu không có dữ liệu */}
      {progress && Array.isArray(progress) && progress.length === 0 && (
        <div style={{ color: '#888', textAlign: 'center', marginTop: 32 }}>Chưa có dữ liệu tiến độ.</div>
      )}
    </div>
  );
};

export default ProgressPlanPage; 