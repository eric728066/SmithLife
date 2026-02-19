package com.smithlife.backend.controller;

import com.smithlife.backend.common.ApiResponse;
import com.smithlife.backend.dto.request.ReservationRequest;
import com.smithlife.backend.dto.response.ReservationResponse;
import com.smithlife.backend.security.SecurityUtil;
import com.smithlife.backend.service.ReservationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/reservations")
@RequiredArgsConstructor
@Tag(name = "Reservation", description = "예약 API")
public class ReservationController {

    private final ReservationService reservationService;

    @Operation(summary = "예약 생성")
    @PostMapping
    public ResponseEntity<ApiResponse<ReservationResponse>> createReservation(
            @Valid @RequestBody ReservationRequest request) {
        Long userId = SecurityUtil.getCurrentUserId();
        ReservationResponse response = reservationService.createReservation(userId, request);
        return ResponseEntity.ok(ApiResponse.ok("예약이 완료되었습니다.", response));
    }

    @Operation(summary = "예약 취소")
    @PostMapping("/{id}/cancel")
    public ResponseEntity<ApiResponse<Void>> cancelReservation(@PathVariable Long id) {
        Long userId = SecurityUtil.getCurrentUserId();
        reservationService.cancelReservation(userId, id);
        return ResponseEntity.ok(ApiResponse.ok("예약이 취소되었습니다."));
    }

    @Operation(summary = "내 예약 목록 조회")
    @GetMapping("/my")
    public ResponseEntity<ApiResponse<List<ReservationResponse>>> getMyReservations() {
        Long userId = SecurityUtil.getCurrentUserId();
        List<ReservationResponse> response = reservationService.getMyReservations(userId);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @Operation(summary = "다음 예약 조회 (홈 화면)")
    @GetMapping("/next")
    public ResponseEntity<ApiResponse<ReservationResponse>> getNextReservation() {
        Long userId = SecurityUtil.getCurrentUserId();
        ReservationResponse response = reservationService.getNextReservation(userId);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }
}
