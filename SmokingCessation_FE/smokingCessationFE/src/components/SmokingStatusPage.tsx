import React, { useEffect, useState } from 'react';
import apiClient from '../api/apiClient';
import { toast } from 'react-toastify';
import styles from './SmokingStatusPage.module.css';
import { useAuth } from '../contexts/AuthContext';

import ReactModal from 'react-modal';

interface SmokingLog {
  id: number;
  memberId: number;
  date: string;
  cigarettes: number;
  tobaccoCompany: string | null;
  numberOfCigarettes: number | null;
  cost: number;
  healthStatus: string;
  cravingLevel: number;
  notes: string;
}

const getImageUrl = (imagePath?: string | null) => {
  if (!imagePath || imagePath === 'string') return '/public/images/logo.png';
  if (imagePath.startsWith('http')) return imagePath;
  const filename = imagePath.split('/').pop();
  return `http://localhost:8080/api/images/${filename}`;
};

const SmokingStatusPage: React.FC = () => {
  const [logs, setLogs] = useState<SmokingLog[] | null>(null);
  const [loading, setLoading] = useState(true);
  const { user } = useAuth();
  const [showModal, setShowModal] = useState(false);
  const [form, setForm] = useState({
    cigarettes: '',
    tobaccoCompany: '',
    numberOfCigarettes: '',
    cost: '',
    healthStatus: '',
    cravingLevel: '',
    notes: '',
  });
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    fetchLogs();
  }, []);

  const fetchLogs = async () => {
    setLoading(true);
    try {
      const response = await apiClient.get('/packages/smoking-logs/list');
      setLogs(response.data);
    } catch (error) {
      toast.error('Có lỗi xảy ra khi lấy tình trạng hút thuốc');
      setLogs([]);
    } finally {
      setLoading(false);
    }
  };

  const handleOpenModal = () => setShowModal(true);
  const handleCloseModal = () => setShowModal(false);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const getToday = () => {
    const d = new Date();
    return d.toISOString().slice(0, 10);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    try {
      await apiClient.post('/packages/smoking-log', {
        date: getToday(),
        cigarettes: Number(form.cigarettes),
        tobaccoCompany: form.tobaccoCompany,
        numberOfCigarettes: form.numberOfCigarettes ? Number(form.numberOfCigarettes) : null,
        cost: Number(form.cost),
        healthStatus: form.healthStatus,
        cravingLevel: Number(form.cravingLevel),
        notes: form.notes,
      });
      toast.success('Ghi nhận thành công!');
      setShowModal(false);
      setForm({ cigarettes: '', tobaccoCompany: '', numberOfCigarettes: '', cost: '', healthStatus: '', cravingLevel: '', notes: '' });
      fetchLogs();
    } catch (error) {
      toast.error('Ghi nhận thất bại!');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className={styles.mainWrapper}>
      {/* Left: Profile Card */}
      <div className={styles.profileCard}>
        <div className={styles.avatar}>
          {user?.image ? (
            <img src={getImageUrl(user.image)} alt="User Avatar" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
          ) : (
            <span style={{ color: '#fff', fontWeight: 700, fontSize: 36 }}>User</span>
          )}
        </div>
        <h2 className={styles.profileName}>{user?.name || 'Người dùng'}</h2>
        <p className={styles.profileRole}>{user?.role || 'Thành viên'}</p>
        <p className={styles.profileInfo}>Thông tin cá nhân</p>
      </div>
      {/* Right: Smoking Status Table */}
      <div className={styles.statusCard}>
        <button onClick={handleOpenModal} style={{ marginBottom: 24, background: '#2580e6', color: '#fff', border: 'none', borderRadius: 8, padding: '10px 20px', fontWeight: 600, fontSize: 16, cursor: 'pointer' }}>
          Ghi nhận tình trạng hút thuốc
        </button>
        <ReactModal
          isOpen={showModal}
          onRequestClose={handleCloseModal}
          ariaHideApp={false}
          style={{
            overlay: { backgroundColor: 'rgba(0,0,0,0.2)' },
            content: {
              top: '80px',
              left: '50%',
              right: 'auto',
              bottom: 'auto',
              transform: 'translateX(-50%)',
              maxWidth: 420,
              maxHeight: '90vh',
              overflowY: 'auto',
              borderRadius: 16,
              padding: 0,
              border: 'none',
              boxShadow: '0 2px 16px rgba(0,0,0,0.12)'
            }
          }}
        >
          <form onSubmit={handleSubmit} style={{ padding: 28, display: 'flex', flexDirection: 'column', gap: 18 }}>
            <h3 style={{ textAlign: 'center', marginBottom: 8, color: '#2580e6', fontWeight: 700, fontSize: 22 }}>Ghi nhận tình trạng hút thuốc</h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
              <label style={{ fontWeight: 500 }}>Số điếu hút trong ngày *</label>
              <input type="number" name="cigarettes" value={form.cigarettes} onChange={handleChange} required min={0} style={{ border: '1px solid #d1d5db', borderRadius: 8, padding: '8px 12px', fontSize: 16, outlineColor: '#2580e6' }} />
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
              <label style={{ fontWeight: 500 }}>Hãng thuốc</label>
              <input type="text" name="tobaccoCompany" value={form.tobaccoCompany} onChange={handleChange} style={{ border: '1px solid #d1d5db', borderRadius: 8, padding: '8px 12px', fontSize: 16, outlineColor: '#2580e6' }} />
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
              <label style={{ fontWeight: 500 }}>Số điếu/bao</label>
              <input type="number" name="numberOfCigarettes" value={form.numberOfCigarettes} onChange={handleChange} min={0} style={{ border: '1px solid #d1d5db', borderRadius: 8, padding: '8px 12px', fontSize: 16, outlineColor: '#2580e6' }} />
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
              <label style={{ fontWeight: 500 }}>Chi phí *</label>
              <input type="number" name="cost" value={form.cost} onChange={handleChange} required min={0} style={{ border: '1px solid #d1d5db', borderRadius: 8, padding: '8px 12px', fontSize: 16, outlineColor: '#2580e6' }} />
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
              <label style={{ fontWeight: 500 }}>Tình trạng sức khỏe</label>
              <input type="text" name="healthStatus" value={form.healthStatus} onChange={handleChange} style={{ border: '1px solid #d1d5db', borderRadius: 8, padding: '8px 12px', fontSize: 16, outlineColor: '#2580e6' }} />
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
              <label style={{ fontWeight: 500 }}>Mức độ thèm (0-10)</label>
              <input type="number" name="cravingLevel" value={form.cravingLevel} onChange={handleChange} min={0} max={10} style={{ border: '1px solid #d1d5db', borderRadius: 8, padding: '8px 12px', fontSize: 16, outlineColor: '#2580e6' }} />
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
              <label style={{ fontWeight: 500 }}>Ghi chú</label>
              <textarea name="notes" value={form.notes} onChange={handleChange} style={{ border: '1px solid #d1d5db', borderRadius: 8, padding: '8px 12px', fontSize: 16, outlineColor: '#2580e6', minHeight: 48 }} />
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 8, gap: 12 }}>
              <button type="button" onClick={handleCloseModal} style={{ flex: 1, padding: '10px 0', borderRadius: 8, border: '1px solid #ccc', background: '#f3f4f6', fontWeight: 500, fontSize: 16, cursor: 'pointer' }}>Hủy</button>
              <button type="submit" disabled={submitting} style={{ flex: 1, padding: '10px 0', borderRadius: 8, border: 'none', background: '#2580e6', color: '#fff', fontWeight: 600, fontSize: 16, cursor: 'pointer' }}>{submitting ? 'Đang lưu...' : 'Lưu'}</button>
            </div>
          </form>
        </ReactModal>
        {/* bảng tình trạng hút thuốc */}
        {loading ? (
          <div className={styles.loading}>Đang tải...</div>
        ) : !logs || logs.length === 0 ? (
          <div className={styles.empty}>Bạn chưa cập nhật tình trạng hút thuốc.</div>
        ) : (
          <>
            <div className={styles.title}>Tình trạng hút thuốc</div>
            <table className={styles.table}>
              <thead>
                <tr>
                  <th>Ngày</th>
                  <th>Số điếu</th>
                  <th>Hãng thuốc</th>
                  <th>Số điếu/bao</th>
                  <th>Chi phí</th>
                  <th>Tình trạng sức khỏe</th>
                  <th>Mức độ thèm</th>
                  <th>Ghi chú</th>
                </tr>
              </thead>
              <tbody>
                {logs.map((log) => (
                  <tr key={log.id}>
                    <td>{log.date}</td>
                    <td>{log.cigarettes}</td>
                    <td>{log.tobaccoCompany || '-'}</td>
                    <td>{log.numberOfCigarettes ?? '-'}</td>
                    <td>{log.cost.toLocaleString()} đ</td>
                    <td>{log.healthStatus}</td>
                    <td>{log.cravingLevel}</td>
                    <td>{log.notes}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </>
        )}
      </div>
    </div>
  );
};

export default SmokingStatusPage; 