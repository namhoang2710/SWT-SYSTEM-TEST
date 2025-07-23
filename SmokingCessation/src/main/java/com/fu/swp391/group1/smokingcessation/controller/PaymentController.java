package com.fu.swp391.group1.smokingcessation.controller;

import com.fu.swp391.group1.smokingcessation.service.PaymentService;
import com.stripe.exception.StripeException;
import com.fu.swp391.group1.smokingcessation.dto.UserPrincipal;

import org.checkerframework.checker.units.qual.s;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/payment")
public class PaymentController {

    @Autowired
    private PaymentService paymentService;

    @Autowired
    private com.fu.swp391.group1.smokingcessation.service.StripeSyncService stripeSyncService;

    @Value("${stripe.publishable.key}")
    private String publishableKey;

    @PostMapping("/create")
    public ResponseEntity<Map<String, String>> createPaymentIntent(
    @RequestParam Long amount,
    @RequestParam String currency,
    @AuthenticationPrincipal UserPrincipal userPrincipal
    ) throws StripeException {
    Long accountId = userPrincipal.getUserId();

    com.stripe.model.PaymentIntent paymentIntent = paymentService.createPaymentIntent(amount, currency);
    Map<String, String> response = new HashMap<>();
    response.put("clientSecret", paymentIntent.getClientSecret());
    return ResponseEntity.ok(response);
}


    @PostMapping("/sheet")
public ResponseEntity<Map<String, String>> createPaymentSheet(
    @RequestParam Long amount,
    @RequestParam String currency,
    @AuthenticationPrincipal UserPrincipal userPrincipal
) throws StripeException {
    Long accountId = userPrincipal.getUserId(); 

    Map<String, String> sheetData = paymentService.createPaymentSheetData(amount, currency);
    sheetData.put("publishableKey", publishableKey);
    return ResponseEntity.ok(sheetData);
}

    @PostMapping("/sync")
    public ResponseEntity<String> syncTransactions() throws StripeException {
    stripeSyncService.syncStripeTransactions();
    return ResponseEntity.ok("Sync completed");
    
}

    @GetMapping("/daily-total-by-date")
    public ResponseEntity<Double> getDailyTotalByDate(@RequestParam String date) {
        Double total = stripeSyncService.getDailyTotalAmount(date);
        return ResponseEntity.ok(total);
    }


    @GetMapping("/monthly-total-by-date")
    public ResponseEntity<Double> getMonthlyTotalByDate(
            @RequestParam int year,
            @RequestParam int month) {
        Double total = stripeSyncService.getMonthlyTotalAmount(year, month);
        return ResponseEntity.ok(total);
    }
    
}