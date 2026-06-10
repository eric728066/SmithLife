package com.smithlife.backend.dto.response;

import com.smithlife.backend.entity.Routine;
import com.smithlife.backend.entity.RoutineExercise;
import lombok.Builder;
import lombok.Getter;

import java.util.List;
import java.util.stream.Collectors;

@Getter
@Builder
public class RoutineResponse {

    private Long routineId;
    private String name;
    private String goal;         // MUSCLE_GAIN | DIET | STAMINA
    private String difficulty;   // BEGINNER | INTERMEDIATE | ADVANCED
    private Integer estimatedMin;
    private String frequency;
    private String description;
    private Boolean isPublic;
    private Boolean isRecommended;
    private String creatorName;
    private List<RoutineExerciseItem> exercises;

    public static RoutineResponse from(Routine routine) {
        List<RoutineExerciseItem> exercises = routine.getRoutineExercises() == null
                ? List.of()
                : routine.getRoutineExercises().stream()
                    .sorted((a, b) -> a.getOrderIndex().compareTo(b.getOrderIndex()))
                    .map(RoutineExerciseItem::from)
                    .collect(Collectors.toList());

        return RoutineResponse.builder()
                .routineId(routine.getRoutineId())
                .name(routine.getName())
                .goal(routine.getGoal().name())
                .difficulty(routine.getDifficulty().name())
                .estimatedMin(routine.getEstimatedMin())
                .frequency(routine.getFrequency())
                .description(routine.getDescription())
                .isPublic(routine.getIsPublic())
                .isRecommended(routine.getIsRecommended())
                .creatorName(routine.getCreator() != null ? routine.getCreator().getName() : null)
                .exercises(exercises)
                .build();
    }

    @Getter
    @Builder
    public static class RoutineExerciseItem {
        private Long exerciseId;
        private String name;
        private String bodyPart;
        private String muscle;
        private Integer orderIndex;
        private Integer targetSets;
        private Integer targetRepsMin;
        private Integer targetRepsMax;

        public static RoutineExerciseItem from(RoutineExercise re) {
            return RoutineExerciseItem.builder()
                    .exerciseId(re.getExercise().getExerciseId())
                    .name(re.getExercise().getName())
                    .bodyPart(re.getExercise().getBodyPart())
                    .muscle(re.getExercise().getEquipment())
                    .orderIndex(re.getOrderIndex())
                    .targetSets(re.getTargetSets())
                    .targetRepsMin(re.getTargetRepsMin())
                    .targetRepsMax(re.getTargetRepsMax())
                    .build();
        }
    }
}
