package com.smithlife.backend.controller;

import com.smithlife.backend.common.ApiResponse;
import com.smithlife.backend.dto.response.ExerciseResponse;
import com.smithlife.backend.dto.response.PersonalRecordResponse;
import com.smithlife.backend.security.SecurityUtil;
import com.smithlife.backend.service.ExerciseService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
@Tag(name = "Exercise", description = "운동 종목 API")
public class ExerciseController {

    private final ExerciseService exerciseService;

    @Operation(summary = "운동 목록 조회", description = "keyword로 이름/부위 검색 가능. 없으면 전체 조회.")
    @GetMapping("/exercises")
    public ResponseEntity<ApiResponse<List<ExerciseResponse>>> getExercises(
            @RequestParam(required = false) String keyword) {
        List<ExerciseResponse> response = exerciseService.getExercises(keyword);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @Operation(summary = "개인 최고 기록 조회")
    @GetMapping("/personal-records")
    public ResponseEntity<ApiResponse<List<PersonalRecordResponse>>> getPersonalRecords() {
        Long userId = SecurityUtil.getCurrentUserId();
        List<PersonalRecordResponse> response = exerciseService.getPersonalRecords(userId);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }
}
