package com.fu.swp391.group1.smokingcessation.service;

import com.fu.swp391.group1.smokingcessation.dto.InformationPackageDTO;
import com.fu.swp391.group1.smokingcessation.entity.Account;
import com.fu.swp391.group1.smokingcessation.entity.InformationPackage;
import com.fu.swp391.group1.smokingcessation.repository.InformationPackageRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class InformationPackageService {

    @Autowired
    private InformationPackageRepository informationPackageRepository;

    private InformationPackageDTO mapToDTO(InformationPackage pkg) {
        InformationPackageDTO dto = new InformationPackageDTO();
        dto.setName(pkg.getName());
        dto.setPrice(pkg.getPrice());
        dto.setDescription(pkg.getDescription());
        dto.setNumberOfConsultations(pkg.getNumberOfConsultations());
        dto.setNumberOfHealthCheckups(pkg.getNumberOfHealthCheckups());
        return dto;
    }

    public List<InformationPackage> getAllPackages() {
        return informationPackageRepository.findAll();
    }

    @Transactional
    public InformationPackageDTO createPackage(Account account, InformationPackageDTO dto) {
        if (account == null || !"Admin".equalsIgnoreCase(account.getRole())) {
            throw new SecurityException("Admins only");
        }
        if (dto.getName() == null || dto.getName().trim().isEmpty()) {
            throw new IllegalArgumentException("Name required");
        }
        InformationPackage pkg = new InformationPackage();
        pkg.setName(dto.getName());
        pkg.setPrice(dto.getPrice());
        pkg.setDescription(dto.getDescription());
        pkg.setNumberOfConsultations(dto.getNumberOfConsultations());
        pkg.setNumberOfHealthCheckups(dto.getNumberOfHealthCheckups());
        return mapToDTO(informationPackageRepository.save(pkg));
    }

    @Transactional
    public InformationPackageDTO updatePackage(Account account, Integer id, InformationPackageDTO dto) {
        if (account == null || !"Admin".equalsIgnoreCase(account.getRole())) {
            throw new SecurityException("Admins only");
        }
        InformationPackage pkg = informationPackageRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Package not found"));
        if (dto.getName() != null && !dto.getName().trim().isEmpty()) pkg.setName(dto.getName());
        if (dto.getPrice() != null) pkg.setPrice(dto.getPrice());
        if (dto.getDescription() != null) pkg.setDescription(dto.getDescription());
        if (dto.getNumberOfConsultations() != null) pkg.setNumberOfConsultations(dto.getNumberOfConsultations());
        if (dto.getNumberOfHealthCheckups() != null) pkg.setNumberOfHealthCheckups(dto.getNumberOfHealthCheckups());
        return mapToDTO(informationPackageRepository.save(pkg));
    }

    @Transactional
    public void deletePackage(Account account, Integer id) {
        if (account == null || !"Admin".equalsIgnoreCase(account.getRole())) {
            throw new SecurityException("Admins only");
        }
        InformationPackage pkg = informationPackageRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Package not found"));
        informationPackageRepository.delete(pkg);
    }
}