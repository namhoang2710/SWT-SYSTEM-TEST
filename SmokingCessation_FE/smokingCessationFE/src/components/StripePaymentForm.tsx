import React from "react";
import { Elements } from "@stripe/react-stripe-js";
import { loadStripe } from "@stripe/stripe-js";
import CheckoutForm from "./CheckoutForm";

const stripePromise = loadStripe("pk_test_51Ra4eiQqsXsd7AGVx9PRjNtRhkn5e7XYa4myqgaw6iASe83YPOeLDEOLMX0vvY2YXqbcfABK1IN3iXUT6eugtNPS00laP8M4fQ");

const StripePaymentForm = ({ clientSecret, onSuccess }: { clientSecret: string, onSuccess: () => void }) => {
  const options = { clientSecret };

  return (
    <Elements stripe={stripePromise} options={options}>
      <CheckoutForm onSuccess={onSuccess} />
    </Elements>
  );
};

export default StripePaymentForm; 