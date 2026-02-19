package com.smithlife.backend.dto.response;

import com.smithlife.backend.entity.InquiryReply;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class InquiryReplyResponse {

    private Long replyId;
    private String adminName;
    private String content;
    private LocalDateTime createdAt;

    public static InquiryReplyResponse from(InquiryReply reply) {
        return InquiryReplyResponse.builder()
                .replyId(reply.getReplyId())
                .adminName(reply.getAdminName())
                .content(reply.getContent())
                .createdAt(reply.getCreatedAt())
                .build();
    }
}
