package com.smithlife.backend.dto.response;

import com.smithlife.backend.entity.TimeSlot;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDate;
import java.time.LocalTime;

@Getter
@Builder
public class TimeSlotResponse {

    private Long slotId;
    private Long facilityId;
    private String facilityName;
    private LocalDate date;
    private LocalTime startTime;
    private LocalTime endTime;
    private Integer maxCapacity;
    private Integer currentCount;
    private Integer remainingCapacity;
    private String congestionLevel; // LOW, MEDIUM, HIGH, FULL
    private Integer congestionPercent;
    private Boolean isAvailable;

    public static TimeSlotResponse from(TimeSlot slot) {
        int max = slot.getMaxCapacity();
        int current = slot.getCurrentCount();
        int percent = max > 0 ? (current * 100 / max) : 0;

        String level;
        if (current >= max) level = "FULL";
        else if (percent >= 70) level = "HIGH";
        else if (percent >= 30) level = "MEDIUM";
        else level = "LOW";

        return TimeSlotResponse.builder()
                .slotId(slot.getSlotId())
                .facilityId(slot.getFacility().getFacilityId())
                .facilityName(slot.getFacility().getName())
                .date(slot.getDate())
                .startTime(slot.getStartTime())
                .endTime(slot.getEndTime())
                .maxCapacity(max)
                .currentCount(current)
                .remainingCapacity(max - current)
                .congestionLevel(level)
                .congestionPercent(percent)
                .isAvailable(current < max)
                .build();
    }
}
