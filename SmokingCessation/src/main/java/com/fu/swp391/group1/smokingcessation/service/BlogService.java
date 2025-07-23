package com.fu.swp391.group1.smokingcessation.service;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.fu.swp391.group1.smokingcessation.dto.BlogCreationRequest;
import com.fu.swp391.group1.smokingcessation.dto.BlogResponseDTO;
import com.fu.swp391.group1.smokingcessation.entity.Account;
import com.fu.swp391.group1.smokingcessation.entity.Blog;
import com.fu.swp391.group1.smokingcessation.entity.BlogLike;
import com.fu.swp391.group1.smokingcessation.repository.AccountRepository;
import com.fu.swp391.group1.smokingcessation.repository.BlogLikeRepository;
import com.fu.swp391.group1.smokingcessation.repository.BlogRepository;
import com.fu.swp391.group1.smokingcessation.repository.CommentRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.DateTimeException;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;


@Service
public class BlogService {

    @Autowired
    private BlogRepository blogRepository;

    @Autowired
    private AccountRepository accountRepository;

    @Autowired
    private CommentRepository commentRepository;

    @Autowired
    private CloudinaryImageService cloudinaryImageService;

    @Autowired
    private Cloudinary cloudinary;

    @Autowired
    private BlogLikeRepository blogLikeRepository;

    public List<BlogResponseDTO> getAllBlogs(Long userId) {
        List<Blog> blogs = blogRepository.findAll();

        final Account user = (userId != null)
                ? accountRepository.findById(userId).orElse(null)
                : null;

        return blogs.stream().map(blog -> {
            boolean liked = false;

            if (user != null) {
                liked = blogLikeRepository.findByAccountAndBlog(user, blog).isPresent();
            }

            BlogResponseDTO dto = new BlogResponseDTO();
            dto.setBlogID(blog.getBlogID());
            dto.setTitle(blog.getTitle());
            dto.setContent(blog.getContent());
            dto.setImage(blog.getImage());
            dto.setLikes(blog.getLikes());
            dto.setCreatedDate(blog.getCreatedDate());
            dto.setCreatedTime(blog.getCreatedTime());
            dto.setLiked(liked);
            dto.setAccount(blog.getAccount());

            return dto;
        }).collect(Collectors.toList());
    }



    public Blog getBlogById(int id) {
        return blogRepository.findById(id).orElse(null);
    }

    public List<Blog> findByAccountId(Long accountId) {
        return blogRepository.findByAccountId(accountId);
    }

    public Blog updateBlog(int id, BlogCreationRequest blogCreationRequest) {
        Blog blog = blogRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Blog not found"));

        blog.setTitle(blogCreationRequest.getTitle());
        blog.setContent(blogCreationRequest.getContent());

        MultipartFile imageFile = blogCreationRequest.getImage();


        if (imageFile != null && !imageFile.isEmpty()) {

            if (blog.getImage() != null && !blog.getImage().isBlank()) {
                try {
                    String publicId = extractPublicIdFromUrl(blog.getImage());
                    cloudinary.uploader().destroy(publicId, ObjectUtils.emptyMap());
                } catch (Exception e) {
                    throw new RuntimeException("Lỗi khi xóa ảnh cũ từ Cloudinary: " + e.getMessage(), e);
                }
            }


            try {
                Map uploadResult = cloudinary.uploader().upload(imageFile.getBytes(), ObjectUtils.emptyMap());
                String imageUrl = (String) uploadResult.get("secure_url");
                blog.setImage(imageUrl);
            } catch (IOException e) {
                throw new RuntimeException("Lỗi khi upload ảnh mới lên Cloudinary: " + e.getMessage(), e);
            }
        }

        return blogRepository.save(blog);
    }



    @Transactional
    public void deleteBlog(int id) {
        Blog blog = blogRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("Blog not found"));

        if (blog.getImage() != null) {
            try {
                String imageUrl = blog.getImage();

                String publicId = extractPublicIdFromUrl(imageUrl);

                cloudinary.uploader().destroy(publicId, ObjectUtils.emptyMap());
            } catch (IOException e) {
                throw new RuntimeException("Lỗi khi xóa ảnh: " + e.getMessage());
            }
        }

        commentRepository.deleteByBlog(blog);
        blogRepository.delete(blog);
    }


    public Blog createBlog(BlogCreationRequest blogCreationRequest, Long accountId) {
        var account = accountRepository.findById(accountId)
                .orElseThrow(() -> new IllegalArgumentException("Account not found"));

        Blog blog = new Blog();
        blog.setTitle(blogCreationRequest.getTitle());
        blog.setContent(blogCreationRequest.getContent());
        blog.setAccount(account);

        MultipartFile imageFile = blogCreationRequest.getImage();
        if (imageFile != null && !imageFile.isEmpty()) {
            try {
                String imageUrl = cloudinaryImageService.uploadImage(imageFile);
                blog.setImage(imageUrl);
            } catch (IOException e) {
                throw new RuntimeException("Lỗi khi upload ảnh: " + e.getMessage(), e);
            }
        }

        return blogRepository.save(blog);
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



    public Map<String, Object> blogLike(int blogId, Long accountId) {
        Blog blog = blogRepository.findById(blogId)
                .orElseThrow(() -> new IllegalArgumentException("Blog not found"));
        Account account = accountRepository.findById(accountId)
                .orElseThrow(() -> new IllegalArgumentException("Account not found"));

        Optional<BlogLike> blogLike = blogLikeRepository.findByAccountAndBlog(account, blog);
        String message;

        if (blogLike.isPresent()) {
            blogLikeRepository.delete(blogLike.get());
            blog.setLikes(blog.getLikes() - 1);
            message = "Unliked";
        } else {
            blogLikeRepository.save(new BlogLike(account, blog));
            blog.setLikes(blog.getLikes() + 1);
            message = "Liked";
        }

        blogRepository.save(blog);

        Map<String, Object> result = new HashMap<>();
        result.put("message", message);
        result.put("likes", blog.getLikes());

        return result;
    }

    public long countBlogsToday() {
        return blogRepository.countByCreatedDate(LocalDate.now());
    }

    public long countBlogsByDate(int day, int month, int year) {
        try {
            LocalDate date = LocalDate.of(year, month, day);
            return blogRepository.countByCreatedDate(date);
        } catch (DateTimeException e) {
            throw new IllegalArgumentException("Ngày không hợp lệ: " + e.getMessage());
        }
    }







}