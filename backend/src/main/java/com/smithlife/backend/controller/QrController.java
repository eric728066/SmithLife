package com.smithlife.backend.controller;

import com.smithlife.backend.common.ApiResponse;
import com.smithlife.backend.dto.response.QrResponse;
import com.smithlife.backend.security.SecurityUtil;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/qr")
@RequiredArgsConstructor
@Tag(name = "QR", description = "QR 코드 API")
public class QrController {

    @PostMapping("/generate")
    @Operation(summary = "QR 코드 생성", description = "현재 사용자의 입장용 QR 코드 내용 생성")
    public ResponseEntity<ApiResponse<QrResponse>> generateQr() {
        Long userId = SecurityUtil.getCurrentUserId();
        long expiresAt = System.currentTimeMillis() + (5 * 60 * 1000); // 5분 유효
        String qrContent = "SMITHLIFE:" + userId + ":" + expiresAt;

        QrResponse response = QrResponse.builder()
                .qrContent(qrContent)
                .userId(userId)
                .expiresAt(expiresAt)
                .build();

        return ResponseEntity.ok(ApiResponse.ok(response));
    }
}
