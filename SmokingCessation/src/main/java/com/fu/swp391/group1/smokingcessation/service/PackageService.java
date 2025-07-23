package com.fu.swp391.group1.smokingcessation.service;

import com.fu.swp391.group1.smokingcessation.dto.PurchaseRequestDTO;
import com.fu.swp391.group1.smokingcessation.dto.PurchaseResponseDTO;
import com.fu.swp391.group1.smokingcessation.dto.SmokingLogDto;
import com.fu.swp391.group1.smokingcessation.entity.Account;
import com.fu.swp391.group1.smokingcessation.entity.InformationPackage;
import com.fu.swp391.group1.smokingcessation.entity.MemberProfile;
import com.fu.swp391.group1.smokingcessation.entity.PackageMember;
import com.fu.swp391.group1.smokingcessation.entity.SmokingLog;
import com.fu.swp391.group1.smokingcessation.repository.AccountRepository;
import com.fu.swp391.group1.smokingcessation.repository.InformationPackageRepository;
import com.fu.swp391.group1.smokingcessation.repository.MemberProfileRepository;
import com.fu.swp391.group1.smokingcessation.repository.PackageMemberRepository;
import com.fu.swp391.group1.smokingcessation.repository.SmokingLogRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

@Service
public class PackageService {

    private final InformationPackageService informationPackageService;
    @Autowired
    private InformationPackageRepository informationPackageRepository;

    @Autowired
    private PackageMemberRepository packageMemberRepository;

    @Autowired
    private SmokingLogRepository smokingLogRepository;

    @Autowired
    private MemberProfileRepository memberProfileRepository;

    @Autowired
    private AccountRepository accountRepository;

    @Autowired
    private UserPackageService userPackageService;

    PackageService(InformationPackageService informationPackageService) {
        this.informationPackageService = informationPackageService;
    }

    @Transactional
    public PurchaseResponseDTO purchasePackage(Long accountId, Integer packageId) {
        if (accountId == null || packageId == null) return null;

        Account account = accountRepository.findById(accountId).orElse(null);
        if (account == null || !"Active".equalsIgnoreCase(account.getStatus()) ||
            !"Member".equalsIgnoreCase(account.getRole())) {
            return null;
        }

        InformationPackage infoPackage = informationPackageRepository.findById(packageId).orElse(null);
        if (infoPackage == null) return null;

        PackageMember packageMember = new PackageMember();
        packageMember.setAccountId(accountId);
        packageMember.setInfoPackageId(packageId);
        packageMember.setName(infoPackage.getName() != null ? infoPackage.getName() : "");
        packageMember.setPrice(infoPackage.getPrice() != null ? infoPackage.getPrice() : 0.0);
        packageMember.setPurchaseDate(LocalDateTime.now());
        packageMemberRepository.save(packageMember);

        if (!userPackageService.addPackageBenefits(accountId, infoPackage)) {
            return null;
        }

        PurchaseResponseDTO response = new PurchaseResponseDTO();
        response.setPackageId(packageId);
        response.setPackageName(infoPackage.getName() != null ? infoPackage.getName() : "");
        response.setPrice(infoPackage.getPrice() != null ? infoPackage.getPrice() : 0.0);
        response.setAccountId(accountId);
        response.setMessage("Purchase successful");
        response.setPurchaseDate(LocalDateTime.now());
        return response;
    }

    // @Transactional
    // public boolean cancelPackage(Long accountId, Integer packageId) {
    //     if (accountId == null || packageId == null) return false;

    //     Account account = accountRepository.findById(accountId).orElse(null);
    //     if (account == null || !"Active".equalsIgnoreCase(account.getStatus()) ||
    //         !"Member".equalsIgnoreCase(account.getRole())) {
    //         return false;
    //     }

    //     List<PackageMember> members = packageMemberRepository.findByAccountIdAndInfoPackageId(accountId, packageId);
    //     if (members.isEmpty()) return false;

    //     InformationPackage infoPackage = informationPackageRepository.findById(packageId).orElse(null);
    //     if (infoPackage == null || !userPackageService.removePackageBenefits(accountId, infoPackage)) {
    //         return false;
    //     }

