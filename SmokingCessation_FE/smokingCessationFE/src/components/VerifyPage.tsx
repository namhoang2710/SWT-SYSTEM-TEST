import React, { useEffect, useState, useRef } from 'react';
import { useSearchParams, Link } from 'react-router-dom';
import { authService } from '../api/services/authService';
import { Reveal } from '../animation/Reveal';
import { SlideReveal } from '../animation/SlideReveal';
import styles from './VerifyPage.module.css';
import successImg from '../assets/react.svg'; // Thay bằng hình ảnh phù hợp nếu có

const VerifyPage: React.FC = () => {
  const [searchParams] = useSearchParams();
  const [status, setStatus] = useState<'verifying' | 'success' | 'error'>('verifying');
  const [message, setMessage] = useState('');
  const calledRef = useRef(false);

  useEffect(() => {
    if (calledRef.current) return;
    calledRef.current = true;

    const verify = async () => {
      const code = searchParams.get('code');
      console.log('FE nhận code:', code); // Log code FE nhận được
      if (!code) {
        setStatus('error');
        setMessage('Không tìm thấy mã xác thực.');
        return;
      }

      try {
        const responseMessage = await authService.verifyAccount(code);
        console.log('Kết quả trả về từ backend:', responseMessage); // Log kết quả trả về
        setStatus('success');
        setMessage(responseMessage || 'Tài khoản của bạn đã được xác thực thành công!');
      } catch (error: any) {
        console.error('Lỗi xác thực FE:', error);
        setStatus('error');
        setMessage(error.response?.data || 'Xác thực thất bại. Mã không hợp lệ hoặc đã hết hạn.');
      }
    };

    verify();
  }, [searchParams]);

  const renderContent = () => {
    switch (status) {
      case 'verifying':
        return (
          <SlideReveal>
            <div className={styles.centerContent}>
              <div className={styles.loader}></div>
              <h1 className={styles.title + ' text-yellow-600'}>Đang xác thực tài khoản...</h1>
              <p className={styles.desc}>Vui lòng chờ trong giây lát.</p>
            </div>
          </SlideReveal>
        );
      case 'success':
        return (
          <Reveal>
            <div className={styles.centerContent}>
              <img src={successImg} alt="success" className={styles.illustration + ' animate-bounce'} />
              <h1 className={styles.title + ' text-green-600'}>Xác thực thành công!</h1>
              <p className={styles.desc}>{message}</p>
              <Link
                to="/login"
                className={styles.button + ' bg-blue-500 hover:bg-blue-600'}
              >
                Đi đến trang đăng nhập
              </Link>
            </div>
          </Reveal>
        );
      case 'error':
        return (
          <Reveal>
            <div className={styles.centerContent}>
              <img src="/images/non-smoking.jpg" alt="error" className={styles.illustration + ' animate-shake'} />
              <h1 className={styles.title + ' text-red-500'}>Xác thực thất bại</h1>
              <p className={styles.desc}>{message}</p>
              <Link
                to="/register"
                className={styles.button + ' bg-gray-500 hover:bg-gray-600'}
              >
                Thử lại đăng ký
              </Link>
            </div>
          </Reveal>
        );
    }
  };

  return (
    <div className={styles.bg + " flex items-center justify-center min-h-screen"}>
      <div className={styles.card + " shadow-lg text-center max-w-md w-full"}>
        {renderContent()}
      </div>
    </div>
  );
};

export default VerifyPage; 