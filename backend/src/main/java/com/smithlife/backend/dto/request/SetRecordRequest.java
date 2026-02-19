package com.smithlife.backend.dto.request;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Getter
@NoArgsConstructor
public class SetRecordRequest {

    @NotNull(message = "세트 번호는 필수입니다")
    @Min(value = 1, message = "세트 번호는 1 이상이어야 합니다")
    private Integer setNumber;

    private BigDecimal weightKg; // null 허용 (맨몸 운동)

    @Min(value = 0, message = "반복 수는 0 이상이어야 합니다")
    private Integer reps;

    private Integer restTimeSec;

    @NotNull(message = "완료 여부는 필수입니다")
    private Boolean isCompleted;
}
