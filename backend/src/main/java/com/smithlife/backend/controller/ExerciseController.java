package com.smithlife.backend.controller;

import com.smithlife.backend.common.ApiResponse;
import com.smithlife.backend.dto.response.ExerciseResponse;
import com.smithlife.backend.service.ExerciseService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/exercises")
@RequiredArgsConstructor
@Tag(name = "Exercise", description = "운동 종목 API")
public class ExerciseController {

    private final ExerciseService exerciseService;

    @GetMapping
    @Operation(
        summary = "운동 목록 조회",
        description = "전체 운동 목록을 조회합니다. bodyPart 파라미터로 카테고리 필터링이 가능합니다.\n\n" +
                      "카테고리: 가슴, 등, 어깨, 삼두, 이두, 하체, 코어, 전신"
    )
    public ResponseEntity<ApiResponse<List<ExerciseResponse>>> getExercises(
            @Parameter(description = "부위 필터 (가슴, 등, 어깨, 삼두, 이두, 하체, 코어, 전신)")
            @RequestParam(required = false) String bodyPart
    ) {
        return ResponseEntity.ok(
                ApiResponse.ok("운동 목록 조회 성공", exerciseService.getExercises(bodyPart))
        );
    }
}
