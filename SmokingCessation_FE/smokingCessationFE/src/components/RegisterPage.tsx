import React, { useState, useRef } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { authService, type RegisterRequest } from '../api/services/authService';
import { uploadImage } from '../api/services/uploadService';
import { useRotatingImage } from '../hooks/useRotatingImage';
import { toast } from 'react-toastify';

interface RegisterFormData {
  email: string;
  password: string;
  confirmPassword: string;
  name: string;
  dob: string;
  gender: string;
  image?: string;
}

export default function RegisterPage() {
  const navigate = useNavigate();
  const location = useLocation();
  const fileInputRef = useRef<HTMLInputElement>(null);

  const [formData, setFormData] = useState<RegisterFormData>({
    email: '',
    password: '',
    confirmPassword: '',
    name: '',
    dob: '',
    gender: 'Nam',
  });

  const [imagePreview, setImagePreview] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({});
  const [uploadProgress, setUploadProgress] = useState(0);

  // Get the current rotating image
  const currentImage = useRotatingImage();

  const handleImageChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      if (!file.type.startsWith('image/')) {
        setError('Vui lòng chọn file ảnh');
        return;
      }
      
      if (file.size > 5 * 1024 * 1024) {
        setError('Kích thước ảnh không được vượt quá 5MB');
        return;
      }

      try {
        setLoading(true);
        const imageUrl = await uploadImage(file);
        setFormData(prev => ({
          ...prev,
          image: imageUrl
        }));
        
        const reader = new FileReader();
        reader.onloadend = () => {
          setImagePreview(reader.result as string);
        };
        reader.readAsDataURL(file);
      } catch (err) {
        setError('Không thể tải lên ảnh. Vui lòng thử lại sau.');
      } finally {
        setLoading(false);
      }
    }
  };

  const validateForm = () => {
    const errors: Record<string, string> = {};
    
    if (!formData.email.match(/^[\w.-]+@[\w.-]+\.[a-zA-Z]{3,}$/)) {
      errors.email = 'Email không hợp lệ';
    }

    if (formData.password.length < 6) {
      errors.password = 'Mật khẩu phải có ít nhất 6 ký tự';
    }

    if (formData.password !== formData.confirmPassword) {
      errors.confirmPassword = 'Mật khẩu không khớp';
    }

    if (!formData.name.trim()) {
      errors.name = 'Tên không được để trống';
    }

    if (!formData.dob) {
      errors.dob = 'Vui lòng chọn ngày sinh';
    } else {
      const birthDate = new Date(formData.dob);
      const today = new Date();
      let age = today.getFullYear() - birthDate.getFullYear();
      const m = today.getMonth() - birthDate.getMonth();
      if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
        age--;
      }
      if (isNaN(age) || age < 1 || age > 100) {
        errors.dob = 'Tuổi phải từ 1 đến 100';
      }
    }

    if (!formData.gender) {
      errors.gender = 'Vui lòng chọn giới tính';
    }

    setFieldErrors(errors);
    return Object.keys(errors).length === 0;
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
    
    // Clear error when user starts typing
    setFieldErrors(prev => ({
      ...prev,
      [name]: ''
    }));
  };

  const calculateAge = (dob: string): number => {
    const birthDate = new Date(dob);
    const today = new Date();
    let age = today.getFullYear() - birthDate.getFullYear();
    const m = today.getMonth() - birthDate.getMonth();
    if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }
    return age;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    if (!validateForm()) {
      return;
    }

    setLoading(true);

    try {
      const age = calculateAge(formData.dob);
      const registerData: RegisterRequest = {
        email: formData.email,
        password: formData.password,
        name: formData.name,
        yearbirth: age, // Đổi thành yearbirth
        gender: formData.gender === 'Nam' ? 'male' : 'female', // Chuyển đổi sang đúng format backend
        image: formData.image
      };

      await authService.register(registerData);
      toast.success('Đăng ký thành công! Vui lòng kiểm tra email để xác thực tài khoản của bạn.', {
        position: 'top-center',
        autoClose: 3500,
        closeOnClick: true,
        pauseOnHover: true,
        style: { minWidth: 320, fontSize: 17, borderRadius: 12, fontWeight: 500 }
      });
      const from = location.state?.from?.pathname || "/login";
      navigate(from, { 
        replace: true,
        state: { 
          message: 'Đăng ký thành công! Vui lòng kiểm tra email để xác thực tài khoản của bạn.' 
        }
      });
    } catch (err: any) {
      console.error('Registration error:', err);
      if (err.response?.status === 409) {
        setError('Email này đã được sử dụng. Vui lòng sử dụng email khác.');
      } else {
        setError(err.response?.data?.message || 'Đăng ký thất bại. Vui lòng thử lại sau.');
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100">
      <div className="container mx-auto px-4 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 lg:gap-12 items-center max-w-6xl mx-auto">
          {/* Left side - Registration Form */}
          <div className="bg-white rounded-3xl shadow-xl p-6 md:p-8 lg:p-10 flex flex-col justify-center">
            <div className="text-center mb-6">
              <h2 className="text-2xl md:text-3xl font-bold text-gray-900 mb-2">Tạo tài khoản của bạn</h2>
              <p className="text-gray-600">Tham gia cộng đồng của chúng tôi và bắt đầu hành trình không khói thuốc của bạn</p>
            </div>

            {error && (
              <div className="mb-6 bg-red-50 border border-red-200 text-red-600 px-4 py-3 rounded-lg">
                {error}
              </div>
            )}

            <form onSubmit={handleSubmit} className="space-y-4" noValidate>
              {/* Email */}
              <div>
                <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-1">
                  Địa chỉ Email
                </label>
                <input
                  id="email"
                  name="email"
                  type="email"
                  value={formData.email}
                  onChange={handleChange}
                  className={`w-full px-4 py-3 rounded-lg border ${
                    fieldErrors.email
                      ? 'border-red-300 focus:ring-red-500 focus:border-red-500'
                      : 'border-gray-300 focus:ring-purple-500 focus:border-purple-500'
                  } focus:outline-none focus:ring-2 transition-colors`}
                  placeholder="emailcuaban@example.com"
                />
                {fieldErrors.email && (
                  <p className="mt-1 text-sm text-red-600">{fieldErrors.email}</p>
                )}
              </div>

              {/* Password */}
              <div>
                <label htmlFor="password" className="block text-sm font-medium text-gray-700 mb-1">
                  Mật khẩu
                </label>
                <input
                  id="password"
                  name="password"
                  type="password"
                  value={formData.password}
                  onChange={handleChange}
                  className={`w-full px-4 py-3 rounded-lg border ${
                    fieldErrors.password
                      ? 'border-red-300 focus:ring-red-500 focus:border-red-500'
                      : 'border-gray-300 focus:ring-purple-500 focus:border-purple-500'
                  } focus:outline-none focus:ring-2 transition-colors`}
                  placeholder="Nhập mật khẩu của bạn"
                />
                {fieldErrors.password && (
                  <p className="mt-1 text-sm text-red-600">{fieldErrors.password}</p>
                )}
              </div>

              {/* Confirm Password */}
              <div>
                <label htmlFor="confirmPassword" className="block text-sm font-medium text-gray-700 mb-1">
                  Xác nhận mật khẩu
                </label>
                <input
                  id="confirmPassword"
                  name="confirmPassword"
                  type="password"
                  value={formData.confirmPassword}
                  onChange={handleChange}
                  className={`w-full px-4 py-3 rounded-lg border ${
                    fieldErrors.confirmPassword
                      ? 'border-red-300 focus:ring-red-500 focus:border-red-500'
                      : 'border-gray-300 focus:ring-purple-500 focus:border-purple-500'
                  } focus:outline-none focus:ring-2 transition-colors`}
                  placeholder="Xác nhận mật khẩu của bạn"
                />
                {fieldErrors.confirmPassword && (
                  <p className="mt-1 text-sm text-red-600">{fieldErrors.confirmPassword}</p>
                )}
              </div>

              {/* Name */}
              <div>
                <label htmlFor="name" className="block text-sm font-medium text-gray-700 mb-1">
                  Họ và tên
                </label>
                <input
                  id="name"
                  name="name"
                  type="text"
                  value={formData.name}
                  onChange={handleChange}
                  className={`w-full px-4 py-3 rounded-lg border ${
                    fieldErrors.name
                      ? 'border-red-300 focus:ring-red-500 focus:border-red-500'
                      : 'border-gray-300 focus:ring-purple-500 focus:border-purple-500'
                  } focus:outline-none focus:ring-2 transition-colors`}
                  placeholder="Nguyễn Văn A"
                />
                {fieldErrors.name && (
                  <p className="mt-1 text-sm text-red-600">{fieldErrors.name}</p>
                )}
              </div>

              {/* Ngày sinh */}
              <div>
                <label htmlFor="dob" className="block text-sm font-medium text-gray-700 mb-1">
                  Ngày tháng năm sinh
                </label>
                <input
                  id="dob"
                  name="dob"
                  type="date"
                  value={formData.dob}
                  onChange={handleChange}
                  className={`w-full px-4 py-3 rounded-lg border ${
                    fieldErrors.dob
                      ? 'border-red-300 focus:ring-red-500 focus:border-red-500'
                      : 'border-gray-300 focus:ring-purple-500 focus:border-purple-500'
                  } focus:outline-none focus:ring-2 transition-colors`}
                  placeholder="YYYY-MM-DD"
                />
                {fieldErrors.dob && (
                  <p className="mt-1 text-sm text-red-600">{fieldErrors.dob}</p>
                )}
              </div>

              {/* Gender */}
              <div>
                <label htmlFor="gender" className="block text-sm font-medium text-gray-700 mb-1">
                  Giới tính
                </label>
                <select
                  id="gender"
                  name="gender"
                  value={formData.gender}
                  onChange={handleChange}
                  className={`w-full px-4 py-3 rounded-lg border ${
                    fieldErrors.gender
                      ? 'border-red-300 focus:ring-red-500 focus:border-red-500'
                      : 'border-gray-300 focus:ring-purple-500 focus:border-purple-500'
                  } focus:outline-none focus:ring-2 transition-colors`}
                >
                  <option value="Nam">Nam</option>
                  <option value="Nữ">Nữ</option>
                  <option value="Khác">Khác</option>
                </select>
                {fieldErrors.gender && (
                  <p className="mt-1 text-sm text-red-600">{fieldErrors.gender}</p>
                )}
              </div>

              {/* Avatar Upload */}
              {/* <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Ảnh đại diện (tùy chọn)
                </label>
                <div className="flex items-center space-x-4">
                  <div className="relative w-24 h-24 rounded-full overflow-hidden bg-gray-100">
                    {imagePreview ? (
                      <img
                        src={imagePreview}
                        alt="Preview"
                        className="w-full h-full object-cover"
                      />
                    ) : (
                      <div className="w-full h-full flex items-center justify-center text-gray-400">
                        <svg className="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                        </svg>
                      </div>
                    )}
                  </div>
                  
                  <div>
                    <input
                      type="file"
                      ref={fileInputRef}
                      onChange={handleImageChange}
                      accept="image/*"
                      className="hidden"
                    />
                    <button
                      type="button"
                      onClick={() => fileInputRef.current?.click()}
                      className="px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors"
                      disabled={loading}
                    >
                      {loading ? 'Đang tải lên...' : 'Chọn ảnh'}
                    </button>
                    {uploadProgress > 0 && (
                      <div className="mt-2">
                        <div className="w-full bg-gray-200 rounded-full h-2">
                          <div
                            className="bg-green-500 h-2 rounded-full transition-all duration-300"
                            style={{ width: `${uploadProgress}%` }}
                          />
                        </div>
                      </div>
                    )}
                    <p className="mt-1 text-sm text-gray-500">
                      JPG, PNG hoặc GIF. Tối đa 5MB.
                    </p>
                  </div>
                </div>
              </div>  */}

              {/* Submit Button */}
              <button
                type="submit"
                disabled={loading}
                className={`w-full py-3 px-4 rounded-lg text-white font-semibold ${
                  loading
                    ? 'bg-gray-400 cursor-not-allowed'
                    : 'bg-[#8b5cf6] hover:bg-[#7a4cd6] transition-colors'
                }`}
              >
                {loading ? (
                  <div className="flex items-center justify-center">
                    <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin mr-2"></div>
                    Đang đăng ký...
                  </div>
                ) : (
                  'Đăng ký'
                )}
              </button>

              {/* Login Link */}
              <p className="text-center text-sm text-gray-600">
                Đã có tài khoản?{' '}
                <a href="/login" className="text-[#8b5cf6] hover:text-[#7a4cd6] font-medium">
                  Đăng nhập
                </a>
              </p>
            </form>
          </div>

          {/* Right side - Image */}
          <div className="hidden lg:block relative rounded-3xl overflow-hidden shadow-2xl h-[600px]">
            <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/50 to-transparent z-10"></div>
            <img
              src={currentImage.src}
              alt={currentImage.alt}
              className="w-full h-full object-cover transition-opacity duration-1000"
            />
            <div className="absolute inset-0 z-20 flex flex-col justify-end p-8 md:p-10">
              <div className="max-w-md">
                <h2 className="text-3xl md:text-4xl font-bold text-white mb-4">
                  Tham gia cùng chúng tôi
                </h2>
                <p className="text-lg text-gray-200 mb-8">
                  Bắt đầu hành trình không khói thuốc của bạn ngay hôm nay
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
        </div>
      </div>
    </div>
  );
} 