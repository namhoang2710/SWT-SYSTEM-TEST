package com.fu.swp391.group1.smokingcessation.service;

import com.stripe.exception.StripeException;
import com.stripe.model.Charge;
import com.stripe.net.StripeResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;
import jakarta.transaction.Transactional;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.Date;
import java.util.List;
import java.util.Map;

@Service
public class StripeSyncService {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @PostConstruct
    public void syncStripeTransactions() {
        try {
            List<Charge> charges = fetchStripeCharges();
            for (Charge charge : charges) {
                saveChargeToDatabase(charge);
            }
            System.out.println("Stripe transactions synced successfully!");
        } catch (StripeException e) {
            System.err.println("Error syncing Stripe transactions: " + e.getMessage());
        }
    }

    private List<Charge> fetchStripeCharges() throws StripeException {
        Map<String, Object> params = Map.of("limit", 12);
        return Charge.list(params).getData();
    }

    private void saveChargeToDatabase(Charge charge) {
    try {
        String sql = "INSERT INTO Payment (PaymentID, Amount, Date, StripePaymentIntentID, Currency, Status, customer_id) " +

                     "VALUES (NULL, ?, FROM_UNIXTIME(?), ?, ?, ?, ?) " +

                     "ON DUPLICATE KEY UPDATE Amount = VALUES(Amount), Date = VALUES(Date), Status = VALUES(Status)";

        jdbcTemplate.update(sql,
                charge.getAmount() , // Amount
                charge.getCreated(), // Date
                charge.getPaymentIntent(), // StripePaymentIntentID
                charge.getCurrency(),
                charge.getStatus(),
                charge.getCustomer() != null ? charge.getCustomer() : "" // customer_id
        );
    } catch (Exception e) {
        System.err.println("Error saving charge " + charge.getId() + ": " + e.getMessage());
    }
}
    @Transactional
    public Double getDailyTotalAmount(String dateString) {
        try {
            LocalDate date = LocalDate.parse(dateString);

            Date startOfDay = java.sql.Date.valueOf(date); 
            Date endOfDay = java.sql.Date.valueOf(date.plusDays(1)); 

            String sql = "SELECT COALESCE(SUM(Amount), 0) FROM Payment WHERE Date >= ? AND Date < ?";
            return jdbcTemplate.queryForObject(sql, Double.class, startOfDay, endOfDay);
        } catch (Exception e) {
            System.err.println("Error parsing date: " + dateString);
            return 0.0;
        }
    }

@Transactional
public Double getMonthlyTotalAmount(int year, int month) {
    try {
        LocalDate start = LocalDate.of(year, month, 1);
        LocalDate end = start.plusMonths(1); 
        Date startOfMonth = java.sql.Date.valueOf(start);
        Date endOfMonth = java.sql.Date.valueOf(end);

        String sql = "SELECT COALESCE(SUM(Amount), 0) FROM Payment WHERE Date >= ? AND Date < ?";
        return jdbcTemplate.queryForObject(sql, Double.class, startOfMonth, endOfMonth);
    } catch (Exception e) {
        System.err.println("Invalid year/month input: " + e.getMessage());
        return 0.0;
    }
}

}