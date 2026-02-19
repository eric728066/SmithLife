package com.smithlife.backend.repository;

import com.smithlife.backend.entity.Faq;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface FaqRepository extends JpaRepository<Faq, Long> {

    List<Faq> findByIsActiveTrueOrderByOrderIndexAsc();

    List<Faq> findByIsActiveTrueAndCategoryOrderByOrderIndexAsc(String category);
}
