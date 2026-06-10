package com.smithlife.backend.controller;

import com.smithlife.backend.common.ApiResponse;
import com.smithlife.backend.dto.request.WorkoutSessionSaveRequest;
import com.smithlife.backend.dto.response.WorkoutSessionResponse;
import com.smithlife.backend.service.WorkoutService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/workout")
@RequiredArgsConstructor
@Tag(name = "Workout", description = "운동 세션/기록 API")
public class WorkoutController {

    private final WorkoutService workoutService;

    @PostMapping("/sessions")
    @Operation(
        summary = "운동 세션 저장",
        description = "운동 완료 후 세션 기록을 저장합니다.\n\n" +
                      "- routineId: 추천/공유 루틴 사용 시 해당 ID, 나만의 루틴이면 null\n\n" +
                      "- exercises[].status: COMPLETED | IN_PROGRESS | PENDING\n\n" +
                      "- exercises[].exerciseName: /api/exercises 에서 조회한 name 값 사용"
    )
    public ResponseEntity<ApiResponse<WorkoutSessionResponse>> saveSession(
            @Valid @RequestBody WorkoutSessionSaveRequest request
    ) {
        return ResponseEntity.ok(
                ApiResponse.ok("운동 기록 저장 성공", workoutService.saveSession(request))
        );
    }

    @GetMapping("/sessions")
    @Operation(
        summary = "내 운동 기록 목록 조회",
        description = "로그인한 사용자의 운동 기록을 최신순으로 반환합니다."
    )
    public ResponseEntity<ApiResponse<List<WorkoutSessionResponse>>> getMyHistory() {
        return ResponseEntity.ok(
                ApiResponse.ok("운동 기록 조회 성공", workoutService.getMyHistory())
        );
    }

    @GetMapping("/sessions/{sessionId}")
    @Operation(
        summary = "운동 세션 상세 조회",
        description = "특정 운동 세션의 상세 정보를 반환합니다. 본인 세션만 조회 가능합니다."
    )
    public ResponseEntity<ApiResponse<WorkoutSessionResponse>> getSession(
            @PathVariable Long sessionId
    ) {
        return ResponseEntity.ok(
                ApiResponse.ok("세션 상세 조회 성공", workoutService.getSession(sessionId))
        );
    }

    @DeleteMapping("/sessions/{sessionId}")
    @Operation(
        summary = "운동 세션 삭제",
        description = "특정 운동 세션을 삭제합니다. 본인 세션만 삭제 가능합니다."
    )
    public ResponseEntity<ApiResponse<Void>> deleteSession(
            @PathVariable Long sessionId
    ) {
        workoutService.deleteSession(sessionId);
        return ResponseEntity.ok(ApiResponse.ok("세션 삭제 성공", null));
    }
}
