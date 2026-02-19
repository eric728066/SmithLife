package com.smithlife.backend.service;

import com.smithlife.backend.common.ErrorCode;
import com.smithlife.backend.dto.response.NotificationResponse;
import com.smithlife.backend.entity.Notification;
import com.smithlife.backend.exception.CustomException;
import com.smithlife.backend.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository notificationRepository;

    /**
     * 알림 목록 조회
     */
    @Transactional(readOnly = true)
    public List<NotificationResponse> getNotifications(Long userId) {
        return notificationRepository.findByUserUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(NotificationResponse::from)
                .collect(Collectors.toList());
    }

    /**
     * 읽지 않은 알림 수 조회
     */
    @Transactional(readOnly = true)
    public Map<String, Long> getUnreadCount(Long userId) {
        long count = notificationRepository.countByUserUserIdAndIsReadFalse(userId);
        return Map.of("unreadCount", count);
    }

    /**
     * 알림 단건 읽음 처리
     */
    @Transactional
    public void markAsRead(Long userId, Long notificationId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new CustomException(ErrorCode.RESOURCE_NOT_FOUND));

        if (!notification.getUser().getUserId().equals(userId)) {
            throw new CustomException(ErrorCode.FORBIDDEN);
        }

        Notification updated = Notification.builder()
                .notificationId(notification.getNotificationId())
                .user(notification.getUser())
                .type(notification.getType())
                .title(notification.getTitle())
                .message(notification.getMessage())
                .subMessage(notification.getSubMessage())
                .isRead(true)
                .relatedUrl(notification.getRelatedUrl())
                .build();

        notificationRepository.save(updated);
    }

    /**
     * 전체 읽음 처리
     */
    @Transactional
    public void markAllAsRead(Long userId) {
        notificationRepository.markAllAsRead(userId);
    }
}
