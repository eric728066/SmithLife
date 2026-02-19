package com.smithlife.backend.controller;

import com.smithlife.backend.common.ApiResponse;
import com.smithlife.backend.dto.request.ExerciseAddRequest;
import com.smithlife.backend.dto.request.SessionStartRequest;
import com.smithlife.backend.dto.request.SetRecordRequest;
import com.smithlife.backend.dto.response.ExerciseSetResponse;
import com.smithlife.backend.dto.response.SessionExerciseResponse;
import com.smithlife.backend.dto.response.WorkoutSessionResponse;
import com.smithlife.backend.security.SecurityUtil;
import com.smithlife.backend.service.WorkoutSessionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/sessions")
@RequiredArgsConstructor
@Tag(name = "WorkoutSession", description = "운동 세션 API")
public class WorkoutSessionController {

    private final WorkoutSessionService workoutSessionService;

    @Operation(summary = "세션 시작")
    @PostMapping("/start")
    public ResponseEntity<ApiResponse<WorkoutSessionResponse>> startSession(
            @Valid @RequestBody SessionStartRequest request) {
        Long userId = SecurityUtil.getCurrentUserId();
        WorkoutSessionResponse response = workoutSessionService.startSession(userId, request);
        return ResponseEntity.ok(ApiResponse.ok("세션이 시작되었습니다.", response));
    }

    @Operation(summary = "세션 종료")
    @PostMapping("/{id}/end")
    public ResponseEntity<ApiResponse<WorkoutSessionResponse>> endSession(@PathVariable Long id) {
        Long userId = SecurityUtil.getCurrentUserId();
        WorkoutSessionResponse response = workoutSessionService.endSession(userId, id);
        return ResponseEntity.ok(ApiResponse.ok("세션이 종료되었습니다.", response));
    }

    @Operation(summary = "진행 중인 세션 조회")
    @GetMapping("/active")
    public ResponseEntity<ApiResponse<WorkoutSessionResponse>> getActiveSession() {
        Long userId = SecurityUtil.getCurrentUserId();
        WorkoutSessionResponse response = workoutSessionService.getActiveSession(userId);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @Operation(summary = "세션 목록 조회")
    @GetMapping
    public ResponseEntity<ApiResponse<List<WorkoutSessionResponse>>> getSessionList() {
        Long userId = SecurityUtil.getCurrentUserId();
        List<WorkoutSessionResponse> response = workoutSessionService.getSessionList(userId);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @Operation(summary = "세션 상세 조회")
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<WorkoutSessionResponse>> getSessionDetail(@PathVariable Long id) {
        Long userId = SecurityUtil.getCurrentUserId();
        WorkoutSessionResponse response = workoutSessionService.getSessionDetail(userId, id);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @Operation(summary = "세션에 운동 추가")
    @PostMapping("/{id}/exercises")
    public ResponseEntity<ApiResponse<SessionExerciseResponse>> addExercise(
            @PathVariable Long id,
            @Valid @RequestBody ExerciseAddRequest request) {
        Long userId = SecurityUtil.getCurrentUserId();
        SessionExerciseResponse response = workoutSessionService.addExercise(userId, id, request);
        return ResponseEntity.ok(ApiResponse.ok("운동이 추가되었습니다.", response));
    }

    @Operation(summary = "세트 기록")
    @PostMapping("/{id}/exercises/{sessionExerciseId}/sets")
    public ResponseEntity<ApiResponse<ExerciseSetResponse>> recordSet(
            @PathVariable Long id,
            @PathVariable Long sessionExerciseId,
            @Valid @RequestBody SetRecordRequest request) {
        Long userId = SecurityUtil.getCurrentUserId();
        ExerciseSetResponse response = workoutSessionService.recordSet(userId, id, sessionExerciseId, request);
        return ResponseEntity.ok(ApiResponse.ok("세트가 기록되었습니다.", response));
    }
}
