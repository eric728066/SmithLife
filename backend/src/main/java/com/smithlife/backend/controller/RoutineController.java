package com.smithlife.backend.controller;

import com.smithlife.backend.common.ApiResponse;
import com.smithlife.backend.dto.request.RoutineCreateRequest;
import com.smithlife.backend.dto.response.RoutineResponse;
import com.smithlife.backend.security.SecurityUtil;
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

    @Operation(summary = "공개 루틴 목록 조회", description = "추천 루틴 우선 정렬. 각 루틴의 즐겨찾기 여부 포함.")
    @GetMapping
    public ResponseEntity<ApiResponse<List<RoutineResponse>>> getPublicRoutines() {
        Long userId = SecurityUtil.getCurrentUserId();
        List<RoutineResponse> response = routineService.getPublicRoutines(userId);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @Operation(summary = "내가 만든 루틴 목록 조회")
    @GetMapping("/my")
    public ResponseEntity<ApiResponse<List<RoutineResponse>>> getMyRoutines() {
        Long userId = SecurityUtil.getCurrentUserId();
        List<RoutineResponse> response = routineService.getMyRoutines(userId);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @Operation(summary = "즐겨찾기 루틴 목록 조회")
    @GetMapping("/favorites")
    public ResponseEntity<ApiResponse<List<RoutineResponse>>> getFavoriteRoutines() {
        Long userId = SecurityUtil.getCurrentUserId();
        List<RoutineResponse> response = routineService.getFavoriteRoutines(userId);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @Operation(summary = "루틴 상세 조회")
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<RoutineResponse>> getRoutineDetail(@PathVariable Long id) {
        Long userId = SecurityUtil.getCurrentUserId();
        RoutineResponse response = routineService.getRoutineDetail(userId, id);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @Operation(summary = "루틴 생성")
    @PostMapping
    public ResponseEntity<ApiResponse<RoutineResponse>> createRoutine(
            @Valid @RequestBody RoutineCreateRequest request) {
        Long userId = SecurityUtil.getCurrentUserId();
        RoutineResponse response = routineService.createRoutine(userId, request);
        return ResponseEntity.ok(ApiResponse.ok("루틴이 생성되었습니다.", response));
    }

    @Operation(summary = "루틴 삭제")
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteRoutine(@PathVariable Long id) {
        Long userId = SecurityUtil.getCurrentUserId();
        routineService.deleteRoutine(userId, id);
        return ResponseEntity.ok(ApiResponse.ok("루틴이 삭제되었습니다."));
    }

    @Operation(summary = "즐겨찾기 추가")
    @PostMapping("/{id}/favorite")
    public ResponseEntity<ApiResponse<Void>> addFavorite(@PathVariable Long id) {
        Long userId = SecurityUtil.getCurrentUserId();
        routineService.addFavorite(userId, id);
        return ResponseEntity.ok(ApiResponse.ok("즐겨찾기에 추가되었습니다."));
    }

    @Operation(summary = "즐겨찾기 제거")
    @DeleteMapping("/{id}/favorite")
    public ResponseEntity<ApiResponse<Void>> removeFavorite(@PathVariable Long id) {
        Long userId = SecurityUtil.getCurrentUserId();
        routineService.removeFavorite(userId, id);
        return ResponseEntity.ok(ApiResponse.ok("즐겨찾기에서 제거되었습니다."));
    }
}
