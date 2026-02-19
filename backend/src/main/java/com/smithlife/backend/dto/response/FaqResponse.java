package com.smithlife.backend.dto.response;

import com.smithlife.backend.entity.Faq;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class FaqResponse {

    private Long faqId;
    private String category;
    private String question;
    private String answer;
    private Integer orderIndex;

    public static FaqResponse from(Faq faq) {
        return FaqResponse.builder()
                .faqId(faq.getFaqId())
                .category(faq.getCategory())
                .question(faq.getQuestion())
                .answer(faq.getAnswer())
                .orderIndex(faq.getOrderIndex())
                .build();
    }
}
