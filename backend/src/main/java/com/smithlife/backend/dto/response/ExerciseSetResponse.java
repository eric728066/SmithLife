package com.smithlife.backend.dto.response;

import com.smithlife.backend.entity.ExerciseSet;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter
@Builder
public class ExerciseSetResponse {

    private Long setId;
    private Integer setNumber;
    private BigDecimal weightKg;
    private Integer reps;
    private Boolean isCompleted;
    private Integer restTimeSec;
    private LocalDateTime completedAt;

    public static ExerciseSetResponse from(ExerciseSet set) {
        return ExerciseSetResponse.builder()
                .setId(set.getSetId())
                .setNumber(set.getSetNumber())
                .weightKg(set.getWeightKg())
                .reps(set.getReps())
                .isCompleted(set.getIsCompleted())
                .restTimeSec(set.getRestTimeSec())
                .completedAt(set.getCompletedAt())
                .build();
    }
}
