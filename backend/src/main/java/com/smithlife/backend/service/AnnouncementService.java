package com.smithlife.backend.service;

import com.smithlife.backend.common.ErrorCode;
import com.smithlife.backend.dto.request.AnnouncementRequest;
import com.smithlife.backend.dto.response.AnnouncementResponse;
import com.smithlife.backend.entity.Announcement;
import com.smithlife.backend.exception.CustomException;
import com.smithlife.backend.repository.AnnouncementRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AnnouncementService {

    private final AnnouncementRepository announcementRepository;

    // 공지사항 목록 조회 (활성만)
    @Transactional(readOnly = true)
    public List<AnnouncementResponse> getAll() {
        return announcementRepository.findByIsActiveTrueOrderByCreatedAtDesc()
                .stream()
                .map(AnnouncementResponse::from)
                .collect(Collectors.toList());
    }

    // 공지사항 생성 (ADMIN)
    @Transactional
    public AnnouncementResponse create(AnnouncementRequest request) {
        Announcement announcement = Announcement.builder()
                .title(request.getTitle())
                .content(request.getContent())
                .tag(request.getTag() != null ? request.getTag() : Announcement.Tag.NOTICE)
                .imageUrl(request.getImageUrl())
                .isNew(true)
                .publishedAt(LocalDateTime.now())
                .isActive(true)
                .build();
        return AnnouncementResponse.from(announcementRepository.save(announcement));
    }

    // 공지사항 수정 (ADMIN)
    @Transactional
    public AnnouncementResponse update(Long id, AnnouncementRequest request) {
        Announcement existing = announcementRepository.findById(id)
                .orElseThrow(() -> new CustomException(ErrorCode.RESOURCE_NOT_FOUND));
        existing.update(
                request.getTitle(),
                request.getContent(),
                request.getTag() != null ? request.getTag() : existing.getTag(),
                request.getImageUrl()
        );
        return AnnouncementResponse.from(announcementRepository.save(existing));
    }

    // 공지사항 삭제 - soft delete (ADMIN)
    @Transactional
    public void delete(Long id) {
        Announcement existing = announcementRepository.findById(id)
                .orElseThrow(() -> new CustomException(ErrorCode.RESOURCE_NOT_FOUND));
        existing.deactivate();
        announcementRepository.save(existing);
    }
}
