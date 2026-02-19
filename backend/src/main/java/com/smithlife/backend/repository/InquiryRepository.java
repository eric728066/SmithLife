package com.smithlife.backend.repository;

import com.smithlife.backend.entity.Inquiry;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface InquiryRepository extends JpaRepository<Inquiry, Long> {

    List<Inquiry> findByUserUserIdOrderByCreatedAtDesc(Long userId);

    @Query("SELECT i FROM Inquiry i LEFT JOIN FETCH i.replies WHERE i.inquiryId = :inquiryId")
    Optional<Inquiry> findByIdWithReplies(@Param("inquiryId") Long inquiryId);
}
