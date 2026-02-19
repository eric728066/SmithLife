package com.smithlife.backend.dto.request;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class ExerciseAddRequest {

    @NotNull(message = "운동 ID는 필수입니다")
    private Long exerciseId;

    @NotNull(message = "목표 세트 수는 필수입니다")
    @Min(value = 1, message = "목표 세트 수는 1 이상이어야 합니다")
    private Integer targetSets;

    @NotNull(message = "목표 반복 수는 필수입니다")
    @Min(value = 1, message = "목표 반복 수는 1 이상이어야 합니다")
    private Integer targetReps;
}
