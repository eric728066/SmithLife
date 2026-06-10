package com.smithlife.backend.dto.request;

import com.smithlife.backend.entity.Announcement;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class AnnouncementRequest {
    private String title;
    private String content;
    private Announcement.Tag tag;
    private String imageUrl;
}
