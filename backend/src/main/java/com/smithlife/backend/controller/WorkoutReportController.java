package com.smithlife.backend.controller;

import com.smithlife.backend.common.ApiResponse;
import com.smithlife.backend.dto.response.WeeklyStatsResponse;
import com.smithlife.backend.dto.response.WorkoutReportResponse;
import com.smithlife.backend.security.SecurityUtil;
import com.smithlife.backend.service.WorkoutReportService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/reports")
@RequiredArgsConstructor
@Tag(name = "WorkoutReport", description = "운동 리포트 API")
public class WorkoutReportController {

    private final WorkoutReportService workoutReportService;

    @Operation(summary = "리포트 생성", description = "세션 종료 후 호출. 이미 존재하면 기존 리포트 반환.")
    @PostMapping("/generate/{sessionId}")
    public ResponseEntity<ApiResponse<WorkoutReportResponse>> generateReport(
            @PathVariable Long sessionId) {
        Long userId = SecurityUtil.getCurrentUserId();
        WorkoutReportResponse response = workoutReportService.generateReport(userId, sessionId);
        return ResponseEntity.ok(ApiResponse.ok("리포트가 생성되었습니다.", response));
    }

    @Operation(summary = "리포트 상세 조회")
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<WorkoutReportResponse>> getReportDetail(
            @PathVariable Long id) {
        Long userId = SecurityUtil.getCurrentUserId();
        WorkoutReportResponse response = workoutReportService.getReportDetail(userId, id);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @Operation(summary = "내 리포트 목록 조회")
    @GetMapping("/my")
    public ResponseEntity<ApiResponse<List<WorkoutReportResponse>>> getMyReports() {
        Long userId = SecurityUtil.getCurrentUserId();
        List<WorkoutReportResponse> response = workoutReportService.getMyReports(userId);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @Operation(summary = "주간 통계 조회", description = "이번 주 월요일~일요일 기준 통계")
    @GetMapping("/weekly")
    public ResponseEntity<ApiResponse<WeeklyStatsResponse>> getWeeklyStats() {
        Long userId = SecurityUtil.getCurrentUserId();
        WeeklyStatsResponse response = workoutReportService.getWeeklyStats(userId);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }
}
