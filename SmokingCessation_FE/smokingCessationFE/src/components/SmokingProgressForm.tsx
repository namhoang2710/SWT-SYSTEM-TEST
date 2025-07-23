import React, { useState, useEffect } from "react";
import apiClient from '../api/apiClient';
import { updateSmokingLog, getActiveUserPackages } from '../api/services/packageService';
import { addDailyProgress } from '../api/services/progressService';

const rowStyle: React.CSSProperties = {
  display: 'flex',
  alignItems: 'center',
  marginBottom: 18,
  gap: 12,
};
const labelStyle: React.CSSProperties = {
  fontWeight: 600,
  minWidth: 130,
  color: '#222',
  flex: '0 0 130px',
};
const inputStyle: React.CSSProperties = {
  flex: 1,
  padding: '10px',
  border: '1px solid #ccc',
  borderRadius: '6px',
  fontSize: '1rem',
  fontFamily: 'inherit',
  background: '#fafbfc',
  transition: 'border 0.2s',
};
const textareaStyle: React.CSSProperties = {
  ...inputStyle,
  minHeight: 60,
  resize: 'vertical',
};
const buttonStyle: React.CSSProperties = {
  width: '100%',
  padding: '12px',
  background: 'linear-gradient(90deg, #1976d2 60%, #42a5f5 100%)',
  color: '#fff',
  border: 'none',
  borderRadius: '6px',
  fontWeight: 700,
  fontSize: '1.1rem',
  cursor: 'pointer',
  marginTop: 8,
  transition: 'background 0.2s',
  boxShadow: '0 2px 8px rgba(25, 118, 210, 0.08)',
};
const formBoxStyle: React.CSSProperties = {
  maxWidth: 520,
  margin: '0 auto',
  background: '#fff',
  borderRadius: 12,
  boxShadow: '0 4px 24px rgba(0,0,0,0.10)',
  padding: '32px 28px 24px 28px',
  fontFamily: 'Segoe UI, Arial, sans-serif',
  position: 'relative',
};
const titleStyle: React.CSSProperties = {
  textAlign: 'center',
  fontWeight: 800,
  fontSize: '1.4rem',
  marginBottom: 24,
  color: '#1976d2',
  letterSpacing: 0.5,
};
const messageStyle: React.CSSProperties = {
  textAlign: 'center',
  marginTop: 12,
  color: '#388e3c',
  fontWeight: 600,
};
const errorStyle: React.CSSProperties = {
  ...messageStyle,
  color: '#d32f2f',
};

// Responsive: mobile về 1 cột
const responsiveStyle: React.CSSProperties = {
  display: 'block',
};

interface SmokingProgressFormProps {
  log?: any;
  onClose?: () => void;
}

