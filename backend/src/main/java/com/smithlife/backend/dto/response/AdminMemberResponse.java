package com.smithlife.backend.dto.response;

import com.smithlife.backend.entity.Membership;
import com.smithlife.backend.entity.User;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Getter
@Builder
public class AdminMemberResponse {

    private Long userId;
    private String email;
    private String name;
    private String phone;
    private String role;
    private Boolean isActive;
    private LocalDateTime createdAt;
    private MembershipResponse activeMembership;
    private List<MembershipResponse> membershipHistory;

    public static AdminMemberResponse fromList(User user, Membership activeMembership) {
        return AdminMemberResponse.builder()
                .userId(user.getUserId())
                .email(user.getEmail())
                .name(user.getName())
                .phone(user.getPhone())
                .role(user.getRole().name())
                .isActive(user.getIsActive())
                .createdAt(user.getCreatedAt())
                .activeMembership(activeMembership != null ? MembershipResponse.from(activeMembership) : null)
                .build();
    }

    public static AdminMemberResponse fromDetail(User user, Membership activeMembership, List<Membership> history) {
        return AdminMemberResponse.builder()
                .userId(user.getUserId())
                .email(user.getEmail())
                .name(user.getName())
                .phone(user.getPhone())
                .role(user.getRole().name())
                .isActive(user.getIsActive())
                .createdAt(user.getCreatedAt())
                .activeMembership(activeMembership != null ? MembershipResponse.from(activeMembership) : null)
                .membershipHistory(history.stream().map(MembershipResponse::from).collect(Collectors.toList()))
                .build();
    }
}
