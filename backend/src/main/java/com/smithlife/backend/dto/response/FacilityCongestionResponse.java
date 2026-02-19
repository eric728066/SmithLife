package com.smithlife.backend.dto.response;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class FacilityCongestionResponse {

    private Long facilityId;
    private String facilityName;
    private Integer maxCapacity;
    private Integer currentCount;
    private String congestionLevel; // LOW, MEDIUM, HIGH, FULL
    private Integer congestionPercent;

    public static FacilityCongestionResponse of(Long facilityId, String facilityName,
                                                int maxCapacity, int currentCount) {
        int percent = maxCapacity > 0 ? (currentCount * 100 / maxCapacity) : 0;

        String level;
        if (currentCount >= maxCapacity) level = "FULL";
        else if (percent >= 70) level = "HIGH";
        else if (percent >= 30) level = "MEDIUM";
        else level = "LOW";

        return FacilityCongestionResponse.builder()
                .facilityId(facilityId)
                .facilityName(facilityName)
                .maxCapacity(maxCapacity)
                .currentCount(currentCount)
                .congestionLevel(level)
                .congestionPercent(percent)
                .build();
    }
}
