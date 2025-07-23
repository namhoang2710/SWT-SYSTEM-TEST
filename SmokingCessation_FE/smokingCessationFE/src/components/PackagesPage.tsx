import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import apiClient from '../api/apiClient';

interface InformationPackageDTO {
  id: number;
  name: string;
  description: string;
  price: number;
  duration: number;
  numberOfConsultations?: number;
  numberOfHealthCheckups?: number;
}

const PackagesPage: React.FC = () => {
  const navigate = useNavigate();
  const { isAuthenticated } = useAuth();
  const [packages, setPackages] = useState<InformationPackageDTO[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchPackages = async () => {
      try {
        setLoading(true);
        
        // Test multiple endpoints
        const endpoints = [
          '/admin/packages/all',
          '/packages/all', 
          '/information-packages',
          '/packages'
        ];

        let success = false;
        
        for (const endpoint of endpoints) {
          try {
            const response = await apiClient.get(endpoint);
            
            if (Array.isArray(response.data)) {
              setPackages(response.data);
              success = true;
              break;
            }
          } catch (err: any) {
            // Continue to next endpoint
          }
        }
        
        if (!success) {
          setError('Không thể tải danh sách gói dịch vụ');
        }
        
      } catch (err: any) {
        setError('Lỗi không xác định khi tải gói dịch vụ');
      } finally {
        setLoading(false);
      }
    };

    fetchPackages();
  }, []);

  const handlePurchase = async (packageId: number, packageName: string) => {
    if (!isAuthenticated) {
      alert('Vui lòng đăng nhập để mua gói dịch vụ');
      navigate('/login');
      return;
    }

    try {
      const token = localStorage.getItem('token');
      const response = await apiClient.post('/packages/buy', {}, {
        headers: {
          'Package-Id': packageId.toString(),
          'Authorization': `Bearer ${token}`
        }
      });
      
      alert(`Mua gói "${packageName}" thành công!`);
      
    } catch (error: any) {
      alert(`Mua gói thất bại: ${error.response?.data?.message || error.message}`);
    }
  };

  // Stripe payment handler
  const handleStripePayment = async (amount: number, currency: string, packageName: string, packageId: number, packageDescription: string) => {
    try {
      const res = await apiClient.post('/payment/create', null, {
        params: { amount, currency }
      });
      console.log("Stripe response:", res.data);
      // Lấy đúng key clientSecret (phòng trường hợp backend trả về khác nhau)
      const clientSecret = res.data.clientSecret || res.data.clientsecret || res.data.client_secret;
      if (clientSecret) {
        navigate("/payment", { state: { clientSecret, packageName, packageId, packagePrice: amount, packageDescription } });
      } else {
        alert('Không lấy được clientSecret từ backend!');
      }
    } catch (err) {
      alert('Lỗi khi tạo thanh toán Stripe!');
      console.error(err);
    }
  };

  if (loading) {
    return (
      <div style={{ 
        minHeight: '100vh', 
        backgroundColor: '#f8fafc', 
        display: 'flex', 
        alignItems: 'center', 
        justifyContent: 'center',
        flexDirection: 'column'
      }}>
        <div style={{ 
          width: '60px', 
          height: '60px', 
          border: '6px solid #e5e7eb', 
          borderTopColor: '#16a34a',
          borderRadius: '50%',
          animation: 'spin 1s linear infinite',
          marginBottom: '20px'
        }}></div>
        <p style={{ fontSize: '18px', color: '#374151' }}>Đang tải danh sách gói dịch vụ...</p>
        
        <style>{`
          @keyframes spin {
            to { transform: rotate(360deg); }
          }
        `}</style>
      </div>
    );
  }

  return (
    <div style={{ minHeight: '100vh', backgroundColor: '#f8fafc', padding: '20px' }}>
      <div style={{ maxWidth: '1200px', margin: '0 auto' }}>
        {/* Header */}
        <div style={{ textAlign: 'center', marginBottom: '40px' }}>
          <button
            onClick={() => navigate('/')}
            style={{
              display: 'flex',
              alignItems: 'center',
              margin: '0 auto 20px',
              padding: '10px 20px',
              backgroundColor: '#6b7280',
              color: 'white',
              border: 'none',
              borderRadius: '8px',
              cursor: 'pointer',
              fontSize: '16px'
            }}
          >
            ← Quay lại trang chủ
          </button>
          
          <h1 style={{ 
            fontSize: '3rem', 
            fontWeight: 'bold', 
            color: '#1f2937',
            marginBottom: '10px'
          }}>
            Gói Dịch Vụ Cai Thuốc Lá
          </h1>
          <p style={{ fontSize: '1.2rem', color: '#6b7280' }}>
            Chọn gói dịch vụ phù hợp để bắt đầu hành trình cai thuốc lá
          </p>
        </div>

        {/* Error */}
        {error && (
          <div style={{ 
            backgroundColor: '#fef2f2', 
            border: '1px solid #fecaca',
            borderRadius: '8px', 
            padding: '20px',
            marginBottom: '30px',
            textAlign: 'center'
          }}>
            <h3 style={{ color: '#dc2626', marginBottom: '10px' }}>❌ Lỗi</h3>
            <p style={{ color: '#dc2626' }}>{error}</p>
            <button
              onClick={() => window.location.reload()}
              style={{
                backgroundColor: '#3b82f6',
                color: 'white',
                border: 'none',
                borderRadius: '8px',
                padding: '12px 24px',
                fontSize: '16px',
                cursor: 'pointer',
                marginTop: '10px'
              }}
            >
              🔄 Thử lại
            </button>
          </div>
        )}

        {/* Packages Grid */}
        <div style={{ 
          backgroundColor: 'white', 
          borderRadius: '16px', 
          boxShadow: '0 10px 25px rgba(0,0,0,0.1)',
          padding: '30px'
        }}>
          <h2 style={{ 
            fontSize: '2rem', 
            fontWeight: 'bold', 
            color: '#1f2937',
            marginBottom: '30px',
            textAlign: 'center'
          }}>
            Danh sách gói dịch vụ ({packages.length} gói)
          </h2>
          
          {packages.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '60px 20px' }}>
              <p style={{ fontSize: '1.2rem', color: '#6b7280', marginBottom: '20px' }}>
                {error ? 'Không thể tải danh sách gói dịch vụ' : 'Chưa có gói dịch vụ nào'}
              </p>
            </div>
          ) : (
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '24px' }}>
              {packages.map(pkg => (
                <div key={pkg.id} style={{ border: '1px solid #e5e7eb', borderRadius: 12, padding: 24, background: '#f9fafb', boxShadow: '0 2px 8px rgba(0,0,0,0.04)' }}>
                  <h3 style={{ fontSize: 22, fontWeight: 700, color: '#0a66c2', marginBottom: 8 }}>{pkg.name}</h3>
                  <div style={{ color: '#444', marginBottom: 8 }}>{pkg.description}</div>
                  <div style={{ fontWeight: 600, color: '#16a34a', fontSize: 18, marginBottom: 8 }}>{pkg.price.toLocaleString()} VND</div>
                  <button
                    style={{
                      background: '#22c55e',
                      color: '#fff',
                      border: 'none',
                      borderRadius: 6,
                      padding: '10px 20px',
                      fontWeight: 600,
                      cursor: 'pointer',
                      transition: 'all 0.18s cubic-bezier(.4,2,.6,1)',
                      boxShadow: '0 2px 8px rgba(34,197,94,0.08)'
                    }}
                    onMouseOver={e => {
                      e.currentTarget.style.background = '#16a34a';
                      e.currentTarget.style.transform = 'scale(1.06)';
                      e.currentTarget.style.boxShadow = '0 4px 18px #22c55e44';
                    }}
                    onMouseOut={e => {
                      e.currentTarget.style.background = '#22c55e';
                      e.currentTarget.style.transform = 'scale(1)';
                      e.currentTarget.style.boxShadow = '0 2px 8px rgba(34,197,94,0.08)';
                    }}
                    onClick={() => handleStripePayment(pkg.price, 'vnd', pkg.name, pkg.id, pkg.description)}
                  >
                    Thanh toán với Stripe
                  </button>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default PackagesPage;