    //     packageMemberRepository.deleteAll(members);
    //     return true;
    // }

   

@Transactional
public SmokingLog logSmokingStatus(Long accountId, SmokingLogDto smokingLogDto) {
    if (accountId == null || smokingLogDto == null) return null;

    Account account = accountRepository.findById(accountId).orElse(null);
    if (account == null || !"Active".equalsIgnoreCase(account.getStatus()) ||
        !"Member".equalsIgnoreCase(account.getRole())) {
        return null;
    }

    MemberProfile memberProfile = memberProfileRepository.findByAccountId(accountId);
    if (memberProfile == null) {
        memberProfile = new MemberProfile();
        memberProfile.setAccount(account);
        memberProfile.setStartDate(LocalDate.now()); 
        memberProfile.setMotivation("Default motivation to quit smoking"); 
        memberProfile = memberProfileRepository.save(memberProfile); 
    }

    SmokingLog smokingLog = new SmokingLog();
    smokingLog.setMemberId(memberProfile.getMemberId());
    smokingLog.setDate(LocalDate.now());
    smokingLog.setCigarettes(smokingLogDto.getCigarettes());
    smokingLog.setTobaccoCompany(smokingLogDto.getTobaccoCompany());
    smokingLog.setNumberOfCigarettes(smokingLogDto.getNumberOfCigarettes());
    smokingLog.setCost(smokingLogDto.getCost());
    smokingLog.setHealthStatus(smokingLogDto.getHealthStatus());
    smokingLog.setCravingLevel(smokingLogDto.getCravingLevel());
    smokingLog.setNotes(smokingLogDto.getNotes());

    return smokingLogRepository.save(smokingLog);
}
    public Map<String, Object> getPurchasedPackagesByAccountId(Long accountId) {
        if (accountId == null) {
            return new HashMap<>();
        }

        List<PackageMember> purchasedPackages = packageMemberRepository.findByAccountId(accountId);

        Map<String, Object> response = new HashMap<>();
        response.put("accountId", accountId);
        response.put("purchasedPackages", purchasedPackages);
        return response;
    }

    public List<SmokingLog> getSmokingLogs(Long accountId, String role) {
        if (accountId == null || role == null) return List.of();

        Account account = accountRepository.findById(accountId).orElse(null);
        if (account == null || !"Active".equalsIgnoreCase(account.getStatus())) return List.of();

        if ("Coach".equalsIgnoreCase(role)) {
            return smokingLogRepository.findAll();
        } else if ("Member".equalsIgnoreCase(role)) {
            MemberProfile memberProfile = memberProfileRepository.findByAccountId(accountId);
            if (memberProfile == null) return List.of();
            return smokingLogRepository.findByMemberId(memberProfile.getMemberId());
        }

        return List.of();
    }

    @Transactional
public SmokingLog updateSmokingLog(Long accountId, Integer logId, SmokingLogDto smokingLogDto) {
    if (accountId == null || logId == null || smokingLogDto == null) return null;

    Account account = accountRepository.findById(accountId).orElse(null);
    if (account == null || !"Active".equalsIgnoreCase(account.getStatus()) ||
        !"Member".equalsIgnoreCase(account.getRole())) {
        return null;
    }

    SmokingLog existingLog = smokingLogRepository.findById(logId).orElse(null);
    if (existingLog == null) return null;

    MemberProfile memberProfile = memberProfileRepository.findByAccountId(accountId);
    if (memberProfile == null || !existingLog.getMemberId().equals(memberProfile.getMemberId())) {
        return null;
    }

    existingLog.setCigarettes(smokingLogDto.getCigarettes());
    existingLog.setTobaccoCompany(smokingLogDto.getTobaccoCompany());
    existingLog.setNumberOfCigarettes(smokingLogDto.getNumberOfCigarettes());
    existingLog.setCost(smokingLogDto.getCost());
    existingLog.setHealthStatus(smokingLogDto.getHealthStatus());
    existingLog.setCravingLevel(smokingLogDto.getCravingLevel());
    existingLog.setNotes(smokingLogDto.getNotes());
    return smokingLogRepository.save(existingLog);
}

 







}