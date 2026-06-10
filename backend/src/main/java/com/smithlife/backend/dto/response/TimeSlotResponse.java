package com.smithlife.backend.dto.response;

import com.smithlife.backend.entity.TimeSlot;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDate;
import java.time.LocalTime;

@Getter
@Builder
public class TimeSlotResponse {

    private Long slotId;
    private LocalDate date;

    @JsonFormat(pattern = "HH:mm")
    private LocalTime startTime;

    @JsonFormat(pattern = "HH:mm")
    private LocalTime endTime;

    private int maxCapacity;
    private int currentCount;
    private String congestionStatus; // SMOOTH, NORMAL, CROWDED
    private boolean myReservation;

    public static TimeSlotResponse from(TimeSlot slot, boolean myReservation) {
        double ratio = slot.getMaxCapacity() == 0 ? 0 :
                (double) slot.getCurrentCount() / slot.getMaxCapacity();

        String status;
        if (ratio >= 0.8) {
            status = "CROWDED";
        } else if (ratio >= 0.5) {
            status = "NORMAL";
        } else {
            status = "SMOOTH";
        }

        return TimeSlotResponse.builder()
                .slotId(slot.getSlotId())
                .date(slot.getDate())
                .startTime(slot.getStartTime())
                .endTime(slot.getEndTime())
                .maxCapacity(slot.getMaxCapacity())
                .currentCount(slot.getCurrentCount())
                .congestionStatus(status)
                .myReservation(myReservation)
                .build();
    }
}
