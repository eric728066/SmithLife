package com.smithlife.backend.controller;

import com.smithlife.backend.common.ApiResponse;
import com.smithlife.backend.dto.response.NotificationResponse;
import com.smithlife.backend.security.SecurityUtil;
import com.smithlife.backend.service.NotificationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
@Tag(name = "Notification", description = "알림 API")
public class NotificationController {

    private final NotificationService notificationService;

    @Operation(summary = "알림 목록 조회")
    @GetMapping
    public ResponseEntity<ApiResponse<List<NotificationResponse>>> getNotifications() {
        Long userId = SecurityUtil.getCurrentUserId();
        List<NotificationResponse> response = notificationService.getNotifications(userId);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @Operation(summary = "읽지 않은 알림 수 조회")
    @GetMapping("/unread-count")
    public ResponseEntity<ApiResponse<Map<String, Long>>> getUnreadCount() {
        Long userId = SecurityUtil.getCurrentUserId();
        Map<String, Long> response = notificationService.getUnreadCount(userId);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @Operation(summary = "알림 단건 읽음 처리")
    @PatchMapping("/{id}/read")
    public ResponseEntity<ApiResponse<Void>> markAsRead(@PathVariable Long id) {
        Long userId = SecurityUtil.getCurrentUserId();
        notificationService.markAsRead(userId, id);
        return ResponseEntity.ok(ApiResponse.ok("읽음 처리되었습니다."));
    }

    @Operation(summary = "전체 알림 읽음 처리")
    @PatchMapping("/read-all")
    public ResponseEntity<ApiResponse<Void>> markAllAsRead() {
        Long userId = SecurityUtil.getCurrentUserId();
        notificationService.markAllAsRead(userId);
        return ResponseEntity.ok(ApiResponse.ok("전체 읽음 처리되었습니다."));
    }
}
