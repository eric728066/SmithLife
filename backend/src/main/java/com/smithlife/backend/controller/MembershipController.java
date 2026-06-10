package com.smithlife.backend.controller;

import com.smithlife.backend.common.ApiResponse;
import com.smithlife.backend.dto.response.MembershipResponse;
import com.smithlife.backend.security.SecurityUtil;
import com.smithlife.backend.service.MembershipService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/membership")
@RequiredArgsConstructor
public class MembershipController {

    private final MembershipService membershipService;

    // 활성 회원권 조회
    @GetMapping("/active")
    public ResponseEntity<ApiResponse<MembershipResponse>> getActiveMembership() {
        Long userId = SecurityUtil.getCurrentUserId();
        return ResponseEntity.ok(ApiResponse.ok(membershipService.getActiveMembership(userId)));
    }

    // 회원권 전체 내역 조회
    @GetMapping("/history")
    public ResponseEntity<ApiResponse<List<MembershipResponse>>> getMembershipHistory() {
        Long userId = SecurityUtil.getCurrentUserId();
        return ResponseEntity.ok(ApiResponse.ok(membershipService.getMembershipHistory(userId)));
    }

    // 남은 일수 조회
    @GetMapping("/remaining-days")
    public ResponseEntity<ApiResponse<Map<String, Long>>> getRemainingDays() {
        Long userId = SecurityUtil.getCurrentUserId();
        long days = membershipService.getRemainingDays(userId);
        return ResponseEntity.ok(ApiResponse.ok(Map.of("remainingDays", days)));
    }
}
