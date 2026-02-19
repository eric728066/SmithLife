package com.smithlife.backend.dto.response;

import com.smithlife.backend.entity.Reservation;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Getter
@Builder
public class ReservationResponse {

    private Long reservationId;
    private String reservationNo;
    private String status;
    private Long facilityId;
    private String facilityName;
    private LocalDate date;
    private LocalTime startTime;
    private LocalTime endTime;
    private LocalDateTime reservedAt;
    private LocalDateTime cancelledAt;

    public static ReservationResponse from(Reservation reservation) {
        return ReservationResponse.builder()
                .reservationId(reservation.getReservationId())
                .reservationNo(reservation.getReservationNo())
                .status(reservation.getStatus().name())
                .facilityId(reservation.getSlot().getFacility().getFacilityId())
                .facilityName(reservation.getSlot().getFacility().getName())
                .date(reservation.getSlot().getDate())
                .startTime(reservation.getSlot().getStartTime())
                .endTime(reservation.getSlot().getEndTime())
                .reservedAt(reservation.getReservedAt())
                .cancelledAt(reservation.getCancelledAt())
                .build();
    }
}
