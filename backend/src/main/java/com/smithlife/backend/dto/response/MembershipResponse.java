package com.smithlife.backend.dto.response;

import com.smithlife.backend.entity.Membership;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

@Getter
@Builder
public class MembershipResponse {

    private Long membershipId;
    private String type;
    private LocalDate startDate;
    private LocalDate endDate;
    private String status;
    private long remainingDays;

    public static MembershipResponse from(Membership membership) {
        long remaining = ChronoUnit.DAYS.between(LocalDate.now(), membership.getEndDate());
        return MembershipResponse.builder()
                .membershipId(membership.getMembershipId())
                .type(membership.getType())
                .startDate(membership.getStartDate())
                .endDate(membership.getEndDate())
                .status(membership.getStatus().name())
                .remainingDays(Math.max(remaining, 0))
                .build();
    }
}
