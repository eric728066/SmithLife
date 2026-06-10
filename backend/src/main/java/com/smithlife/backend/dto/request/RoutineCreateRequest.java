package com.smithlife.backend.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;

import java.util.List;

@Getter
public class RoutineCreateRequest {

    @NotBlank(message = "루틴 이름을 입력해주세요.")
    private String name;

    @NotBlank(message = "목표를 입력해주세요.")
    private String goal;        // "MUSCLE_GAIN" | "DIET" | "STAMINA"

    @NotBlank(message = "난이도를 입력해주세요.")
    private String difficulty;  // "BEGINNER" | "INTERMEDIATE" | "ADVANCED"

    private String frequency;   // "주 3회" 등

    private String description;

    @NotNull(message = "운동 목록을 입력해주세요.")
    private List<ExerciseItem> exercises;

    @Getter
    public static class ExerciseItem {
        private String exerciseName;   // 운동 이름으로 DB 조회
        private Integer orderIndex;
        private Integer targetSets;
        private Integer targetRepsMin;
        private Integer targetRepsMax;
    }
}
