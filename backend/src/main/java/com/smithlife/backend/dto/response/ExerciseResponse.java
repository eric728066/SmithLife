package com.smithlife.backend.dto.response;

import com.smithlife.backend.entity.Exercise;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class ExerciseResponse {

    private Long exerciseId;
    private String name;
    private String bodyPart;
    private String equipment;
    private String imageUrl;
    private String description;

    public static ExerciseResponse from(Exercise exercise) {
        return ExerciseResponse.builder()
                .exerciseId(exercise.getExerciseId())
                .name(exercise.getName())
                .bodyPart(exercise.getBodyPart())
                .equipment(exercise.getEquipment())
                .imageUrl(exercise.getImageUrl())
                .description(exercise.getDescription())
                .build();
    }
}
