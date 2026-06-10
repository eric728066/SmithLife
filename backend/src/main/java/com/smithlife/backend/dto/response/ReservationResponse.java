package com.smithlife.backend.dto.response;

import com.smithlife.backend.entity.Reservation;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class ReservationResponse {

    private Long reservationId;
    private String reservationNo;
    private String status;
    private LocalDateTime reservedAt;
    private LocalDateTime cancelledAt;
    private TimeSlotResponse slot;
    private String userName;

    public static ReservationResponse from(Reservation reservation, TimeSlotResponse slotResponse) {
        return ReservationResponse.builder()
                .reservationId(reservation.getReservationId())
                .reservationNo(reservation.getReservationNo())
                .status(reservation.getStatus().name())
                .reservedAt(reservation.getReservedAt())
                .cancelledAt(reservation.getCancelledAt())
                .slot(slotResponse)
                .userName(reservation.getUser().getName())
                .build();
    }
}
