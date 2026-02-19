package com.smithlife.backend.repository;

import com.smithlife.backend.entity.WorkoutSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface WorkoutSessionRepository extends JpaRepository<WorkoutSession, Long> {

    Optional<WorkoutSession> findByUserUserIdAndStatus(Long userId, WorkoutSession.Status status);

    List<WorkoutSession> findByUserUserIdOrderByStartTimeDesc(Long userId);

    @Query("SELECT ws FROM WorkoutSession ws " +
           "LEFT JOIN FETCH ws.sessionExercises se " +
           "LEFT JOIN FETCH se.exerciseSets " +
           "LEFT JOIN FETCH se.exercise " +
           "WHERE ws.sessionId = :sessionId")
    Optional<WorkoutSession> findByIdWithDetails(@Param("sessionId") Long sessionId);

    @Modifying
    @Query("UPDATE WorkoutSession ws SET ws.status = :status, ws.endTime = :endTime, " +
           "ws.totalDurationSec = :duration, ws.totalVolumeKg = :volume, ws.totalCalories = :calories " +
           "WHERE ws.sessionId = :sessionId")
    void updateSessionEnd(@Param("sessionId") Long sessionId,
                          @Param("status") WorkoutSession.Status status,
                          @Param("endTime") LocalDateTime endTime,
                          @Param("duration") Integer duration,
                          @Param("volume") BigDecimal volume,
                          @Param("calories") BigDecimal calories);
}
