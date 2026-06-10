package com.smithlife.backend.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;

import java.util.List;

@Getter
public class WorkoutSessionSaveRequest {

    private Long routineId;   // 추천/공유 루틴 선택 시; 나만의 루틴이면 null

    @NotBlank(message = "세션 이름을 입력해주세요.")
    private String sessionName;

    @NotNull(message = "운동 시간을 입력해주세요.")
    private Integer totalDurationSec;

    private List<ExerciseData> exercises;

    private Double totalVolumeKgOverride; // 클라이언트에서 직접 계산한 총 볼륨 (선택)

    @Getter
    public static class ExerciseData {
        private String exerciseName;  // DB의 Exercise.name 과 매칭
        private Integer orderIndex;
        private String status;        // "COMPLETED" | "PENDING" | "IN_PROGRESS"
        private List<SetData> sets;
    }

    @Getter
    public static class SetData {
        private Integer setNumber;
        private Double weightKg;
        private Integer reps;
        private Boolean isCompleted;
    }
}
