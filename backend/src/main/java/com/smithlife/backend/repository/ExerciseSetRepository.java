package com.smithlife.backend.repository;

import com.smithlife.backend.entity.ExerciseSet;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.util.List;

public interface ExerciseSetRepository extends JpaRepository<ExerciseSet, Long> {

    List<ExerciseSet> findBySessionExerciseSessionExerciseIdOrderBySetNumberAsc(Long sessionExerciseId);

    @Query("SELECT COALESCE(SUM(es.weightKg * es.reps), 0) FROM ExerciseSet es " +
           "WHERE es.sessionExercise.session.sessionId = :sessionId AND es.isCompleted = true")
    BigDecimal sumVolumeBySessionId(@Param("sessionId") Long sessionId);

    long countBySessionExerciseSessionExerciseIdAndIsCompletedTrue(Long sessionExerciseId);
}
