package com.smithlife.backend.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class ReservationRequest {

    @NotNull(message = "슬롯 ID는 필수입니다")
    private Long slotId;
}
