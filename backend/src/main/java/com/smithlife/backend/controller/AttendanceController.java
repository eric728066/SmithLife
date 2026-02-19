package com.smithlife.backend.controller;

import com.smithlife.backend.common.ApiResponse;
import com.smithlife.backend.dto.response.AttendanceRateResponse;
import com.smithlife.backend.dto.response.AttendanceResponse;
import com.smithlife.backend.security.SecurityUtil;
import com.smithlife.backend.service.AttendanceService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/attendance")
@RequiredArgsConstructor
public class AttendanceController {

    private final AttendanceService attendanceService;

    // QR 스캔으로 체크인
    @PostMapping("/checkin")
    public ResponseEntity<ApiResponse<AttendanceResponse>> checkIn(
            @RequestParam String qrToken) {
        return ResponseEntity.ok(ApiResponse.ok("체크인 완료", attendanceService.checkIn(qrToken)));
    }

    // 체크아웃
    @PostMapping("/checkout")
    public ResponseEntity<ApiResponse<AttendanceResponse>> checkOut() {
        Long userId = SecurityUtil.getCurrentUserId();
        return ResponseEntity.ok(ApiResponse.ok("체크아웃 완료", attendanceService.checkOut(userId)));
    }

    // 출석 내역 조회
    @GetMapping("/history")
    public ResponseEntity<ApiResponse<List<AttendanceResponse>>> getHistory() {
        Long userId = SecurityUtil.getCurrentUserId();
        return ResponseEntity.ok(ApiResponse.ok(attendanceService.getHistory(userId)));
    }

    // 월간 출석률 조회
    @GetMapping("/rate")
    public ResponseEntity<ApiResponse<AttendanceRateResponse>> getAttendanceRate() {
        Long userId = SecurityUtil.getCurrentUserId();
        return ResponseEntity.ok(ApiResponse.ok(attendanceService.getAttendanceRate(userId)));
    }
}
