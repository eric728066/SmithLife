package com.smithlife.backend.dto.request;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.List;

@Getter
@NoArgsConstructor
public class RoutineCreateRequest {

    @NotBlank(message = "루틴 이름은 필수입니다")
    private String name;

    @NotNull(message = "목표는 필수입니다")
    private String goal; // MUSCLE_GAIN, DIET, STAMINA

    @NotNull(message = "난이도는 필수입니다")
    private String difficulty; // BEGINNER, INTERMEDIATE, ADVANCED

    @NotNull(message = "예상 소요 시간은 필수입니다")
    @Min(value = 1, message = "예상 소요 시간은 1분 이상이어야 합니다")
    private Integer estimatedMin;

    private String frequency;
    private String description;
    private Boolean isPublic = true;

    @NotNull(message = "운동 목록은 필수입니다")
    private List<RoutineExerciseItem> exercises;

    @Getter
    @NoArgsConstructor
    public static class RoutineExerciseItem {
        @NotNull private Long exerciseId;
        @NotNull private Integer orderIndex;
        @NotNull private Integer targetSets;
        @NotNull private Integer targetRepsMin;
        private Integer targetRepsMax;
    }
}
