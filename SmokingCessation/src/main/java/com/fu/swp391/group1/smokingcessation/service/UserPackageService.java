package com.fu.swp391.group1.smokingcessation.service;

import com.fu.swp391.group1.smokingcessation.entity.Account;
import com.fu.swp391.group1.smokingcessation.entity.InformationPackage;
import com.fu.swp391.group1.smokingcessation.repository.AccountRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserPackageService {
    @Autowired
    private AccountRepository accountRepository;

    @Transactional
    public boolean addPackageBenefits(Long accountId, InformationPackage pack) {
        if (accountId == null || pack == null) return false;
        Account account = accountRepository.findById(accountId).orElse(null);
        if (account == null || !"Active".equalsIgnoreCase(account.getStatus()) ||
            !"Member".equals(account.getRole())) {
            return false;
        }

        account.setConsultations(account.getConsultations() + pack.getNumberOfConsultations());
        account.setHealthCheckups(account.getHealthCheckups() + pack.getNumberOfHealthCheckups());
        accountRepository.save(account);
        return true;
    }

    @Transactional
    public boolean removePackageBenefits(Long accountId, InformationPackage pack) {
        if (accountId == null || pack == null) return false;
        Account account = accountRepository.findById(accountId).orElse(null);
        if (account == null || !"Active".equalsIgnoreCase(account.getStatus()) ||
            !"Member".equals(account.getRole())) {
            return false;
        }

        account.setConsultations(Math.max(0, account.getConsultations() - pack.getNumberOfConsultations()));
        account.setHealthCheckups(Math.max(0, account.getHealthCheckups() - pack.getNumberOfHealthCheckups()));
        accountRepository.save(account);
        return true;
    }
}