package com.smithlife.backend.controller;

import com.smithlife.backend.common.ApiResponse;
import com.smithlife.backend.dto.response.QrResponse;
import com.smithlife.backend.security.SecurityUtil;
import com.smithlife.backend.service.QrService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/qr")
@RequiredArgsConstructor
public class QrController {

    private final QrService qrService;

    // QR 코드 생성
    @GetMapping("/generate")
    public ResponseEntity<ApiResponse<QrResponse>> generateQr() {
        Long userId = SecurityUtil.getCurrentUserId();
        return ResponseEntity.ok(ApiResponse.ok(qrService.generateQr(userId)));
    }

    // QR 코드 갱신
    @GetMapping("/refresh")
    public ResponseEntity<ApiResponse<QrResponse>> refreshQr() {
        Long userId = SecurityUtil.getCurrentUserId();
        return ResponseEntity.ok(ApiResponse.ok(qrService.refreshQr(userId)));
    }
}
