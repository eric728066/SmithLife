package com.smithlife.backend.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class SessionStartRequest {

    @NotBlank(message = "세션 이름은 필수입니다")
    private String sessionName;

    private Long routineId; // 선택 (루틴 기반 세션일 경우)
}
