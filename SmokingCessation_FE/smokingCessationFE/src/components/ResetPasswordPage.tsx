import React, { useState, useEffect } from 'react';
import { useSearchParams, useNavigate } from 'react-router-dom';
import { authService } from '../api/services/authService';
import { toast } from 'react-toastify';

const ResetPasswordPage: React.FC = () => {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const token = searchParams.get('token') || '';
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  // Kiểm tra token khi component được tải
  useEffect(() => {
    if (!token) {
      setError('Thiếu token xác thực. Vui lòng kiểm tra lại đường dẫn hoặc yêu cầu đặt lại mật khẩu mới.');
    } else {
      console.log('Token found in URL:', token);
    }
  }, [token]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setMsg(null);
    setError(null);
    
    if (!token) {
      setError('Thiếu token xác thực. Vui lòng kiểm tra lại đường dẫn hoặc yêu cầu đặt lại mật khẩu mới.');
      return;
    }
    
    if (newPassword.length < 6) {
      setError('Mật khẩu phải có ít nhất 6 ký tự.');
      return;
    }
    
    if (newPassword !== confirmPassword) {
      setError('Mật khẩu nhập lại không khớp.');
      return;
    }
    
    setLoading(true);
    
    try {
      console.log('Attempting to reset password with token:', token);
      await authService.resetPassword(token, newPassword);
      
      setMsg('Đổi mật khẩu thành công! Bạn có thể đăng nhập với mật khẩu mới.');
      toast.success('Đổi mật khẩu thành công!');
      
      // Chuyển hướng đến trang đăng nhập sau 2 giây
      setTimeout(() => navigate('/login'), 2000);
    } catch (err: any) {
      console.error('Password reset error:', err);
      
      // Xử lý các loại lỗi cụ thể
      if (err.response?.data?.message) {
        setError(err.response.data.message);
      } else if (err.message) {
        setError(err.message);
      } else {
        setError('Đổi mật khẩu thất bại. Token không hợp lệ hoặc đã hết hạn.');
      }
      
      toast.error('Đổi mật khẩu thất bại. Vui lòng thử lại.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-gray-50 to-gray-100">
      <div className="bg-white rounded-2xl shadow-xl p-8 max-w-md w-full">
        <h2 className="text-2xl font-bold mb-4 text-center">Đặt lại mật khẩu</h2>
        
        {!token ? (
          <div className="text-red-600 text-center mb-4">
            Thiếu token xác thực. Vui lòng kiểm tra lại đường dẫn hoặc yêu cầu đặt lại mật khẩu mới.
          </div>
        ) : (
          <form onSubmit={handleSubmit} className="space-y-4">
            <input type="hidden" value={token} />
            <div>
              <label className="block text-sm font-medium mb-1">Mật khẩu mới</label>
              <input
                type="password"
                value={newPassword}
                onChange={e => setNewPassword(e.target.value)}
                className="w-full px-4 py-3 rounded-lg border border-gray-300 focus:ring-2 focus:ring-[#8b5cf6] focus:border-[#8b5cf6] focus:outline-none transition-colors bg-white/90 shadow-sm"
                placeholder="Nhập mật khẩu mới"
                required
              />
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">Nhập lại mật khẩu mới</label>
              <input
                type="password"
                value={confirmPassword}
                onChange={e => setConfirmPassword(e.target.value)}
                className="w-full px-4 py-3 rounded-lg border border-gray-300 focus:ring-2 focus:ring-[#8b5cf6] focus:border-[#8b5cf6] focus:outline-none transition-colors bg-white/90 shadow-sm"
                placeholder="Nhập lại mật khẩu mới"
                required
              />
            </div>
            {error && <div className="text-red-600 text-center text-sm">{error}</div>}
            {msg && <div className="text-green-600 text-center text-sm">{msg}</div>}
            <button
              type="submit"
              disabled={loading}
              className={`w-full py-3 px-4 rounded-lg text-white font-semibold shadow-lg transition-all duration-200 text-lg tracking-wide focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-[#8b5cf6] bg-gradient-to-r from-[#8b5cf6] to-[#6366f1] hover:from-[#7a4cd6] hover:to-[#6366f1] ${loading ? 'opacity-60 cursor-not-allowed' : ''}`}
            >
              {loading ? 'Đang đổi mật khẩu...' : 'Đổi mật khẩu'}
            </button>
          </form>
        )}
        
        <div className="mt-4 text-center">
          <a href="/login" className="text-[#8b5cf6] hover:text-[#7a4cd6] text-sm">
            Quay lại trang đăng nhập
          </a>
        </div>
      </div>
    </div>
  );
};

export default ResetPasswordPage; 