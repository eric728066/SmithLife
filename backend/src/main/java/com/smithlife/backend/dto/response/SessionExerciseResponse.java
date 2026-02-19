package com.smithlife.backend.dto.response;

import com.smithlife.backend.entity.SessionExercise;
import lombok.Builder;
import lombok.Getter;

import java.util.List;
import java.util.stream.Collectors;

@Getter
@Builder
public class SessionExerciseResponse {

    private Long sessionExerciseId;
    private Long exerciseId;
    private String exerciseName;
    private String bodyPart;
    private Integer orderIndex;
    private Integer targetSets;
    private Integer targetReps;
    private String status;
    private List<ExerciseSetResponse> sets;

    public static SessionExerciseResponse from(SessionExercise se) {
        List<ExerciseSetResponse> sets = se.getExerciseSets() != null
                ? se.getExerciseSets().stream()
                    .map(ExerciseSetResponse::from)
                    .collect(Collectors.toList())
                : List.of();

        return SessionExerciseResponse.builder()
                .sessionExerciseId(se.getSessionExerciseId())
                .exerciseId(se.getExercise().getExerciseId())
                .exerciseName(se.getExercise().getName())
                .bodyPart(se.getExercise().getBodyPart())
                .orderIndex(se.getOrderIndex())
                .targetSets(se.getTargetSets())
                .targetReps(se.getTargetReps())
                .status(se.getStatus().name())
                .sets(sets)
                .build();
    }
}
