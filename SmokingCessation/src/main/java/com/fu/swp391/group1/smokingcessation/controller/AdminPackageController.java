package com.fu.swp391.group1.smokingcessation.controller;

import com.fu.swp391.group1.smokingcessation.config.JwtUtil;
import com.fu.swp391.group1.smokingcessation.dto.InformationPackageDTO;
import com.fu.swp391.group1.smokingcessation.entity.Account;
import com.fu.swp391.group1.smokingcessation.entity.InformationPackage;
import com.fu.swp391.group1.smokingcessation.repository.AccountRepository;
import com.fu.swp391.group1.smokingcessation.service.InformationPackageService;
import com.fu.swp391.group1.smokingcessation.dto.UserPrincipal;



import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/packages")
public class AdminPackageController {

    @Autowired
    private InformationPackageService informationPackageService;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private AccountRepository accountRepository;

    private Account getAccountFromToken(String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) return null;
        Long accountId = jwtUtil.extractId(authHeader.substring(7));
        return accountRepository.findById(accountId).orElse(null);
    }

   @GetMapping("/all")
    public ResponseEntity<List<InformationPackage>> getAllPackages() {
        List<InformationPackage> packages = informationPackageService.getAllPackages();
        return ResponseEntity.ok(packages);
    }

    @PostMapping("/create")
        public ResponseEntity<InformationPackageDTO> createPackage(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            
            @RequestBody InformationPackageDTO dto
        ) {
            Long accountId = userPrincipal.getUserId();

            Account account = accountRepository.findById(accountId).orElse(null);
            if (account == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
            }

            try {
                InformationPackageDTO result = informationPackageService.createPackage(account, dto);
                return ResponseEntity.ok(result);
            } catch (Exception e) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
            }
        }


    @PutMapping(value = "/{id}" , consumes = MediaType.MULTIPART_FORM_DATA_VALUE )
    public ResponseEntity<InformationPackageDTO> updatePackage(
        @PathVariable Integer id,
        @ModelAttribute InformationPackageDTO dto,
        @AuthenticationPrincipal UserPrincipal userPrincipal
    ) {
        Long accountId = userPrincipal.getUserId();
        Account account = accountRepository.findById(accountId).orElse(null);
        if (account == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        try {
            return ResponseEntity.ok(informationPackageService.updatePackage(account, id, dto));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
    }


@DeleteMapping("/{id}")
public ResponseEntity<Void> deletePackage(
    @PathVariable Integer id,
    @AuthenticationPrincipal UserPrincipal userPrincipal
) {
    Long accountId = userPrincipal.getUserId();
    Account account = accountRepository.findById(accountId).orElse(null);
    if (account == null) {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
    }

    try {
        informationPackageService.deletePackage(account, id);
        return ResponseEntity.ok().build();
    } catch (Exception e) {
        return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
    }
}
}
