import React from "react";
import { PaymentElement, useStripe, useElements } from "@stripe/react-stripe-js";

const CheckoutForm = ({ onSuccess }: { onSuccess: () => void }) => {
  const stripe = useStripe();
  const elements = useElements();
  const [loading, setLoading] = React.useState(false);
  const [error, setError] = React.useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!stripe || !elements) return;

    setLoading(true);
    const { error } = await stripe.confirmPayment({
      elements,
      confirmParams: {},
      redirect: "if_required",
    });

    setLoading(false);

    if (error) {
      setError(error.message || "Thanh toán thất bại");
    } else {
      setError(null);
      onSuccess();
    }
  };

  return (
    <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
      <PaymentElement />
      <button type="submit" disabled={!stripe || loading} 
        style={{ 
          marginTop: 16, 
          background: '#0a66c2', 
          color: '#fff', 
          border: 'none', 
          borderRadius: 6, 
          padding: '10px 20px', 
          fontWeight: 600, 
          cursor: 'pointer', 
          transition: 'all 0.18s cubic-bezier(.4,2,.6,1)', 
          boxShadow: '0 2px 8px #0a66c244' 
        }}
        onMouseOver={e => {
          if (!loading && stripe) {
            e.currentTarget.style.background = '#2563eb';
            e.currentTarget.style.transform = 'scale(1.06)';
            e.currentTarget.style.boxShadow = '0 4px 18px #2563eb44';
          }
        }}
        onMouseOut={e => {
          if (!loading && stripe) {
            e.currentTarget.style.background = '#0a66c2';
            e.currentTarget.style.transform = 'scale(1)';
            e.currentTarget.style.boxShadow = '0 2px 8px #0a66c244';
          }
        }}
      >
        {loading ? "Đang xử lý..." : "Thanh toán"}
      </button>
      {error && <div style={{ color: "red", marginTop: 8 }}>{error}</div>}
    </form>
  );
};

export default CheckoutForm; 