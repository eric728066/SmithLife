package com.smithlife.backend.dto.response;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class AttendanceRateResponse {

    private int totalDays;
    private int attendedDays;
    private double attendanceRate;
}
