package com.smithlife.backend.repository;

import com.smithlife.backend.entity.Attendance;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface AttendanceRepository extends JpaRepository<Attendance, Long> {

    // 오늘 체크인 여부 확인
    Optional<Attendance> findTopByUserUserIdAndStatusOrderByCheckInTimeDesc(
            Long userId, Attendance.Status status);

    // QR 토큰으로 출석 조회
    Optional<Attendance> findByQrToken(String qrToken);

    // 출석 내역 조회 (최신순)
    List<Attendance> findAllByUserUserIdOrderByCheckInTimeDesc(Long userId);

    // 기간별 출석 수 조회
    @Query("SELECT COUNT(a) FROM Attendance a WHERE a.user.userId = :userId " +
            "AND a.checkInTime >= :from AND a.checkInTime < :to")
    long countByUserIdAndPeriod(@Param("userId") Long userId,
                                @Param("from") LocalDateTime from,
                                @Param("to") LocalDateTime to);
}
