package com.smithlife.backend.service;

import com.smithlife.backend.dto.response.QrResponse;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
public class QrService {

    private static final int QR_EXPIRY_SECONDS = 60; // QR 유효시간 60초

    // QR 토큰 생성
    public QrResponse generateQr(Long userId) {
        String qrToken = buildQrToken(userId);
        LocalDateTime expiresAt = LocalDateTime.now().plusSeconds(QR_EXPIRY_SECONDS);

        return QrResponse.builder()
                .qrToken(qrToken)
                .expiresAt(expiresAt)
                .remainingSeconds(QR_EXPIRY_SECONDS)
                .build();
    }

    // QR 토큰 갱신
    public QrResponse refreshQr(Long userId) {
        return generateQr(userId);
    }

    // QR 토큰 유효성 검증
    public boolean validateQrToken(String qrToken) {
        try {
            String[] parts = qrToken.split("_");
            if (parts.length != 3) return false;

            long issuedAt = Long.parseLong(parts[2]);
            long now = System.currentTimeMillis();
            long elapsed = (now - issuedAt) / 1000;

            return elapsed <= QR_EXPIRY_SECONDS;
        } catch (Exception e) {
            return false;
        }
    }

    // QR 토큰에서 userId 추출
    public Long extractUserId(String qrToken) {
        String[] parts = qrToken.split("_");
        return Long.parseLong(parts[1]);
    }

    private String buildQrToken(Long userId) {
        String uuid = UUID.randomUUID().toString().replace("-", "").substring(0, 8);
        long timestamp = System.currentTimeMillis();
        return uuid + "_" + userId + "_" + timestamp;
    }
}
