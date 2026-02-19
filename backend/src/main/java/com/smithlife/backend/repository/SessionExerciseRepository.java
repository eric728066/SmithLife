package com.smithlife.backend.repository;

import com.smithlife.backend.entity.SessionExercise;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface SessionExerciseRepository extends JpaRepository<SessionExercise, Long> {

    List<SessionExercise> findBySessionSessionIdOrderByOrderIndexAsc(Long sessionId);

    int countBySessionSessionId(Long sessionId);

    @Modifying
    @Query("UPDATE SessionExercise se SET se.status = :status WHERE se.sessionExerciseId = :id")
    void updateStatus(@Param("id") Long id, @Param("status") SessionExercise.Status status);
}
