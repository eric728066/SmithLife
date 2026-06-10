package com.smithlife.backend.dto.response;

import com.smithlife.backend.entity.Exercise;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class ExerciseResponse {

    private Long exerciseId;
    private String name;
    private String bodyPart;   // 카테고리 (가슴, 등, 어깨, ...)
    private String muscle;     // 세부 근육 (가슴 상부, 광배근, ...)

    public static ExerciseResponse from(Exercise exercise) {
        return ExerciseResponse.builder()
                .exerciseId(exercise.getExerciseId())
                .name(exercise.getName())
                .bodyPart(exercise.getBodyPart())
                .muscle(exercise.getEquipment())  // equipment 필드를 muscle 설명으로 재사용
                .build();
    }
}
