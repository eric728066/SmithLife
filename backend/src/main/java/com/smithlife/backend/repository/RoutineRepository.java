package com.smithlife.backend.repository;

import com.smithlife.backend.entity.Routine;
import com.smithlife.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RoutineRepository extends JpaRepository<Routine, Long> {

    // 추천 루틴 (관리자 시딩)
    List<Routine> findAllByIsRecommendedTrueOrderByRoutineIdAsc();

    // 공유 루틴 (유저가 공개한 루틴, 추천 제외)
    List<Routine> findAllByIsPublicTrueAndIsRecommendedFalseOrderByCreatedAtDesc();

    // 내 공유 루틴
    List<Routine> findAllByCreatorAndIsPublicTrueOrderByCreatedAtDesc(User creator);

    boolean existsByIsRecommendedTrue();

    boolean existsByNameAndCreator(String name, User creator);
}
