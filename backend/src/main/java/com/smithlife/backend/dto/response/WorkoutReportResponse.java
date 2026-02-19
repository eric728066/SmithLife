package com.smithlife.backend.dto.response;

import com.smithlife.backend.entity.WorkoutReport;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@Builder
public class WorkoutReportResponse {

    private Long reportId;
    private Long sessionId;
    private String sessionName;
    private LocalDate reportDate;
    private Integer totalTimeSec;
    private BigDecimal totalVolumeKg;
    private BigDecimal totalCalories;
    private BigDecimal weeklyChangePct;
    private String motivationMsg;
    private LocalDateTime sharedAt;
    private LocalDateTime createdAt;

    public static WorkoutReportResponse from(WorkoutReport report) {
        return WorkoutReportResponse.builder()
                .reportId(report.getReportId())
                .sessionId(report.getSession().getSessionId())
                .sessionName(report.getSession().getSessionName())
                .reportDate(report.getReportDate())
                .totalTimeSec(report.getTotalTimeSec())
                .totalVolumeKg(report.getTotalVolumeKg())
                .totalCalories(report.getTotalCalories())
                .weeklyChangePct(report.getWeeklyChangePct())
                .motivationMsg(report.getMotivationMsg())
                .sharedAt(report.getSharedAt())
                .createdAt(report.getCreatedAt())
                .build();
    }
}
