package com.smithlife.backend.dto.response;

import com.smithlife.backend.entity.Routine;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Getter
@Builder
public class RoutineResponse {

    private Long routineId;
    private String name;
    private String goal;
    private String difficulty;
    private Integer estimatedMin;
    private String frequency;
    private String description;
    private String imageUrl;
    private Boolean isPublic;
    private Boolean isRecommended;
    private Long creatorId;
    private LocalDateTime createdAt;
    private Boolean isFavorited;
    private List<RoutineExerciseResponse> exercises;

    public static RoutineResponse from(Routine routine, boolean isFavorited) {
        List<RoutineExerciseResponse> exercises = routine.getRoutineExercises() != null
                ? routine.getRoutineExercises().stream()
                    .map(RoutineExerciseResponse::from)
                    .sorted((a, b) -> a.getOrderIndex().compareTo(b.getOrderIndex()))
                    .collect(Collectors.toList())
                : List.of();

        return RoutineResponse.builder()
                .routineId(routine.getRoutineId())
                .name(routine.getName())
                .goal(routine.getGoal().name())
                .difficulty(routine.getDifficulty().name())
                .estimatedMin(routine.getEstimatedMin())
                .frequency(routine.getFrequency())
                .description(routine.getDescription())
                .imageUrl(routine.getImageUrl())
                .isPublic(routine.getIsPublic())
                .isRecommended(routine.getIsRecommended())
                .creatorId(routine.getCreator() != null ? routine.getCreator().getUserId() : null)
                .createdAt(routine.getCreatedAt())
                .isFavorited(isFavorited)
                .exercises(exercises)
                .build();
    }
}
