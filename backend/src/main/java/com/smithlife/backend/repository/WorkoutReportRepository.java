package com.smithlife.backend.repository;

import com.smithlife.backend.entity.WorkoutReport;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface WorkoutReportRepository extends JpaRepository<WorkoutReport, Long> {

    List<WorkoutReport> findByUserUserIdOrderByReportDateDesc(Long userId);

    Optional<WorkoutReport> findBySessionSessionId(Long sessionId);

    List<WorkoutReport> findByUserUserIdAndReportDateBetweenOrderByReportDateAsc(
            Long userId, LocalDate start, LocalDate end);

    @Query("SELECT COALESCE(SUM(r.totalVolumeKg), 0) FROM WorkoutReport r " +
           "WHERE r.user.userId = :userId AND r.reportDate BETWEEN :start AND :end")
    BigDecimal sumVolumeByUserAndDateRange(@Param("userId") Long userId,
                                           @Param("start") LocalDate start,
                                           @Param("end") LocalDate end);
}
