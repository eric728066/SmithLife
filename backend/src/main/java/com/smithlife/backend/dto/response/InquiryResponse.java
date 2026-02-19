package com.smithlife.backend.dto.response;

import com.smithlife.backend.entity.Inquiry;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Getter
@Builder
public class InquiryResponse {

    private Long inquiryId;
    private String category;
    private String title;
    private String content;
    private String imageUrl;
    private String status; // RECEIVED, IN_PROGRESS, REPLIED
    private LocalDateTime createdAt;
    private List<InquiryReplyResponse> replies;

    public static InquiryResponse from(Inquiry inquiry) {
        List<InquiryReplyResponse> replies = inquiry.getReplies() != null
                ? inquiry.getReplies().stream()
                    .map(InquiryReplyResponse::from)
                    .collect(Collectors.toList())
                : List.of();

        return InquiryResponse.builder()
                .inquiryId(inquiry.getInquiryId())
                .category(inquiry.getCategory())
                .title(inquiry.getTitle())
                .content(inquiry.getContent())
                .imageUrl(inquiry.getImageUrl())
                .status(inquiry.getStatus().name())
                .createdAt(inquiry.getCreatedAt())
                .replies(replies)
                .build();
    }
}
