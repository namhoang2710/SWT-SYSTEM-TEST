package com.fu.swp391.group1.smokingcessation.service;


import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.fu.swp391.group1.smokingcessation.dto.MedalCreationRequest;
import com.fu.swp391.group1.smokingcessation.entity.Medal;
import com.fu.swp391.group1.smokingcessation.repository.AccountRepository;
import com.fu.swp391.group1.smokingcessation.repository.MedalRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@Service
public class MedalService {

    @Autowired
    private MedalRepository medalRepository;

    @Autowired
    private CloudinaryImageService cloudinaryImageService;

    @Autowired
    private Cloudinary cloudinary;

    public List<Medal> getAllMedal() {
        return medalRepository.findAll();
    }

    public Medal createMedal(MedalCreationRequest medalCreationRequest) {
        Medal medal = new Medal();
        medal.setName(medalCreationRequest.getName());
        medal.setDescription(medalCreationRequest.getDescription());
        medal.setType(medalCreationRequest.getType());

        MultipartFile imageFile = medalCreationRequest.getImage();
        if (imageFile != null && !imageFile.isEmpty()) {
            try {
                String imageUrl = cloudinaryImageService.uploadImage(imageFile);
                medal.setImage(imageUrl);
            } catch (IOException e) {
                throw new RuntimeException("Lỗi khi upload ảnh: " + e.getMessage(), e);
            }
        }

        return medalRepository.save(medal);
    }


    @Transactional
    public void deleteMedal(int id) {
        Medal medal = medalRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("Medal not found"));

        if (medal.getImage() != null) {
            try {
                String imageUrl = medal.getImage();
                String publicId = extractPublicIdFromUrl(imageUrl);
                cloudinary.uploader().destroy(publicId, ObjectUtils.emptyMap());
            }  catch (IOException e) {
                throw new RuntimeException("Lỗi khi xoá ảnh: " + e.getMessage());
            }

        }

        medalRepository.delete(medal);
    }

    private String extractPublicIdFromUrl(String imageUrl) {
        try {
            String[] parts = imageUrl.split("/");
            String filename = parts[parts.length - 1];
            return filename.substring(0, filename.lastIndexOf("."));
        } catch (Exception e) {
            throw new RuntimeException("Không thể tách public_id từ URL ảnh", e);
        }
    }

    @Transactional
    public Medal updateMedal(int id, MedalCreationRequest request) {
        Medal medal = medalRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("Medal not found"));

        medal.setName(request.getName());
        medal.setDescription(request.getDescription());
        medal.setType(request.getType());

        MultipartFile imageFile = request.getImage();
        if (imageFile != null && !imageFile.isEmpty()) {
            try {
                if (medal.getImage() != null) {
                    String publicId = extractPublicIdFromUrl(medal.getImage());
                    cloudinary.uploader().destroy(publicId, ObjectUtils.emptyMap());
                }

                String imageUrl = cloudinaryImageService.uploadImage(imageFile);
                medal.setImage(imageUrl);
            } catch (IOException e) {
                throw new RuntimeException("Lỗi khi cập nhật ảnh: " + e.getMessage(), e);
            }
        }

        return medalRepository.save(medal);
    }


}
