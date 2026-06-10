package com.smithlife.backend.dto.response;

import com.smithlife.backend.entity.SessionExercise;
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
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private Integer totalDurationSec;
    private String timerLabel;
    private Integer completedExercises;
    private Integer totalExercises;
    private Integer completionPercent;
    private BigDecimal totalVolumeKg;
    private List<SessionExerciseItem> exercises;

    public static WorkoutSessionResponse from(WorkoutSession session) {
        List<SessionExercise> sessionExercises = session.getSessionExercises() == null
                ? List.of()
                : session.getSessionExercises();

        // DB에 저장된 실제 총/완료 수 우선, 없으면 sessionExercises 기준
        int total = session.getTotalExercises() != null && session.getTotalExercises() > 0
                ? session.getTotalExercises()
                : sessionExercises.size();
        int completed = session.getCompletedExercises() != null && session.getTotalExercises() != null && session.getTotalExercises() > 0
                ? session.getCompletedExercises()
                : (int) sessionExercises.stream()
                        .filter(se -> se.getStatus() == SessionExercise.Status.COMPLETED)
                        .count();

        List<SessionExerciseItem> items = sessionExercises.stream()
                .sorted((a, b) -> a.getOrderIndex().compareTo(b.getOrderIndex()))
                .map(SessionExerciseItem::from)
                .collect(Collectors.toList());

        int durationSec = session.getTotalDurationSec() != null ? session.getTotalDurationSec() : 0;
        int m = durationSec / 60;
        int s = durationSec % 60;
        String timerLabel = String.format("%02d:%02d", m, s);

        return WorkoutSessionResponse.builder()
                .sessionId(session.getSessionId())
                .sessionName(session.getSessionName())
                .startTime(session.getStartTime())
                .endTime(session.getEndTime())
                .totalDurationSec(durationSec)
                .timerLabel(timerLabel)
                .completedExercises(completed)
                .totalExercises(total)
                .completionPercent(total > 0 ? (completed * 100 / total) : 0)
                .totalVolumeKg(session.getTotalVolumeKg() != null ? session.getTotalVolumeKg() : BigDecimal.ZERO)
                .exercises(items)
                .build();
    }

    @Getter
    @Builder
    public static class SessionExerciseItem {
        private Long exerciseId;
        private String name;
        private String bodyPart;
        private String muscle;
        private String status;   // PENDING | IN_PROGRESS | COMPLETED

        public static SessionExerciseItem from(SessionExercise se) {
            return SessionExerciseItem.builder()
                    .exerciseId(se.getExercise() != null ? se.getExercise().getExerciseId() : null)
                    .name(se.getExercise() != null ? se.getExercise().getName() : "")
                    .bodyPart(se.getExercise() != null ? se.getExercise().getBodyPart() : "")
                    .muscle(se.getExercise() != null ? se.getExercise().getEquipment() : "")
                    .status(se.getStatus().name())
                    .build();
        }
    }
}
