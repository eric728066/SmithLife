package com.smithlife.backend.controller;

import com.smithlife.backend.common.ApiResponse;
import com.smithlife.backend.security.SecurityUtil;
import com.smithlife.backend.service.AttendanceService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/attendance")
@RequiredArgsConstructor
@Tag(name = "Attendance", description = "출석 API")
public class AttendanceController {

    private final AttendanceService attendanceService;

    @GetMapping("/rate")
    @Operation(summary = "참석율 조회", description = "현재 유저의 참석율 조회 (0-100)")
    public ResponseEntity<ApiResponse<Integer>> getAttendanceRate() {
        Long userId = SecurityUtil.getCurrentUserId();
        int rate = attendanceService.getMyAttendanceRate(userId);
        return ResponseEntity.ok(ApiResponse.ok(rate));
    }
}
