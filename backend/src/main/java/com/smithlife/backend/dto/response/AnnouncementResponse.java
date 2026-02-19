package com.smithlife.backend.dto.response;

import com.smithlife.backend.entity.Announcement;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class AnnouncementResponse {

    private Long announcementId;
    private String title;
    private String content;
    private String tag; // NOTICE, EVENT
    private String imageUrl;
    private Boolean isNew;
    private LocalDateTime publishedAt;

    public static AnnouncementResponse from(Announcement announcement) {
        return AnnouncementResponse.builder()
                .announcementId(announcement.getAnnouncementId())
                .title(announcement.getTitle())
                .content(announcement.getContent())
                .tag(announcement.getTag().name())
                .imageUrl(announcement.getImageUrl())
                .isNew(announcement.getIsNew())
                .publishedAt(announcement.getPublishedAt())
                .build();
    }
}
