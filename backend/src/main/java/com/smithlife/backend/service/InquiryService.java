package com.smithlife.backend.service;

import com.smithlife.backend.common.ErrorCode;
import com.smithlife.backend.dto.request.InquiryCreateRequest;
import com.smithlife.backend.dto.response.InquiryResponse;
import com.smithlife.backend.entity.Inquiry;
import com.smithlife.backend.entity.User;
import com.smithlife.backend.exception.CustomException;
import com.smithlife.backend.repository.InquiryRepository;
import com.smithlife.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class InquiryService {

    private final InquiryRepository inquiryRepository;
    private final UserRepository userRepository;

    /**
     * 문의 등록
     */
    @Transactional
    public InquiryResponse createInquiry(Long userId, InquiryCreateRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        Inquiry inquiry = Inquiry.builder()
                .user(user)
                .category(request.getCategory())
                .title(request.getTitle())
                .content(request.getContent())
                .imageUrl(request.getImageUrl())
                .status(Inquiry.Status.RECEIVED)
                .build();

        Inquiry saved = inquiryRepository.save(inquiry);
        return InquiryResponse.from(saved);
    }

    /**
     * 내 문의 목록 조회
     */
    @Transactional(readOnly = true)
    public List<InquiryResponse> getMyInquiries(Long userId) {
        return inquiryRepository.findByUserUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(InquiryResponse::from)
                .collect(Collectors.toList());
    }

    /**
     * 문의 상세 조회 (답변 포함)
     */
    @Transactional(readOnly = true)
    public InquiryResponse getInquiryDetail(Long userId, Long inquiryId) {
        Inquiry inquiry = inquiryRepository.findByIdWithReplies(inquiryId)
                .orElseThrow(() -> new CustomException(ErrorCode.RESOURCE_NOT_FOUND));

        if (!inquiry.getUser().getUserId().equals(userId)) {
            throw new CustomException(ErrorCode.FORBIDDEN);
        }

        return InquiryResponse.from(inquiry);
    }
}
