import React, { useState, useEffect, useRef } from 'react';
import { Link, useNavigate } from "react-router-dom";
import styles from './Navbar.module.css';
import { useAuth } from '../contexts/AuthContext';

const Navbar: React.FC = () => {
  const { isAuthenticated, user, logout } = useAuth();
  const navigate = useNavigate();
  const [isOpen, setIsOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  // Close dropdown when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleLogout = async () => {
    try {
      await logout();
      navigate('/login');
    } catch (error) {
      console.error('Logout failed:', error);
    }
  };

  return (
    <nav className={styles.navbar}>
      <div className={styles.container}>
        <Link to="/" className={styles.brand} aria-label="Smoking Cessation Home">
          <img src="/images/logo.png" alt="Smoking Cessation Logo" className={styles.logo} />
          <div className={styles.brandText}>
            <span className={styles.brandName}>Cai thuốc lá thông minh</span>
            <span className={styles.brandTagline}>Giải pháp hỗ trợ bỏ thuốc hiệu quả</span>
          </div>
        </Link>

        {/* Nếu là admin: chỉ hiện logo */}
        {isAuthenticated && user?.role === 'Admin' ? null : (
          isAuthenticated && (
            <div className="relative" ref={dropdownRef}>
              <button
                onClick={() => setIsOpen(!isOpen)}
                className={styles.profileButton}
                aria-expanded={isOpen}
                aria-haspopup="true"
              >
                <div className={styles.profileInfo}>
                  <img
                    src={user?.image || '/images/default-avatar.png'}
                    alt="Profile"
                    className={styles.profileImage}
                  />
                  <div className={styles.profileGreeting}>
                    <span className={styles.greetingText}>Xin chào,</span>
                    <span className={styles.userName}>{user?.name}</span>
                  </div>
                </div>
                <i className={`fas fa-chevron-${isOpen ? 'up' : 'down'} ${styles.dropdownIcon}`}></i>
              </button>

              {isOpen && (
                <div className={styles.dropdown}>
                  <div className={styles.dropdownHeader}>
                    <img
                      src={user?.image || '/images/default-avatar.png'}
                      alt="Profile"
                      className={styles.dropdownProfileImage}
                    />
                    <div className={styles.dropdownUserInfo}>
                      <p className={styles.dropdownName}>{user?.name}</p>
                      <p className={styles.dropdownEmail}>{user?.email}</p>
                      <p className={styles.dropdownRole}>{
                        user?.role === 'ROLE_ADMIN'
                          ? 'Quản trị viên'
                          : user?.role === 'Coach'
                            ? 'Huấn luyện viên'
                            : user?.role === 'Member'
                              ? 'Thành viên'
                              : user?.role || ''
                      }</p>
                    </div>
                  </div>

                  <div className={styles.dropdownDivider}></div>

                  <div className={styles.dropdownContent}>
                    <Link
                      to="/profile"
                      className={styles.dropdownLink}
                      onClick={() => setIsOpen(false)}
                    >
                      <i className="fas fa-user"></i>
                      Hồ sơ của tôi
                    </Link>
                    <Link
                      to="/my-blogs"
                      className={styles.dropdownLink}
                      onClick={() => setIsOpen(false)}
                    >
                      <i className="fas fa-pencil-alt"></i>
                      Bài viết của tôi
                    </Link>
                    {user?.role !== 'Coach' && (
                      <Link
                        to="/my-packages"
                        className={styles.dropdownLink}
                        onClick={() => setIsOpen(false)}
                      >
                        <i className="fas fa-box"></i>
                        Gói dịch vụ của tôi
                      </Link>
                    )}
                    {user?.role !== 'Coach' && (
                      <Link
                        to="/smoking-log"
                        className={styles.dropdownLink}
                        onClick={() => setIsOpen(false)}
                      >
                        <i className="fas fa-chart-line"></i>
                        Nhật ký hút thuốc
                      </Link>
                    )}
                    {user?.role !== 'Coach' && (
                      <Link
                        to="/consultation-history"
                        className={styles.dropdownLink}
                        onClick={() => setIsOpen(false)}
                      >
                        <i className="fas fa-history"></i>
                        Lịch sử tư vấn
                      </Link>
                    )}
                    <button
                      onClick={handleLogout}
                      className={styles.logoutButton}
                    >
                      <i className="fas fa-sign-out-alt"></i>
                      Đăng xuất
                    </button>
                  </div>
                </div>
              )}
            </div>
          )
        )}
      </div>
    </nav>
  );
};

export default Navbar; 