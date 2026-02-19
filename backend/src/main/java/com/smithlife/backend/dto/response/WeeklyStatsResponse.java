package com.smithlife.backend.dto.response;

import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Getter
@Builder
public class WeeklyStatsResponse {

    private LocalDate weekStart;
    private LocalDate weekEnd;
    private Integer totalWorkouts;
    private Integer totalTimeSec;
    private BigDecimal totalVolumeKg;
    private BigDecimal totalCalories;
    private List<DailyStatResponse> dailyStats;

    @Getter
    @Builder
    public static class DailyStatResponse {
        private LocalDate date;
        private Integer workoutCount;
        private BigDecimal volumeKg;
        private Integer timeSec;
    }
}
