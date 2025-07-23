import React, { useEffect, useState } from 'react';
import styles from './HomePage.module.css';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import Leaderboard from './Leaderboard';
import BlogLeaderboard from './BlogLeaderboard';
import Billboard from './Billboard';
import PackageSlider from './PackageSlider';
import { getAllPackages, purchasePackage, cancelPackage, getUserPackages, type InformationPackageDTO } from '../api/services/packageService';
import { toast } from 'react-toastify';

const HomePage: React.FC = () => {
  const navigate = useNavigate();
  const { isAuthenticated } = useAuth();
  const [packages, setPackages] = useState<InformationPackageDTO[]>([]);
  const [purchasedPackages, setPurchasedPackages] = useState<number[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [packagesData, userPackagesData] = await Promise.all([
          getAllPackages(),
          isAuthenticated ? getUserPackages() : Promise.resolve([])
        ]);
        
        // Ensure packagesData is an array
        if (!Array.isArray(packagesData)) {
          console.error('Packages data is not an array:', packagesData);
          setPackages([]);
        } else {
          setPackages(packagesData);
        }

        // Ensure userPackagesData is an array and map safely
        const purchasedIds = Array.isArray(userPackagesData) 
          ? userPackagesData.map(pkg => pkg?.infoPackageId).filter(Boolean)
          : [];
        setPurchasedPackages(purchasedIds);
      } catch (error) {
        console.error('Error fetching data:', error);
        toast.error('Không thể tải dữ liệu. Vui lòng thử lại sau.');
        setPackages([]);
        setPurchasedPackages([]);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [isAuthenticated]);

  const handlePurchase = async (packageId: number) => {
    if (!isAuthenticated) {
      toast.info('Vui lòng đăng nhập để mua gói dịch vụ', {
        onClick: () => navigate('/login'),
        closeButton: true,
        autoClose: 5000
      });
      return;
    }

    try {
      await purchasePackage(packageId);
      setPurchasedPackages([...purchasedPackages, packageId]);
      toast.success('Mua gói dịch vụ thành công!');
    } catch (error: any) {
      console.error('Error purchasing package:', error);
      if (error.response?.status === 401) {
        toast.error('Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại', {
          onClick: () => navigate('/login'),
          closeButton: true,
          autoClose: 5000
        });
        return;
      }
      toast.error(error.response?.data?.message || 'Không thể mua gói dịch vụ. Vui lòng thử lại sau.');
    }
  };

  const handleCancel = async (packageId: number) => {
    if (!isAuthenticated) {
      return;
    }

    if (!window.confirm('Bạn có chắc chắn muốn hủy gói dịch vụ này?')) {
      return;
    }

    try {
      await cancelPackage(packageId);
      setPurchasedPackages(purchasedPackages.filter(id => id !== packageId));
      toast.success('Hủy gói dịch vụ thành công!');
    } catch (error: any) {
      console.error('Error canceling package:', error);
      if (error.response?.status === 401) {
        toast.error('Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại', {
          onClick: () => navigate('/login'),
          closeButton: true,
          autoClose: 5000
        });
        return;
      }
      toast.error(error.response?.data?.message || 'Không thể hủy gói dịch vụ. Vui lòng thử lại sau.');
    }
  };

  // Determine the class name for heroContent based on auth state
  const heroContentClass = isAuthenticated 
    ? `${styles.heroContent} ${styles.authenticatedContent}` 
    : styles.heroContent;

  return (
    <div className={styles.container}>
      <section className={styles.heroSection}>
        <div className={heroContentClass}>
          <h1 className={styles.heroTitle}>
            Chào Mừng Đến Với <span className={styles.highlightText}>Web Cai Nghiện Thuốc Lá</span>
          </h1>
          <div className={styles.separatorLine}></div>
          <p className={styles.heroQuote}>
            "Không biết rằng <span className={styles.highlightText}>cai thuốc lá</span> có thể dễ dàng như vậy."
          </p>
          <p className={styles.heroSubtitle}>
            Chúng tôi cung cấp những công cụ và tài nguyên hiệu quả giúp bạn <span className={styles.highlightText}>từ bỏ thuốc lá</span> mãi mãi.
          </p>
          {!isAuthenticated && (
            <div className={styles.heroButtons}>
              <button className={styles.registerButton} onClick={() => navigate('/register')}>Đăng ký</button>
              <button className={styles.loginButton} onClick={() => navigate('/login')}>Đăng nhập</button>
            </div>
          )}
        </div>
      </section>

      {/* Billboard Section */}
      <section className={styles.billboardSection}>
        <div className={styles.billboardContainer}>
          <Billboard />
        </div>
      </section>

      {/* Leaderboard Section */}
      <section className={styles.leaderboardSection}>
        <div className={styles.leaderboardContainer}>
          <Leaderboard />
          <BlogLeaderboard />
        </div>
      </section>

      {/* Package Section */}
      <section className={styles.packageSection}>
        <div className={styles.packageContainer}>
          <h2 className={styles.packageTitle}>Gói Dịch Vụ Hỗ Trợ Cai Thuốc</h2>
          <p className={styles.packageSubtitle}>
            Chọn gói dịch vụ phù hợp với nhu cầu của bạn và bắt đầu hành trình cai thuốc lá ngay hôm nay
          </p>
          {loading ? (
            <div className="flex justify-center items-center py-12">
              <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500"></div>
            </div>
          ) : (
            <PackageSlider
              packages={packages}
              onPurchase={handlePurchase}
              onCancel={handleCancel}
              isAuthenticated={isAuthenticated}
              purchasedPackages={purchasedPackages}
            />
          )}
        </div>
      </section>
    </div>
  );
};

export default HomePage;