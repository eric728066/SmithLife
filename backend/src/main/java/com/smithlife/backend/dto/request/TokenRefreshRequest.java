package com.smithlife.backend.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;

@Getter
public class TokenRefreshRequest {

    @NotBlank(message = "Refresh 토큰을 입력해주세요.")
    private String refreshToken;
}
