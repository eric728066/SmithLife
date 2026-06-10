package com.smithlife.backend.controller;

import com.smithlife.backend.common.ApiResponse;
import com.smithlife.backend.dto.request.RoutineCreateRequest;
import com.smithlife.backend.dto.response.RoutineResponse;
import com.smithlife.backend.service.RoutineService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/routines")
@RequiredArgsConstructor
@Tag(name = "Routine", description = "루틴 API")
public class RoutineController {

    private final RoutineService routineService;

    @GetMapping("/recommended")
    @Operation(
        summary = "추천 루틴 목록 조회",
        description = "관리자가 등록한 기본 제공 추천 루틴 목록을 반환합니다.\n\n" +
                      "goal: MUSCLE_GAIN(근성장) | DIET(다이어트) | STAMINA(체력증진)\n\n" +
                      "difficulty: BEGINNER(입문) | INTERMEDIATE(중급) | ADVANCED(고급)"
    )
    public ResponseEntity<ApiResponse<List<RoutineResponse>>> getRecommendedRoutines() {
        return ResponseEntity.ok(
                ApiResponse.ok("추천 루틴 조회 성공", routineService.getRecommendedRoutines())
        );
    }

    @GetMapping("/shared")
    @Operation(
        summary = "공유 루틴 목록 조회",
        description = "회원들이 공개로 등록한 공유 루틴 목록을 반환합니다. (최신순)"
    )
    public ResponseEntity<ApiResponse<List<RoutineResponse>>> getSharedRoutines() {
        return ResponseEntity.ok(
                ApiResponse.ok("공유 루틴 조회 성공", routineService.getSharedRoutines())
        );
    }

    @GetMapping("/my-shared")
    @Operation(
        summary = "내 공유 루틴 목록 조회",
        description = "로그인한 사용자가 등록한 공유 루틴 목록을 반환합니다."
    )
    public ResponseEntity<ApiResponse<List<RoutineResponse>>> getMySharedRoutines() {
        return ResponseEntity.ok(
                ApiResponse.ok("내 공유 루틴 조회 성공", routineService.getMySharedRoutines())
        );
    }

    @PostMapping("/shared")
    @Operation(
        summary = "공유 루틴 생성",
        description = "루틴을 생성하고 다른 회원들과 공유합니다.\n\n" +
                      "exercises[].exerciseName 은 운동 목록 API에서 조회한 name 값을 사용하세요."
    )
    public ResponseEntity<ApiResponse<RoutineResponse>> createSharedRoutine(
            @Valid @RequestBody RoutineCreateRequest request
    ) {
        return ResponseEntity.ok(
                ApiResponse.ok("공유 루틴 생성 성공", routineService.createSharedRoutine(request))
        );
    }

    @DeleteMapping("/{routineId}")
    @Operation(
        summary = "내 공유 루틴 삭제",
        description = "본인이 생성한 공유 루틴을 삭제합니다. 타인의 루틴 삭제 시 403 반환."
    )
    public ResponseEntity<ApiResponse<Void>> deleteSharedRoutine(
            @PathVariable Long routineId
    ) {
        routineService.deleteSharedRoutine(routineId);
        return ResponseEntity.ok(ApiResponse.ok("루틴 삭제 완료"));
    }
}