const SmokingProgressForm: React.FC<SmokingProgressFormProps> = ({ log, onClose }) => {
  const [form, setForm] = useState({
    planId: 0,
    date: "",
    cigarettesSmoked: 0,
    cravingLevel: 0,
    moodLevel: 0,
    exerciseMinutes: 0,
    notes: "",
  });
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [isMobile, setIsMobile] = useState(false);
  const [loadingProfile, setLoadingProfile] = useState(true);

  // Nếu có log (chỉnh sửa), điền sẵn dữ liệu
  useEffect(() => {
    if (log) {
      setForm({
        planId: log.planId,
        date: log.date || "",
        cigarettesSmoked: log.cigarettesSmoked,
        cravingLevel: log.cravingLevel,
        moodLevel: log.moodLevel,
        exerciseMinutes: log.exerciseMinutes,
        notes: log.notes,
      });
      setLoadingProfile(false);
    } else {
      // Lấy memberId như cũ nếu tạo mới
      const fetchProfile = async () => {
        try {
          const res = await apiClient.get('/member/profile/me');
          const memberId = res.data?.memberId;
          let planId = 0;
          try {
            const plansRes = await apiClient.get('/plans/member/my-plans');
            const activePlan = Array.isArray(plansRes.data)
              ? plansRes.data.find((p: any) => p.status === 'ACTIVE')
              : null;
            if (activePlan) {
              planId = activePlan.planId;
            }
          } catch {}
          setForm(f => ({ ...f, planId: planId, memberId: memberId ?? null }));
        } catch (e) {
          setError('Không lấy được thông tin thành viên hoặc kế hoạch cai thuốc.');
        } finally {
          setLoadingProfile(false);
        }
      };
      fetchProfile();
    }
  }, [log]);

  useEffect(() => {
    const handleResize = () => {
      setIsMobile(window.innerWidth < 600);
    };
    handleResize();
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    const { name, value, type } = e.target;
    setForm({
      ...form,
      [name]: type === "number" ? Number(value) : value,
    });
  };

  const validateForm = () => {
    if (!form.planId || form.planId <= 0) {
      setError('Bạn chưa có kế hoạch cai thuốc hoặc planId không hợp lệ.');
      return false;
    }
    if (!form.date) {
      setError('Vui lòng chọn ngày.');
      return false;
    }
    if (!/^\d{4}-\d{2}-\d{2}$/.test(form.date)) {
      setError('Ngày phải đúng định dạng yyyy-MM-dd.');
      return false;
    }
    if (form.cigarettesSmoked === undefined || form.cigarettesSmoked === null || isNaN(form.cigarettesSmoked)) {
      setError('Vui lòng nhập số điếu thuốc đã hút.');
      return false;
    }
    if (form.cigarettesSmoked < 0) {
      setError('Số điếu thuốc không được nhỏ hơn 0.');
      return false;
    }
    return true;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setMessage("");
    setError("");
    if (!validateForm()) {
      setLoading(false);
      return;
    }
    try {
      if (log && log.id) {
        await updateSmokingLog(log.id, form);
        setMessage("Cập nhật log thành công!");
      } else {
        await addDailyProgress({
          planId: form.planId,
          date: form.date,
          cigarettesSmoked: form.cigarettesSmoked,
          cravingLevel: form.cravingLevel,
          moodLevel: form.moodLevel,
          exerciseMinutes: form.exerciseMinutes
        });
        setMessage("Cập nhật tiến độ thành công!");
        setForm({
          ...form,
          planId: 0,
          date: "",
          cigarettesSmoked: 0,
          cravingLevel: 0,
          moodLevel: 0,
          exerciseMinutes: 0,
          notes: "",
        });
      }
      if (onClose) setTimeout(onClose, 1000);
    } catch (error) {
      setError("Có lỗi xảy ra khi cập nhật tiến độ.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} style={formBoxStyle}>
      <div style={titleStyle}>{log ? "Cập nhật log hút thuốc" : "Cập nhật tiến độ cai thuốc"}</div>
      {loadingProfile ? (
        <div style={{ textAlign: 'center', margin: 16 }}>Đang tải thông tin thành viên...</div>
      ) : (
        <>
          <div style={isMobile ? responsiveStyle : {}}>
            <div style={rowStyle}>
              <label style={labelStyle} htmlFor="date">Ngày</label>
              <input
                style={inputStyle}
                type="date"
                name="date"
                id="date"
                value={form.date}
                onChange={handleChange}
                required
                placeholder="Chọn ngày"
              />
            </div>
            <div style={rowStyle}>
              <label style={labelStyle} htmlFor="cigarettesSmoked">Số điếu thuốc</label>
              <input
                style={inputStyle}
                type="number"
                name="cigarettesSmoked"
                id="cigarettesSmoked"
                value={form.cigarettesSmoked}
                onChange={handleChange}
                min={0}
                required
                placeholder="Nhập số điếu thuốc đã hút"
              />
            </div>
            <div style={rowStyle}>
              <label style={labelStyle} htmlFor="cravingLevel">Mức độ thèm thuốc (0-10)</label>
              <input
                style={inputStyle}
                type="number"
                name="cravingLevel"
                id="cravingLevel"
                value={form.cravingLevel}
                onChange={handleChange}
                min={0}
                max={10}
                required
                placeholder="0 là không thèm, 10 là rất thèm"
              />
            </div>
            <div style={rowStyle}>
              <label style={labelStyle} htmlFor="moodLevel">Mức độ tâm trạng (0 - 10)</label>
              <input
                style={inputStyle}
                type="number"
                name="moodLevel"
                id="moodLevel"
                value={form.moodLevel}
                onChange={handleChange}
                min={0}
                max={10}
                required
                placeholder="0 là rất tệ, 10 là rất tốt"
              />
            </div>
            <div style={rowStyle}>
              <label style={labelStyle} htmlFor="exerciseMinutes">Thời gian tập thể dục (phút)</label>
              <input
                style={inputStyle}
                type="number"
                name="exerciseMinutes"
                id="exerciseMinutes"
                value={form.exerciseMinutes}
                onChange={handleChange}
                min={0}
                required
                placeholder="Nhập số phút tập thể dục"
              />
            </div>
            <div style={rowStyle}>
              <label style={labelStyle} htmlFor="notes">Ghi chú</label>
              <textarea
                style={textareaStyle}
                name="notes"
                id="notes"
                value={form.notes}
                onChange={handleChange}
                placeholder="Ghi chú thêm (nếu có)"
              />
            </div>
          </div>
          <button
            type="submit"
            style={{
              ...buttonStyle,
              opacity: loading || loadingProfile ? 0.7 : 1,
              pointerEvents: loading || loadingProfile ? 'none' : 'auto',
            }}
            disabled={loading || loadingProfile}
          >
            {loading ? (log ? "Đang cập nhật..." : "Đang tạo...") : (log ? "Cập nhật log" : "Cập nhật tiến độ")}
          </button>
        </>
      )}
      {message && <div style={messageStyle}>{message}</div>}
      {error && <div style={errorStyle}>{error}</div>}
    </form>
  );
};

export default SmokingProgressForm; 