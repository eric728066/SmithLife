package com.smithlife.backend.dto.request;

import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Getter
@NoArgsConstructor
public class AdminMembershipRequest {
    private String type;
    private LocalDate startDate;
    private LocalDate endDate;
}
