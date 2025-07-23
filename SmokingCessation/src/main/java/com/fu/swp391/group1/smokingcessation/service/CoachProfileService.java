package com.fu.swp391.group1.smokingcessation.service;

import com.fu.swp391.group1.smokingcessation.dto.CoachProfileCreationRequest;
import com.fu.swp391.group1.smokingcessation.entity.Account;
import com.fu.swp391.group1.smokingcessation.entity.CoachProfile;
import com.fu.swp391.group1.smokingcessation.repository.AccountRepository;
import com.fu.swp391.group1.smokingcessation.repository.CoachProfileRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Optional;

@Service
public class CoachProfileService {

    @Autowired
    private CoachProfileRepository coachProfileRepository;

    @Autowired
    private AccountRepository accountRepository;

    @Autowired
    private CloudinaryImageService cloudinaryImageService;


    public List<CoachProfile> getAllCoachProfiles() {
        return coachProfileRepository.findAll();
    }

    public Optional<CoachProfile> getByAccountId(Long accountId) {
        return coachProfileRepository.findByAccount_Id(accountId);
    }



    public CoachProfile createCoachProfile(CoachProfileCreationRequest req, Long accountId) {
        var account = accountRepository.findById(accountId).orElseThrow(() -> new IllegalArgumentException("Account not found"));

        CoachProfile profile = new CoachProfile();
        profile.setSpecialty(req.getSpecialty());
        profile.setExperience(req.getExperience());
        profile.setAccount(account);

        MultipartFile imageFile = req.getImage();
        if (imageFile != null && !imageFile.isEmpty()) {
            try {
                String imageUrl = cloudinaryImageService.uploadImage(imageFile);
                profile.setImage(imageUrl);
            } catch (Exception e) {
                throw new RuntimeException("Failed to upload image: " + e.getMessage());
            }
        }

        return coachProfileRepository.save(profile);
    }



    public CoachProfile updateCoachProfile(Long accountId, CoachProfileCreationRequest req) {
        CoachProfile profile = coachProfileRepository.findByAccount_Id(accountId).orElseThrow(() -> new IllegalArgumentException("Profile not found"));

        profile.setSpecialty(req.getSpecialty());
        profile.setExperience(req.getExperience());

        MultipartFile imageFile = req.getImage();
        if (imageFile != null && !imageFile.isEmpty()) {
            try {
                String imageUrl = cloudinaryImageService.uploadImage(imageFile);
                profile.setImage(imageUrl);
            } catch (Exception e) {
                throw new RuntimeException("Failed to upload image: " + e.getMessage());
            }
        }

        return coachProfileRepository.save(profile);
    }


    @Transactional
    public void deleteByAccountId(Long accountId) {
        CoachProfile profile = coachProfileRepository.findByAccount_Id(accountId)
                .orElseThrow(() -> new IllegalArgumentException("Profile not found"));

        profile.setSpecialty("");
        profile.setExperience("");
        coachProfileRepository.save(profile);
    }


    public void createEmptyProfileForCoach(Account account) {
    if (coachProfileRepository.findByAccount(account).isEmpty()) {
        CoachProfile profile = new CoachProfile();
        profile.setAccount(account);
        profile.setSpecialty("");
        profile.setExperience("");
        profile.setImage(null); // hoặc đường dẫn ảnh mặc định
        coachProfileRepository.save(profile);
    }
}


}
