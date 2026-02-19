package com.smithlife.backend.dto.response;

import com.smithlife.backend.entity.RoutineExercise;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class RoutineExerciseResponse {

    private Long routineExerciseId;
    private Long exerciseId;
    private String exerciseName;
    private String bodyPart;
    private String equipment;
    private Integer orderIndex;
    private Integer targetSets;
    private Integer targetRepsMin;
    private Integer targetRepsMax;

    public static RoutineExerciseResponse from(RoutineExercise re) {
        return RoutineExerciseResponse.builder()
                .routineExerciseId(re.getRoutineExerciseId())
                .exerciseId(re.getExercise().getExerciseId())
                .exerciseName(re.getExercise().getName())
                .bodyPart(re.getExercise().getBodyPart())
                .equipment(re.getExercise().getEquipment())
                .orderIndex(re.getOrderIndex())
                .targetSets(re.getTargetSets())
                .targetRepsMin(re.getTargetRepsMin())
                .targetRepsMax(re.getTargetRepsMax())
                .build();
    }
}
