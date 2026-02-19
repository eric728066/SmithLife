package com.smithlife.backend.controller;

import com.smithlife.backend.common.ApiResponse;
import com.smithlife.backend.dto.request.InquiryCreateRequest;
import com.smithlife.backend.dto.response.InquiryResponse;
import com.smithlife.backend.security.SecurityUtil;
import com.smithlife.backend.service.InquiryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/inquiries")
@RequiredArgsConstructor
@Tag(name = "Inquiry", description = "문의 API")
public class InquiryController {

    private final InquiryService inquiryService;

    @Operation(summary = "문의 등록")
    @PostMapping
    public ResponseEntity<ApiResponse<InquiryResponse>> createInquiry(
            @Valid @RequestBody InquiryCreateRequest request) {
        Long userId = SecurityUtil.getCurrentUserId();
        InquiryResponse response = inquiryService.createInquiry(userId, request);
        return ResponseEntity.ok(ApiResponse.ok("문의가 등록되었습니다.", response));
    }

    @Operation(summary = "내 문의 목록 조회")
    @GetMapping("/my")
    public ResponseEntity<ApiResponse<List<InquiryResponse>>> getMyInquiries() {
        Long userId = SecurityUtil.getCurrentUserId();
        List<InquiryResponse> response = inquiryService.getMyInquiries(userId);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @Operation(summary = "문의 상세 조회 (답변 포함)")
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<InquiryResponse>> getInquiryDetail(@PathVariable Long id) {
        Long userId = SecurityUtil.getCurrentUserId();
        InquiryResponse response = inquiryService.getInquiryDetail(userId, id);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }
}
