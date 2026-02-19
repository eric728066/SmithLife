package com.smithlife.backend.service;

import com.smithlife.backend.common.ErrorCode;
import com.smithlife.backend.dto.response.MembershipResponse;
import com.smithlife.backend.entity.Membership;
import com.smithlife.backend.exception.CustomException;
import com.smithlife.backend.repository.MembershipRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MembershipService {

    private final MembershipRepository membershipRepository;

    // 활성 회원권 조회
    @Transactional(readOnly = true)
    public MembershipResponse getActiveMembership(Long userId) {
        Membership membership = membershipRepository
                .findTopByUserUserIdAndStatusOrderByEndDateDesc(userId, Membership.Status.ACTIVE)
                .orElseThrow(() -> new CustomException(ErrorCode.RESOURCE_NOT_FOUND));
        return MembershipResponse.from(membership);
    }

    // 회원권 전체 내역 조회
    @Transactional(readOnly = true)
    public List<MembershipResponse> getMembershipHistory(Long userId) {
        return membershipRepository.findAllByUserUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(MembershipResponse::from)
                .collect(Collectors.toList());
    }

    // 남은 일수 조회
    @Transactional(readOnly = true)
    public long getRemainingDays(Long userId) {
        Membership membership = membershipRepository
                .findTopByUserUserIdAndStatusOrderByEndDateDesc(userId, Membership.Status.ACTIVE)
                .orElseThrow(() -> new CustomException(ErrorCode.RESOURCE_NOT_FOUND));
        return MembershipResponse.from(membership).getRemainingDays();
    }
}
