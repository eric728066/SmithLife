package com.smithlife.backend.controller;

import com.smithlife.backend.common.ApiResponse;
import com.smithlife.backend.dto.response.AnnouncementResponse;
import com.smithlife.backend.dto.response.FaqResponse;
import com.smithlife.backend.service.NoticeService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@Tag(name = "Notice", description = "공지/FAQ API")
public class NoticeController {

    private final NoticeService noticeService;

    @Operation(summary = "공지 목록 조회", description = "tag 파라미터: NOTICE(공지) / EVENT(이벤트). 없으면 전체 조회.")
    @GetMapping("/api/announcements")
    public ResponseEntity<ApiResponse<List<AnnouncementResponse>>> getAnnouncements(
            @RequestParam(required = false) String tag) {
        List<AnnouncementResponse> response = noticeService.getAnnouncements(tag);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @Operation(summary = "공지 상세 조회")
    @GetMapping("/api/announcements/{id}")
    public ResponseEntity<ApiResponse<AnnouncementResponse>> getAnnouncementDetail(@PathVariable Long id) {
        AnnouncementResponse response = noticeService.getAnnouncementDetail(id);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @Operation(summary = "FAQ 목록 조회", description = "category 파라미터로 필터링 가능. 없으면 전체 조회.")
    @GetMapping("/api/faq")
    public ResponseEntity<ApiResponse<List<FaqResponse>>> getFaqs(
            @RequestParam(required = false) String category) {
        List<FaqResponse> response = noticeService.getFaqs(category);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }
}
