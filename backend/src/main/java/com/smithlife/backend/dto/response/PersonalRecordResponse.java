package com.smithlife.backend.dto.response;

import com.smithlife.backend.entity.PersonalRecord;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.time.LocalDate;

@Getter
@Builder
public class PersonalRecordResponse {

    private Long recordId;
    private Long exerciseId;
    private String exerciseName;
    private String recordType; // ONE_RM, MAX_VOLUME, MAX_REPS
    private BigDecimal value;
    private LocalDate achievedAt;

    public static PersonalRecordResponse from(PersonalRecord record) {
        return PersonalRecordResponse.builder()
                .recordId(record.getRecordId())
                .exerciseId(record.getExercise().getExerciseId())
                .exerciseName(record.getExercise().getName())
                .recordType(record.getRecordType().name())
                .value(record.getValue())
                .achievedAt(record.getAchievedAt())
                .build();
    }
}
