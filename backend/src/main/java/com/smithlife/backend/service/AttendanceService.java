package com.smithlife.backend.service;

import com.smithlife.backend.common.ErrorCode;
import com.smithlife.backend.dto.response.AttendanceRateResponse;
import com.smithlife.backend.dto.response.AttendanceResponse;
import com.smithlife.backend.entity.Attendance;
import com.smithlife.backend.entity.User;
import com.smithlife.backend.exception.CustomException;
import com.smithlife.backend.repository.AttendanceRepository;
import com.smithlife.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AttendanceService {

    private final AttendanceRepository attendanceRepository;
    private final UserRepository userRepository;
    private final QrService qrService;

    // QR 스캔으로 체크인
    @Transactional
    public AttendanceResponse checkIn(String qrToken) {
        if (!qrService.validateQrToken(qrToken)) {
            throw new CustomException(ErrorCode.INVALID_TOKEN);
        }

        Long userId = qrService.extractUserId(qrToken);
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        // 이미 체크인 상태인지 확인
        attendanceRepository.findTopByUserUserIdAndStatusOrderByCheckInTimeDesc(
                userId, Attendance.Status.CHECKED_IN)
                .ifPresent(a -> { throw new CustomException(ErrorCode.DUPLICATE_RESERVATION); });

        Attendance attendance = Attendance.builder()
                .user(user)
                .checkInTime(LocalDateTime.now())
                .qrToken(qrToken)
                .status(Attendance.Status.CHECKED_IN)
                .build();

        return AttendanceResponse.from(attendanceRepository.save(attendance));
    }

    // 체크아웃
    @Transactional
    public AttendanceResponse checkOut(Long userId) {
        Attendance attendance = attendanceRepository
                .findTopByUserUserIdAndStatusOrderByCheckInTimeDesc(
                        userId, Attendance.Status.CHECKED_IN)
                .orElseThrow(() -> new CustomException(ErrorCode.RESOURCE_NOT_FOUND));

        Attendance updated = Attendance.builder()
                .attendanceId(attendance.getAttendanceId())
                .user(attendance.getUser())
                .checkInTime(attendance.getCheckInTime())
                .checkOutTime(LocalDateTime.now())
                .qrToken(attendance.getQrToken())
                .status(Attendance.Status.CHECKED_OUT)
                .build();

        return AttendanceResponse.from(attendanceRepository.save(updated));
    }

    // 출석 내역 조회
    @Transactional(readOnly = true)
    public List<AttendanceResponse> getHistory(Long userId) {
        return attendanceRepository.findAllByUserUserIdOrderByCheckInTimeDesc(userId)
                .stream()
                .map(AttendanceResponse::from)
                .collect(Collectors.toList());
    }

    // 월간 출석률 조회
    @Transactional(readOnly = true)
    public AttendanceRateResponse getAttendanceRate(Long userId) {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime startOfMonth = now.withDayOfMonth(1).truncatedTo(ChronoUnit.DAYS);
        LocalDateTime endOfMonth = startOfMonth.plusMonths(1);

        int totalDays = now.getDayOfMonth();
        long attendedDays = attendanceRepository.countByUserIdAndPeriod(
                userId, startOfMonth, endOfMonth);

        double rate = totalDays > 0
                ? Math.round((double) attendedDays / totalDays * 100 * 10) / 10.0
                : 0.0;

        return AttendanceRateResponse.builder()
                .totalDays(totalDays)
                .attendedDays((int) attendedDays)
                .attendanceRate(rate)
                .build();
    }
}
