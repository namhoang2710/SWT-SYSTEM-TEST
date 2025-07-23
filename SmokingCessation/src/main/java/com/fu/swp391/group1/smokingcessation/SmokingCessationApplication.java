package com.fu.swp391.group1.smokingcessation;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;


@EnableAsync
@SpringBootApplication
public class SmokingCessationApplication {
    public static void main(String[] args) {
        SpringApplication.run(SmokingCessationApplication.class, args);
    }



}
    