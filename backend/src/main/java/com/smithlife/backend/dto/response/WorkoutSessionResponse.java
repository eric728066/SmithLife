package com.smithlife.backend.dto.response;

import com.smithlife.backend.entity.WorkoutSession;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Getter
@Builder
public class WorkoutSessionResponse {

    private Long sessionId;
    private String sessionName;
    private String status;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private Integer totalDurationSec;
    private BigDecimal totalVolumeKg;
    private BigDecimal totalCalories;
    private LocalDateTime createdAt;
    private List<SessionExerciseResponse> exercises;

    // 목록 조회용 (exercises 없이)
    public static WorkoutSessionResponse from(WorkoutSession session) {
        return WorkoutSessionResponse.builder()
                .sessionId(session.getSessionId())
                .sessionName(session.getSessionName())
                .status(session.getStatus().name())
                .startTime(session.getStartTime())
                .endTime(session.getEndTime())
                .totalDurationSec(session.getTotalDurationSec())
                .totalVolumeKg(session.getTotalVolumeKg())
                .totalCalories(session.getTotalCalories())
                .createdAt(session.getCreatedAt())
                .exercises(List.of())
                .build();
    }

    // 상세 조회용 (exercises 포함)
    public static WorkoutSessionResponse fromDetail(WorkoutSession session) {
        List<SessionExerciseResponse> exercises = session.getSessionExercises() != null
                ? session.getSessionExercises().stream()
                    .map(SessionExerciseResponse::from)
                    .collect(Collectors.toList())
                : List.of();

        return WorkoutSessionResponse.builder()
                .sessionId(session.getSessionId())
                .sessionName(session.getSessionName())
                .status(session.getStatus().name())
                .startTime(session.getStartTime())
                .endTime(session.getEndTime())
                .totalDurationSec(session.getTotalDurationSec())
                .totalVolumeKg(session.getTotalVolumeKg())
                .totalCalories(session.getTotalCalories())
                .createdAt(session.getCreatedAt())
                .exercises(exercises)
                .build();
    }
}
