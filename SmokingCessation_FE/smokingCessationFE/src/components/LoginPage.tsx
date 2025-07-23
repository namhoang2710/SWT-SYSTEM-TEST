// src/components/LoginPage.tsx
import React, { useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { useRotatingImage } from '../hooks/useRotatingImage';
import apiClient from '../api/apiClient';

export default function LoginPage() {
  const navigate = useNavigate();
  const location = useLocation();
  const { login } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | React.ReactNode | null>(null);
  const [showForgot, setShowForgot] = useState(false);
  const [forgotEmail, setForgotEmail] = useState('');
  const [forgotLoading, setForgotLoading] = useState(false);
  const [forgotMsg, setForgotMsg] = useState<string | null>(null);
  
  // Get the current rotating image
  const currentImage = useRotatingImage();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);

    try {
      // Validate email format
      if (!email.match(/^[\w.-]+@[\w.-]+\.[a-zA-Z]{3,}$/)) {
        setError('Email không hợp lệ');
        return;
      }

      // Validate password
      if (password.length < 6) {
        setError('Mật khẩu phải có ít nhất 6 ký tự');
        return;
      }

      await login(email, password);
      
      // Get the redirect path from location state or default to home
      const from = location.state?.from?.pathname || "/home";
      navigate(from, { replace: true });
    } catch (err: any) {
      console.error('Login error:', err);
      if (
        err.message === 'Invalid email or password' ||
        err.response?.status === 401
      ) {
        setError('Email hoặc mật khẩu không đúng');
      } else if (err.response?.data?.message) {
        setError(err.response.data.message);
      } else {
        setError('Đăng nhập thất bại. Vui lòng thử lại sau.');
      }
    } finally {
      setLoading(false);
    }
  };

  const handleForgot = async (e: React.FormEvent) => {
    e.preventDefault();
    setForgotMsg(null);
    setForgotLoading(true);
    try {
      await apiClient.post('/account/forgot-password', { email: forgotEmail });
      setForgotMsg('Đã gửi email đặt lại mật khẩu (nếu email tồn tại trong hệ thống). Vui lòng kiểm tra hộp thư.');
    } catch (err: any) {
      setForgotMsg('Không thể gửi email. Vui lòng thử lại hoặc kiểm tra email.');
    } finally {
      setForgotLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100">
      <div className="container mx-auto px-4 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 lg:gap-12 items-center max-w-6xl mx-auto">
          {/* Left side - Image and Text */}
          <div className="hidden lg:block relative rounded-3xl overflow-hidden shadow-2xl order-2 lg:order-1 h-[600px]">
            <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/50 to-transparent z-10"></div>
            <img
              src={currentImage.src}
              alt={currentImage.alt}
              className="w-full h-full object-cover transition-opacity duration-1000"
            />
            <div className="absolute inset-0 z-20 flex flex-col justify-end p-8 md:p-10">
              <div className="max-w-md">
                <h2 className="text-3xl md:text-4xl font-bold text-white mb-4">
                  Chào mừng trở lại!
                </h2>
                <p className="text-lg text-gray-200 mb-8">
                  Đăng nhập để tiếp tục hành trình không khói thuốc của bạn
                </p>
                <div className="grid grid-cols-2 gap-4">
                  <div className="bg-white/10 backdrop-blur-sm rounded-xl p-4 border border-white/20">
                    <div className="text-2xl font-bold text-[#8b5cf6] mb-1">24/7</div>
                    <div className="text-sm text-gray-200">Hỗ trợ 24/7</div>
                  </div>
                  <div className="bg-white/10 backdrop-blur-sm rounded-xl p-4 border border-white/20">
                    <div className="text-2xl font-bold text-[#8b5cf6] mb-1">100%</div>
                    <div className="text-sm text-gray-200">Miễn phí sử dụng</div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Right side - Login Form */}
          <div className="bg-white/80 backdrop-blur-md rounded-3xl shadow-2xl p-6 md:p-8 lg:p-10 flex flex-col justify-center border border-white/40 animate-fade-in-up">
            <div className="max-w-md mx-auto w-full">
              <div className="flex flex-col items-center mb-6">
                <img src="/images/logo.png" alt="Logo" className="w-16 h-16 mb-2 drop-shadow-lg" />
                <h2 className="text-2xl md:text-3xl font-bold text-gray-900 mb-2 bg-gradient-to-r from-[#8b5cf6] to-[#6366f1] bg-clip-text text-transparent">Đăng nhập</h2>
                <p className="text-gray-600">Đăng nhập để tiếp tục hành trình không khói thuốc của bạn</p>
              </div>

              {error && (
                <div className="mb-6 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg shadow animate-fade-in">
                  <span className="font-semibold">{error}</span>
                </div>
              )}

              {!showForgot ? (
                <form onSubmit={handleSubmit} className="space-y-4">
                  <div>
                    <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-1">
                      Địa chỉ Email
                    </label>
                    <input
                      id="email"
                      name="email"
                      type="email"
                      required
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      className="w-full px-4 py-3 rounded-lg border border-gray-300 focus:ring-2 focus:ring-[#8b5cf6] focus:border-[#8b5cf6] focus:outline-none transition-colors bg-white/90 shadow-sm"
                      placeholder="emailcuaban@example.com"
                    />
                  </div>
                  <div>
                    <label htmlFor="password" className="block text-sm font-medium text-gray-700 mb-1">
                      Mật khẩu
                    </label>
                    <input
                      id="password"
                      name="password"
                      type="password"
                      required
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      className="w-full px-4 py-3 rounded-lg border border-gray-300 focus:ring-2 focus:ring-[#8b5cf6] focus:border-[#8b5cf6] focus:outline-none transition-colors bg-white/90 shadow-sm"
                      placeholder="••••••••"
                    />
                  </div>
                  <button
                    type="submit"
                    disabled={loading}
                    className={`w-full py-3 px-4 rounded-lg text-white font-semibold shadow-lg transition-all duration-200 text-lg tracking-wide focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-[#8b5cf6] bg-gradient-to-r from-[#8b5cf6] to-[#6366f1] hover:from-[#7a4cd6] hover:to-[#6366f1] ${loading ? 'opacity-60 cursor-not-allowed' : ''}`}
                  >
                    {loading ? (
                      <div className="flex items-center justify-center">
                        <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin mr-2"></div>
                        Đang đăng nhập...
                      </div>
                    ) : (
                      'Đăng nhập'
                    )}
                  </button>
                  <div className="flex justify-between items-center text-sm mt-2">
                    <a href="#" className="text-[#8b5cf6] hover:text-[#7a4cd6] font-medium" onClick={e => { e.preventDefault(); setShowForgot(true); }}>
                      Quên mật khẩu?
                    </a>
                    <span>
                      Chưa có tài khoản?{' '}
                      <a href="/register" className="text-[#8b5cf6] hover:text-[#7a4cd6] font-medium">
                        Đăng ký
                      </a>
                    </span>
                  </div>
                </form>
              ) : (
                <form onSubmit={handleForgot} className="space-y-4 animate-fade-in">
                  <div>
                    <label htmlFor="forgotEmail" className="block text-sm font-medium text-gray-700 mb-1">
                      Nhập email để đặt lại mật khẩu
                    </label>
                    <input
                      id="forgotEmail"
                      name="forgotEmail"
                      type="email"
                      required
                      value={forgotEmail}
                      onChange={e => setForgotEmail(e.target.value)}
                      className="w-full px-4 py-3 rounded-lg border border-gray-300 focus:ring-2 focus:ring-[#8b5cf6] focus:border-[#8b5cf6] focus:outline-none transition-colors bg-white/90 shadow-sm"
                      placeholder="emailcuaban@example.com"
                    />
                  </div>
                  <button
                    type="submit"
                    disabled={forgotLoading}
                    className={`w-full py-3 px-4 rounded-lg text-white font-semibold shadow-lg transition-all duration-200 text-lg tracking-wide focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-[#8b5cf6] bg-gradient-to-r from-[#8b5cf6] to-[#6366f1] hover:from-[#7a4cd6] hover:to-[#6366f1] ${forgotLoading ? 'opacity-60 cursor-not-allowed' : ''}`}
                  >
                    {forgotLoading ? 'Đang gửi...' : 'Gửi email đặt lại mật khẩu'}
                  </button>
                  {forgotMsg && <div className="text-center text-sm text-green-600 mt-2">{forgotMsg}</div>}
                  <button type="button" className="w-full mt-2 py-2 rounded-lg bg-gray-200 text-gray-700 font-medium" onClick={() => setShowForgot(false)}>
                    Quay lại đăng nhập
                  </button>
                </form>
              )}
            </div>
          </div>
        </div>
      </div>
      <style>{`
        .animate-fade-in {
          animation: fadeIn 1.2s cubic-bezier(0.4,0,0.2,1) both;
        }
        .animate-fade-in-up {
          animation: fadeInUp 1.2s cubic-bezier(0.4,0,0.2,1) both;
        }
        @keyframes fadeIn {
          from { opacity: 0; }
          to { opacity: 1; }
        }
        @keyframes fadeInUp {
          from { opacity: 0; transform: translateY(40px); }
          to { opacity: 1; transform: none; }
        }
      `}</style>
    </div>
  );
}
