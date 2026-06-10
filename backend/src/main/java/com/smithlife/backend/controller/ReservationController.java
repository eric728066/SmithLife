package com.smithlife.backend.controller;

import com.smithlife.backend.common.ApiResponse;
import com.smithlife.backend.dto.request.ReservationRequest;
import com.smithlife.backend.dto.response.ReservationResponse;
import com.smithlife.backend.dto.response.TimeSlotResponse;
import com.smithlife.backend.security.SecurityUtil;
import com.smithlife.backend.service.ReservationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
@Tag(name = "Reservation", description = "예약 API")
public class ReservationController {

    private final ReservationService reservationService;

    @GetMapping("/timeslots")
    @Operation(summary = "타임슬롯 조회", description = "날짜별 타임슬롯 목록 조회 (09:00-22:00)")
    public ResponseEntity<ApiResponse<List<TimeSlotResponse>>> getTimeSlots(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        if (date == null) {
            date = LocalDate.now();
        }
        Long userId = SecurityUtil.getCurrentUserId();
        List<TimeSlotResponse> slots = reservationService.getTimeSlots(date, userId);
        return ResponseEntity.ok(ApiResponse.ok(slots));
    }

    @GetMapping("/timeslots/{slotId}/reservations")
    @Operation(summary = "슬롯 예약자 목록", description = "특정 슬롯의 예약자 목록 조회")
    public ResponseEntity<ApiResponse<List<ReservationResponse>>> getSlotReservations(
            @PathVariable Long slotId) {
        List<ReservationResponse> reservations = reservationService.getSlotReservations(slotId);
        return ResponseEntity.ok(ApiResponse.ok(reservations));
    }

    @PostMapping("/reservations")
    @Operation(summary = "예약 생성", description = "타임슬롯 예약")
    public ResponseEntity<ApiResponse<ReservationResponse>> createReservation(
            @Valid @RequestBody ReservationRequest request) {
        Long userId = SecurityUtil.getCurrentUserId();
        ReservationResponse response = reservationService.createReservation(userId, request);
        return ResponseEntity.ok(ApiResponse.ok("예약이 완료되었습니다.", response));
    }

    @DeleteMapping("/reservations/{reservationId}")
    @Operation(summary = "예약 취소", description = "예약 취소")
    public ResponseEntity<ApiResponse<Void>> cancelReservation(
            @PathVariable Long reservationId) {
        Long userId = SecurityUtil.getCurrentUserId();
        reservationService.cancelReservation(userId, reservationId);
        return ResponseEntity.ok(ApiResponse.ok("예약이 취소되었습니다."));
    }

    @GetMapping("/reservations/my")
    @Operation(summary = "내 예약 목록", description = "현재 유저의 예약 목록 조회")
    public ResponseEntity<ApiResponse<List<ReservationResponse>>> getMyReservations() {
        Long userId = SecurityUtil.getCurrentUserId();
        List<ReservationResponse> reservations = reservationService.getMyReservations(userId);
        return ResponseEntity.ok(ApiResponse.ok(reservations));
    }

    @GetMapping("/reservations/next")
    @Operation(summary = "다음 예약", description = "현재 유저의 다음 예약 조회")
    public ResponseEntity<ApiResponse<ReservationResponse>> getNextReservation() {
        Long userId = SecurityUtil.getCurrentUserId();
        ReservationResponse next = reservationService.getNextReservation(userId);
        return ResponseEntity.ok(ApiResponse.ok(next));
    }

    @GetMapping("/reservations/history")
    @Operation(summary = "내 예약 이력", description = "현재 유저의 전체 예약 이력 조회 (모든 상태)")
    public ResponseEntity<ApiResponse<List<ReservationResponse>>> getAllMyReservations() {
        Long userId = SecurityUtil.getCurrentUserId();
        List<ReservationResponse> reservations = reservationService.getAllMyReservations(userId);
        return ResponseEntity.ok(ApiResponse.ok(reservations));
    }
}
