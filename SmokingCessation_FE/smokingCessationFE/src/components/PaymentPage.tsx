import React from "react";
import { useLocation, useNavigate } from "react-router-dom";
import StripePaymentForm from "./StripePaymentForm";
import apiClient from "../api/apiClient";
import { toast } from 'react-toastify';

const PaymentPage: React.FC = () => {
  const location = useLocation();
  const navigate = useNavigate();
  const clientSecret = location.state?.clientSecret;
  const packageName = location.state?.packageName;
  const packageId = location.state?.packageId;
  const packagePrice = location.state?.packagePrice;
  const packageDescription = location.state?.packageDescription;

  React.useEffect(() => {
    if (!clientSecret) {
      navigate("/packages");
    }
  }, [clientSecret, navigate]);

  // Hàm gọi API mua gói
  const handleBuyPackage = async () => {
    try {
      const token = localStorage.getItem("token");
      await apiClient.post('/packages/buy', {}, {
        headers: {
          'Package-Id': packageId.toString(),
          'Authorization': `Bearer ${token}`
        }
      });
      toast.success("🎉 Thanh toán & mua gói thành công!");
      setTimeout(() => navigate("/packages"), 2500);
    } catch (error: any) {
      toast.error("Thanh toán thành công nhưng mua gói thất bại: " + (error.response?.data?.message || error.message));
      setTimeout(() => navigate("/packages"), 2500);
    }
  };

  if (!clientSecret) return null;

  return (
    <div style={{
      minHeight: "100vh",
      background: "#f8fafc",
      display: "flex",
      alignItems: "center",
      justifyContent: "center"
    }}>
      <div style={{
        background: "#fff",
        borderRadius: 18,
        boxShadow: "0 8px 32px rgba(0,0,0,0.12)",
        display: "flex",
        minWidth: 700,
        maxWidth: 900,
        width: "100%",
        overflow: "hidden"
      }}>
        {/* Left: Info */}
        <div style={{
          flex: 1,
          padding: "40px 32px",
          borderRight: "1px solid #f1f5f9",
          display: "flex",
          flexDirection: "column",
          justifyContent: "center"
        }}>
          <h2 style={{ fontSize: 28, fontWeight: 800, color: "#2563eb", marginBottom: 18 }}>
            Thanh toán gói dịch vụ
          </h2>
          <div style={{ fontSize: 20, fontWeight: 700, marginBottom: 8 }}>{packageName}</div>
          {packagePrice && (
            <div style={{ fontSize: 22, color: "#16a34a", fontWeight: 700, marginBottom: 8 }}>
              {Number(packagePrice).toLocaleString()} VND
            </div>
          )}
          {packageDescription && (
            <div style={{ color: "#334155", fontSize: 16, marginBottom: 12 }}>
              {packageDescription}
            </div>
          )}
          <div style={{ color: "#64748b", fontSize: 16, marginBottom: 12 }}>
            Hãy nhập thông tin thanh toán để hoàn tất mua gói dịch vụ.
          </div>
        </div>
        {/* Right: Stripe Form */}
        <div style={{
          flex: 1.2,
          padding: "40px 32px",
          display: "flex",
          flexDirection: "column",
          justifyContent: "center"
        }}>
          <StripePaymentForm
            clientSecret={clientSecret}
            onSuccess={handleBuyPackage}
          />
        </div>
      </div>
    </div>
  );
};

export default PaymentPage; 