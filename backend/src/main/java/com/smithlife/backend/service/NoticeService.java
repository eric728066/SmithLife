package com.smithlife.backend.service;

import com.smithlife.backend.common.ErrorCode;
import com.smithlife.backend.dto.response.AnnouncementResponse;
import com.smithlife.backend.dto.response.FaqResponse;
import com.smithlife.backend.entity.Announcement;
import com.smithlife.backend.exception.CustomException;
import com.smithlife.backend.repository.AnnouncementRepository;
import com.smithlife.backend.repository.FaqRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class NoticeService {

    private final AnnouncementRepository announcementRepository;
    private final FaqRepository faqRepository;

    /**
     * 공지 목록 조회 (태그 필터 가능: NOTICE, EVENT)
     */
    @Transactional(readOnly = true)
    public List<AnnouncementResponse> getAnnouncements(String tag) {
        if (tag != null && !tag.isBlank()) {
            Announcement.Tag tagEnum = Announcement.Tag.valueOf(tag.toUpperCase());
            return announcementRepository.findByIsActiveTrueAndTagOrderByPublishedAtDesc(tagEnum)
                    .stream().map(AnnouncementResponse::from).collect(Collectors.toList());
        }
        return announcementRepository.findByIsActiveTrueOrderByPublishedAtDesc()
                .stream().map(AnnouncementResponse::from).collect(Collectors.toList());
    }

    /**
     * 공지 상세 조회
     */
    @Transactional(readOnly = true)
    public AnnouncementResponse getAnnouncementDetail(Long announcementId) {
        return announcementRepository.findById(announcementId)
                .filter(a -> a.getIsActive())
                .map(AnnouncementResponse::from)
                .orElseThrow(() -> new CustomException(ErrorCode.RESOURCE_NOT_FOUND));
    }

    /**
     * FAQ 목록 조회 (카테고리 필터 가능)
     */
    @Transactional(readOnly = true)
    public List<FaqResponse> getFaqs(String category) {
        if (category != null && !category.isBlank()) {
            return faqRepository.findByIsActiveTrueAndCategoryOrderByOrderIndexAsc(category)
                    .stream().map(FaqResponse::from).collect(Collectors.toList());
        }
        return faqRepository.findByIsActiveTrueOrderByOrderIndexAsc()
                .stream().map(FaqResponse::from).collect(Collectors.toList());
    }
}
