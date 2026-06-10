package com.smithlife.backend.controller;

import com.smithlife.backend.common.ApiResponse;
import com.smithlife.backend.dto.request.AnnouncementRequest;
import com.smithlife.backend.dto.response.AnnouncementResponse;
import com.smithlife.backend.service.AnnouncementService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class AnnouncementController {

    private final AnnouncementService announcementService;

    // 공개 - 전체 공지사항 조회
    @GetMapping("/api/announcements")
    public ResponseEntity<ApiResponse<List<AnnouncementResponse>>> getAll() {
        return ResponseEntity.ok(ApiResponse.ok(announcementService.getAll()));
    }

    // ADMIN 전용 - 공지사항 생성
    @PostMapping("/api/admin/announcements")
    public ResponseEntity<ApiResponse<AnnouncementResponse>> create(@RequestBody AnnouncementRequest request) {
        return ResponseEntity.ok(ApiResponse.ok(announcementService.create(request)));
    }

    // ADMIN 전용 - 공지사항 수정
    @PutMapping("/api/admin/announcements/{id}")
    public ResponseEntity<ApiResponse<AnnouncementResponse>> update(
            @PathVariable Long id,
            @RequestBody AnnouncementRequest request) {
        return ResponseEntity.ok(ApiResponse.ok(announcementService.update(id, request)));
    }

    // ADMIN 전용 - 공지사항 삭제
    @DeleteMapping("/api/admin/announcements/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable Long id) {
        announcementService.delete(id);
        return ResponseEntity.ok(ApiResponse.ok(null));
    }
}
