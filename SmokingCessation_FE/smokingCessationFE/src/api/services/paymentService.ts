import apiClient from '../apiClient';
import endpoints from '../endpoints';

export const getMonthlyPaymentTotal = async (year: number, month: number) => {
  const res = await apiClient.get(endpoints.paymentMonthlyTotalByDate, {
    params: { year, month }
  });
  return res.data;
};

export const getDailyPaymentTotal = async (date: string) => {
  const res = await apiClient.get(endpoints.paymentDailyTotalByDate, {
    params: { date }
  });
  return res.data;
}; 