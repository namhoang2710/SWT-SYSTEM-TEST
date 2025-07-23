import React, { useState, useEffect, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import apiClient from '../api/apiClient';
import { uploadImage } from '../api/services/uploadService';
import { useAuth } from '../contexts/AuthContext';
import { authService } from '../api/services/authService';

interface Account {
  id: number;
  email: string;
  name: string;
  yearbirth?: number;
  age: number;
  gender: string;
  role: string;
  status: string;
  image: string | null;
  healthCheckups?: number;
  consultations?: number;
}

const ProfilePage: React.FC = () => {
  const navigate = useNavigate();
  const { user } = useAuth();
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [profile, setProfile] = useState<Account | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [isEditing, setIsEditing] = useState(false);
  const [uploadingImage, setUploadingImage] = useState(false);
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    yearbirth: '',
    gender: '',
    password: '',
    confirmPassword: '',
    image: '',
    motivation: '',
  });
  const [imagePreview, setImagePreview] = useState<string | null>(null);
  const [validationErrors, setValidationErrors] = useState<Record<string, string>>({});
  const [motivation, setMotivation] = useState<string | null>(null);
  const [coachProfile, setCoachProfile] = useState<any>(null);
  const [coachFormData, setCoachFormData] = useState({
    experience: '',
    specialty: '',
    degreeImage: null as File | null,
  });
  const [degreeImagePreview, setDegreeImagePreview] = useState<string | null>(null);

  useEffect(() => {
    if (!user) {
      navigate('/login');
      return;
    }
    setProfile(user as Account);
    setFormData({
      name: user.name,
      email: user.email,
      yearbirth: user.yearbirth?.toString() || '',
      gender: user.gender || '',
      password: '',
      confirmPassword: '',
      image: user.image || '',
      motivation: '',
    });
    if (user.image) {
      setImagePreview(user.image);
    }
    // Nếu là Coach thì gọi API lấy profile coach
    if (user.role === 'Coach') {
      setLoading(true);
      authService.fetchCoachProfile()
        .then(data => setCoachProfile(data))
        .catch(() => setCoachProfile(null))
        .finally(() => setLoading(false));
    } else {
      setLoading(false);
    }
  }, [user, navigate]);

  useEffect(() => {
    if (isEditing && profile?.role === 'Coach' && coachProfile) {
      setCoachFormData({
        experience: coachProfile.experience || '',
        specialty: coachProfile.specialty || '',
        degreeImage: null,
      });
      setDegreeImagePreview(coachProfile.degreeImageUrl || null);
    }
  }, [isEditing, profile, coachProfile]);

  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      if (!file.type.startsWith('image/')) {
        setError('Vui lòng chọn một tệp hình ảnh');
        return;
      }
      if (file.size > 1 * 1024 * 1024) {
        setError('Kích thước ảnh phải nhỏ hơn 1MB');
        return;
      }
      setFormData(prev => ({
        ...prev,
        image: file // Lưu file object, không phải URL
      }));
      const reader = new FileReader();
      reader.onloadend = () => {
        setImagePreview(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
  };

  const validateForm = () => {
    const errors: Record<string, string> = {};
    
    if (!formData.name.trim()) {
      errors.name = 'Tên không được để trống';
    }

    if (!formData.email.match(/^[\w.-]+@[\w.-]+\.[a-zA-Z]{3,}$/)) {
      errors.email = 'Vui lòng nhập địa chỉ email hợp lệ';
    }

    if (!formData.yearbirth) {
      errors.yearbirth = 'Vui lòng nhập năm sinh';
    } else {
      const year = parseInt(formData.yearbirth);
      const now = new Date().getFullYear();
      if (isNaN(year) || year < 1900 || year > now) {
        errors.yearbirth = 'Năm sinh không hợp lệ';
      }
    }

    if (!formData.gender) {
      errors.gender = 'Vui lòng chọn giới tính';
    }

    if (formData.password || formData.confirmPassword) {
      if (formData.password.length < 6) {
        errors.password = 'Mật khẩu phải có ít nhất 6 ký tự';
      }
      if (formData.password !== formData.confirmPassword) {
        errors.confirmPassword = 'Mật khẩu không khớp';
      }
    }

    setValidationErrors(errors);
    return Object.keys(errors).length === 0;
  };

  const handleInputChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>
  ) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
    if (validationErrors[name]) {
      setValidationErrors(prev => ({
        ...prev,
        [name]: ''
      }));
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setSuccess(null);

    if (!validateForm()) {
      return;
    }

    if (!profile || !profile.id) {
      setError("Người dùng chưa được xác thực hoặc ID người dùng không khả dụng.");
      return;
    }

    try {
      const formDataToSend = new FormData();
      formDataToSend.append('name', formData.name);
      formDataToSend.append('email', formData.email);
      formDataToSend.append('yearbirth', formData.yearbirth);
      formDataToSend.append('gender', formData.gender);
      // Chỉ gửi image nếu là file object (user vừa chọn ảnh mới)
      if (formData.image && typeof formData.image !== 'string') {
        formDataToSend.append('image', formData.image);
      }
      if (formData.password) {
        formDataToSend.append('password', formData.password);
      }
      const response = await apiClient.put(`/account/${profile.id}`, formDataToSend, {
        headers: {
          'Content-Type': 'multipart/form-data'
        }
      });
      setProfile(response.data);
      setSuccess('Cập nhật hồ sơ thành công');
      setIsEditing(false);
      setFormData(prev => ({
        ...prev,
        password: '',
        confirmPassword: '',
      }));

      // Nếu là Coach, update coach profile
      if (profile.role === 'Coach') {
        const coachForm = new FormData();
        coachForm.append('accountId', String(profile.id));
        coachForm.append('experience', coachFormData.experience);
        coachForm.append('specialty', coachFormData.specialty);
        if (coachFormData.degreeImage) {
          coachForm.append('image', coachFormData.degreeImage);
        }
        await authService.updateCoachProfile(coachForm);
        // Reload coachProfile mới
        const newCoachProfile = await authService.fetchCoachProfile();
        setCoachProfile(newCoachProfile);
      }
    } catch (error: any) {
      console.error('Lỗi khi cập nhật hồ sơ:', error);
      console.error('Chi tiết lỗi:', {
        status: error.response?.status,
        data: error.response?.data,
        headers: error.response?.headers,
        config: error.config
      });
      
      if (error.response?.status === 401 || error.response?.status === 403) {
        setError('Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.');
        setTimeout(() => {
          navigate('/login');
        }, 2000);
      } else {
        setError(error.response?.data?.message || 'Cập nhật hồ sơ thất bại');
      }
    }
  };

  const handleEditClick = () => {
    setValidationErrors({});
    setError(null);
    setSuccess(null);
    setFormData({
      name: profile?.name || '',
      email: profile?.email || '',
      yearbirth: profile?.yearbirth?.toString() || '',
      gender: profile?.gender || '',
      password: '',
      confirmPassword: '',
      image: profile?.image || '',
      motivation: motivation || '',
    });
    setImagePreview(profile?.image || null);
    setIsEditing(true);
  };

  const handleCancelClick = () => {
    setIsEditing(false);
    setFormData({
      name: profile?.name || '',
      email: profile?.email || '',
      yearbirth: profile?.yearbirth?.toString() || '',
      gender: profile?.gender || '',
      password: '',
      confirmPassword: '',
      image: profile?.image || '',
      motivation: '',
    });
    setImagePreview(profile?.image || null);
    setValidationErrors({});
    setError(null);
  };

  // Hàm chuyển đổi giới tính sang tiếng Việt
  const getGenderLabel = (gender: string) => {
    if (!gender) return '';
    if (gender.toLowerCase() === 'male' || gender === 'Nam') return 'Nam';
    if (gender.toLowerCase() === 'female' || gender === 'Nữ') return 'Nữ';
    return 'Khác';
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 flex items-center justify-center">
        <div className="w-12 h-12 border-4 border-green-400 border-t-transparent rounded-full animate-spin"></div>
      </div>
    );
  }

  if (!profile) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 flex items-center justify-center">
        <div className="bg-red-50 border border-red-200 text-red-600 px-6 py-4 rounded-lg">
          Không tìm thấy hồ sơ
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 py-10 px-4 sm:px-6 lg:px-8">
      <div className="max-w-7xl mx-auto">
        <button
          onClick={() => navigate('/')}
          className="text-gray-600 hover:text-gray-900 transition-colors flex items-center mb-6"
        >
          <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              strokeLinecap="round" strokeLinejoin="round" strokeWidth="2"
              d="M10 19l-7-7m0 0l7-7m-7 7h18"
            />
          </svg>
          Quay lại trang chủ
        </button>

        <div className="max-w-3xl mx-auto">
          <div className="bg-white rounded-2xl shadow-xl overflow-hidden">
            <div className="bg-gradient-to-r from-gray-900 to-gray-800 text-white p-8">
              <div className="flex items-center space-x-6">
                <div className="relative">
                  <div className="w-24 h-24 rounded-full border-4 border-white overflow-hidden">
                    {imagePreview || profile.image ? (
                      <img
                        src={imagePreview || profile.image || undefined}
                        alt={profile.name}
                        className="w-full h-full object-cover"
                      />
                    ) : (
                      <div className="w-full h-full bg-gray-700 flex items-center justify-center text-white text-xl">
                        <svg className="w-12 h-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                        </svg>
                      </div>
                    )}
                  </div>
                  {isEditing && (
                    <button
                      onClick={() => fileInputRef.current?.click()}
                      disabled={uploadingImage}
                      className="absolute bottom-0 right-0 bg-green-500 text-white p-2 rounded-full shadow-lg hover:bg-green-600 transition-colors"
                    >
                      {uploadingImage ? (
                        <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                      ) : (
                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
                        </svg>
                      )}
                    </button>
                  )}
                  <input
                    type="file"
                    ref={fileInputRef}
                    onChange={handleImageChange}
                    accept="image/*"
                    className="hidden"
                  />
                </div>
                <div>
                  <h1 className="text-3xl font-bold mb-2 flex items-center gap-4">
                    {profile.name}
                    <span className="inline-flex items-center bg-green-100 text-green-700 text-sm font-semibold px-3 py-1 rounded-full">
                      🩺 {profile.healthCheckups ?? 0} khám
                    </span>
                    <span className="inline-flex items-center bg-blue-100 text-blue-700 text-sm font-semibold px-3 py-1 rounded-full">
                      💬 {profile.consultations ?? 0} tư vấn
                    </span>
                  </h1>
                  <p className="text-gray-300">{profile.role && profile.role.toLowerCase() === 'member' ? 'Thành viên' : profile.role}</p>
                </div>
              </div>
            </div>

            <div className="p-8">
              {error && (
                <div className="mb-6 bg-red-50 border border-red-200 text-red-600 px-4 py-3 rounded-lg">
                  {error}
                </div>
              )}

              {success && (
                <div className="mb-6 bg-green-50 border border-green-200 text-green-600 px-4 py-3 rounded-lg">
                  {success}
                </div>
              )}

              {!isEditing ? (
                <div className="space-y-4">
                  <div>
                    <h3 className="text-lg font-semibold text-gray-700">Thông tin tài khoản</h3>
                    <div className="mt-2 grid grid-cols-1 gap-4">
                      <div>
                        <label className="block text-sm font-medium text-gray-600">Tên</label>
                        <p className="mt-1 text-gray-900">{profile?.name}</p>
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-600">Email</label>
                        <p className="mt-1 text-gray-900">{profile?.email}</p>
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-600">Năm sinh</label>
                        <p className="mt-1 text-gray-900">{
                          profile?.age ? (new Date().getFullYear() - profile.age) : profile?.yearbirth
                        }</p>
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-600">Giới tính</label>
                        <p className="mt-1 text-gray-900">{getGenderLabel(profile?.gender || '')}</p>
                      </div>
                      {/* Hiển thị lý do cai thuốc nếu là member */}
                      {profile?.role?.toLowerCase() === 'member' && motivation && (
                        <div>
                          <label className="block text-sm font-medium text-green-700">Lý do cai thuốc</label>
                          <p className="mt-1 text-green-900">{motivation}</p>
                        </div>
                      )}
                      {/* Nếu là Coach, hiển thị thêm các trường coachProfile */}
                      {profile?.role === 'Coach' && coachProfile && (
                        <>
                          {coachProfile.coachTitle && (
                            <div className="mt-4">
                              <label className="block text-sm font-semibold text-blue-700">Chức danh</label>
                              <p className="mt-1 text-gray-900">{coachProfile.coachTitle}</p>
                            </div>
                          )}
                          {coachProfile.experience && (
                            <div className="mt-4">
                              <label className="block text-sm font-medium text-gray-900">Kinh nghiệm</label>
                              <p className="mt-1 text-gray-900">{coachProfile.experience}</p>
                            </div>
                          )}
                          {coachProfile.specialty && (
                            <div className="mt-4">
                              <label className="block text-sm font-medium text-gray-900">Chuyên môn</label>
                              <p className="mt-1 text-gray-900">{coachProfile.specialty}</p>
                            </div>
                          )}
                          {coachProfile.image && (
                            <div className="mt-4">
                              <label className="block text-sm font-medium text-gray-900 mb-1">Bằng cấp (ảnh)</label>
                              <img src={coachProfile.image} alt="Bằng cấp" className="mt-2 rounded-lg max-h-40" />
                            </div>
                          )}
                        </>
                      )}
                    </div>
                  </div>
                  <div className="flex justify-end mt-6">
                    <button
                      type="button"
                      onClick={handleEditClick}
                      className="bg-green-600 text-white px-6 py-3 rounded-lg font-semibold hover:bg-green-700 transition-colors shadow-md"
                    >
                      Chỉnh sửa hồ sơ
                    </button>
                  </div>
                </div>
              ) : (
                <form onSubmit={handleSubmit} className="space-y-6">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                      <label htmlFor="name" className="block text-sm font-medium text-gray-700 mb-1">
                        Họ và tên
                      </label>
                      <input
                        id="name"
                        name="name"
                        type="text"
                        value={formData.name}
                        onChange={handleInputChange}
                        disabled={!isEditing}
                        className={`w-full px-4 py-2 rounded-lg border ${
                          validationErrors.name
                            ? 'border-red-300 focus:ring-red-500 focus:border-red-500'
                            : 'border-gray-300 focus:ring-green-500 focus:border-green-500'
                        } focus:outline-none focus:ring-2 transition-colors`}
                      />
                      {validationErrors.name && (
                        <p className="mt-1 text-sm text-red-600">{validationErrors.name}</p>
                      )}
                    </div>
                    <div>
                      <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-1">
                        Địa chỉ Email
                      </label>
                      <input
                        id="email"
                        name="email"
                        type="email"
                        value={formData.email}
                        onChange={handleInputChange}
                        disabled={true}
                        className={`w-full px-4 py-2 rounded-lg border ${
                          validationErrors.email
                            ? 'border-red-300 focus:ring-red-500 focus:border-red-500'
                            : 'border-gray-300 focus:ring-green-500 focus:border-green-500'
                        } focus:outline-none focus:ring-2 transition-colors`}
                      />
                      {validationErrors.email && (
                        <p className="mt-1 text-sm text-red-600">{validationErrors.email}</p>
                      )}
                    </div>
                    <div>
                      <label htmlFor="yearbirth" className="block text-sm font-medium text-gray-700 mb-1">Năm sinh</label>
                      <input
                        id="yearbirth"
                        name="yearbirth"
                        type="number"
                        min="1900"
                        max={new Date().getFullYear()}
                        value={formData.yearbirth}
                        onChange={handleInputChange}
                        disabled={!isEditing}
                        className={`w-full px-4 py-2 rounded-lg border ${validationErrors.yearbirth ? 'border-red-300 focus:ring-red-500 focus:border-red-500' : 'border-gray-300 focus:ring-green-500 focus:border-green-500'} focus:outline-none focus:ring-2 transition-colors`}
                      />
                      {validationErrors.yearbirth && (
                        <p className="mt-1 text-sm text-red-600">{validationErrors.yearbirth}</p>
                      )}
                    </div>
                    <div>
                      <label htmlFor="gender" className="block text-sm font-medium text-gray-700 mb-1">
                        Giới tính
                      </label>
                      <select
                        id="gender"
                        name="gender"
                        value={formData.gender}
                        onChange={handleInputChange}
                        disabled={!isEditing}
                        className={`w-full px-4 py-2 rounded-lg border ${
                          validationErrors.gender
                            ? 'border-red-300 focus:ring-red-500 focus:border-red-500'
                            : 'border-gray-300 focus:ring-green-500 focus:border-green-500'
                        } focus:outline-none focus:ring-2 transition-colors`}
                      >
                        <option value="">Chọn giới tính</option>
                        <option value="Male">Nam</option>
                        <option value="Female">Nữ</option>
                        <option value="Other">Khác</option>
                      </select>
                      {validationErrors.gender && (
                        <p className="mt-1 text-sm text-red-600">{validationErrors.gender}</p>
                      )}
                    </div>
                    <div>
                      <label htmlFor="password" className="block text-sm font-medium text-gray-700 mb-1">
                        Mật khẩu mới
                      </label>
                      <input
                        id="password"
                        name="password"
                        type="password"
                        value={formData.password}
                        onChange={handleInputChange}
                        disabled={!isEditing}
                        className={`w-full px-4 py-2 rounded-lg border ${
                          validationErrors.password
                            ? 'border-red-300 focus:ring-red-500 focus:border-red-500'
                            : 'border-gray-300 focus:ring-green-500 focus:border-green-500'
                        } focus:outline-none focus:ring-2 transition-colors`}
                      />
                      {validationErrors.password && (
                        <p className="mt-1 text-sm text-red-600">{validationErrors.password}</p>
                      )}
                    </div>
                    <div>
                      <label htmlFor="confirmPassword" className="block text-sm font-medium text-gray-700 mb-1">
                        Xác nhận mật khẩu mới
                      </label>
                      <input
                        id="confirmPassword"
                        name="confirmPassword"
                        type="password"
                        value={formData.confirmPassword}
                        onChange={handleInputChange}
                        disabled={!isEditing}
                        className={`w-full px-4 py-2 rounded-lg border ${
                          validationErrors.confirmPassword
                            ? 'border-red-300 focus:ring-red-500 focus:border-red-500'
                            : 'border-gray-300 focus:ring-green-500 focus:border-green-500'
                        } focus:outline-none focus:ring-2 transition-colors`}
                      />
                      {validationErrors.confirmPassword && (
                        <p className="mt-1 text-sm text-red-600">{validationErrors.confirmPassword}</p>
                      )}
                    </div>
                    {/* Motivation cho member */}
                    {profile?.role?.toLowerCase() === 'member' && (
                      <div className="md:col-span-2">
                        <label htmlFor="motivation" className="block text-sm font-medium text-green-700 mb-1">
                          Lý do cai thuốc
                        </label>
                        <textarea
                          id="motivation"
                          name="motivation"
                          value={formData.motivation}
                          onChange={handleInputChange}
                          rows={3}
                          className="w-full px-4 py-2 rounded-lg border border-gray-300 focus:ring-green-500 focus:border-green-500 focus:outline-none focus:ring-2 transition-colors"
                          placeholder="Nhập lý do bạn muốn cai thuốc..."
                        />
                      </div>
                    )}
                    {profile?.role === 'Coach' && isEditing && (
                      <>
                        <div className="md:col-span-2">
                          <label className="block text-sm font-medium text-gray-900 mb-1">Kinh nghiệm</label>
                          <input
                            type="text"
                            name="experience"
                            value={coachFormData.experience}
                            onChange={e => setCoachFormData(f => ({ ...f, experience: e.target.value }))}
                            className="w-full px-4 py-2 rounded-lg border border-gray-300 focus:ring-blue-500 focus:border-blue-500 focus:outline-none focus:ring-2 transition-colors"
                          />
                        </div>
                        <div className="md:col-span-2">
                          <label className="block text-sm font-medium text-gray-900 mb-1">Chuyên môn</label>
                          <input
                            type="text"
                            name="specialty"
                            value={coachFormData.specialty}
                            onChange={e => setCoachFormData(f => ({ ...f, specialty: e.target.value }))}
                            className="w-full px-4 py-2 rounded-lg border border-gray-300 focus:ring-blue-500 focus:border-blue-500 focus:outline-none focus:ring-2 transition-colors"
                          />
                        </div>
                        <div className="md:col-span-2">
                          <label className="block text-sm font-medium text-gray-900 mb-1">Bằng cấp (ảnh)</label>
                          <input
                            type="file"
                            accept="image/*"
                            onChange={e => {
                              const file = e.target.files?.[0] || null;
                              setCoachFormData(f => ({ ...f, degreeImage: file }));
                              if (file) {
                                const reader = new FileReader();
                                reader.onloadend = () => setDegreeImagePreview(reader.result as string);
                                reader.readAsDataURL(file);
                              } else {
                                setDegreeImagePreview(null);
                              }
                            }}
                            className="w-full px-4 py-2 rounded-lg border border-gray-300 focus:ring-blue-500 focus:border-blue-500 focus:outline-none focus:ring-2 transition-colors"
                          />
                          {degreeImagePreview && (
                            <img src={degreeImagePreview} alt="Bằng cấp" className="mt-2 rounded-lg max-h-40" />
                          )}
                        </div>
                      </>
                    )}
                  </div>
                  <div className="flex justify-end space-x-4 mt-6">
                    <button
                      type="button"
                      onClick={handleCancelClick}
                      className="px-6 py-3 rounded-lg font-semibold border border-gray-300 text-gray-700 hover:bg-gray-100 transition-colors shadow-md"
                    >
                      Hủy
                    </button>
                    <button
                      type="submit"
                      className="bg-green-600 text-white px-6 py-3 rounded-lg font-semibold hover:bg-green-700 transition-colors shadow-md"
                    >
                      Lưu thay đổi
                    </button>
                  </div>
                </form>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ProfilePage;