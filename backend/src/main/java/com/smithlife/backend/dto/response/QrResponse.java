package com.smithlife.backend.dto.response;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class QrResponse {

    private String qrContent;
    private Long userId;
    private long expiresAt;
}
