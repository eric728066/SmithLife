package com.smithlife.backend.service;

import com.smithlife.backend.entity.Reservation;
import com.smithlife.backend.repository.AttendanceRepository;
import com.smithlife.backend.repository.ReservationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;

@Service
@RequiredArgsConstructor
public class AttendanceService {

    private final AttendanceRepository attendanceRepository;
    private final ReservationRepository reservationRepository;

    // 참석율 계산: 실제 체크인 수 / 과거 확정 예약 수
    @Transactional(readOnly = true)
    public int getMyAttendanceRate(Long userId) {
        long totalPastConfirmed = reservationRepository
                .countByUserUserIdAndStatusAndSlotDateBefore(
                        userId, Reservation.Status.CONFIRMED, LocalDate.now());

        if (totalPastConfirmed == 0) {
            return 0;
        }

        long attended = attendanceRepository.countByUserUserId(userId);
        return (int) Math.min(100, attended * 100 / totalPastConfirmed);
    }
}
