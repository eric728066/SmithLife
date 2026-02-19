package com.smithlife.backend.dto.response;

import com.smithlife.backend.entity.Notification;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class NotificationResponse {

    private Long notificationId;
    private String type; // RESERVATION, MEMBERSHIP, WORKOUT, SYSTEM
    private String title;
    private String message;
    private String subMessage;
    private Boolean isRead;
    private String relatedUrl;
    private LocalDateTime createdAt;

    public static NotificationResponse from(Notification notification) {
        return NotificationResponse.builder()
                .notificationId(notification.getNotificationId())
                .type(notification.getType().name())
                .title(notification.getTitle())
                .message(notification.getMessage())
                .subMessage(notification.getSubMessage())
                .isRead(notification.getIsRead())
                .relatedUrl(notification.getRelatedUrl())
                .createdAt(notification.getCreatedAt())
                .build();
    }
}
