package com.smithlife.backend.repository;

import com.smithlife.backend.entity.Attendance;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface AttendanceRepository extends JpaRepository<Attendance, Long> {
    List<Attendance> findAllByUserUserIdOrderByCreatedAtDesc(Long userId);
    Optional<Attendance> findTopByUserUserIdAndStatusOrderByCreatedAtDesc(Long userId, Attendance.Status status);
    long countByUserUserId(Long userId);
}
