package com.smithlife.backend.controller;

import com.smithlife.backend.common.ApiResponse;
import com.smithlife.backend.common.ErrorCode;
import com.smithlife.backend.dto.request.AdminMembershipRequest;
import com.smithlife.backend.dto.response.AdminMemberResponse;
import com.smithlife.backend.entity.Membership;
import com.smithlife.backend.entity.User;
import com.smithlife.backend.exception.CustomException;
import com.smithlife.backend.repository.MembershipRepository;
import com.smithlife.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class AdminController {

    private final UserRepository userRepository;
    private final MembershipRepository membershipRepository;

    // 전체 회원 목록 (USER role만)
    @GetMapping("/members")
    public ResponseEntity<ApiResponse<List<AdminMemberResponse>>> getMembers() {
        List<AdminMemberResponse> responses = userRepository.findAll().stream()
                .filter(u -> u.getRole() == User.Role.USER)
                .map(user -> {
                    Membership active = membershipRepository
                            .findTopByUserUserIdAndStatusOrderByEndDateDesc(user.getUserId(), Membership.Status.ACTIVE)
                            .orElse(null);
                    return AdminMemberResponse.fromList(user, active);
                })
                .collect(Collectors.toList());

        return ResponseEntity.ok(ApiResponse.ok(responses));
    }

    // 회원 상세 + 회원권 이력
    @GetMapping("/members/{userId}")
    public ResponseEntity<ApiResponse<AdminMemberResponse>> getMemberDetail(@PathVariable Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        Membership active = membershipRepository
                .findTopByUserUserIdAndStatusOrderByEndDateDesc(userId, Membership.Status.ACTIVE)
                .orElse(null);
        List<Membership> history = membershipRepository.findAllByUserUserIdOrderByCreatedAtDesc(userId);

        return ResponseEntity.ok(ApiResponse.ok(AdminMemberResponse.fromDetail(user, active, history)));
    }

    // 회원권 등록
    @PostMapping("/members/{userId}/membership")
    public ResponseEntity<ApiResponse<Void>> registerMembership(
            @PathVariable Long userId,
            @RequestBody AdminMembershipRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        Membership membership = Membership.builder()
                .user(user)
                .type(request.getType())
                .startDate(request.getStartDate())
                .endDate(request.getEndDate())
                .status(Membership.Status.ACTIVE)
                .build();

        membershipRepository.save(membership);
        return ResponseEntity.ok(ApiResponse.ok(null));
    }
}
