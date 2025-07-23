package com.fu.swp391.group1.smokingcessation.repository;

import com.fu.swp391.group1.smokingcessation.entity.Medal;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface MedalRepository extends JpaRepository<Medal, Integer> {
    List<Medal> findAll();
}
