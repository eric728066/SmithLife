package com.smithlife.backend.dto.response;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class QrResponse {

    private String qrToken;
    private LocalDateTime expiresAt;
    private int remainingSeconds;
}
