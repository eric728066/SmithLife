package com.smithlife.backend.controller;

import com.smithlife.backend.common.ApiResponse;
import com.smithlife.backend.dto.response.FacilityCongestionResponse;
import com.smithlife.backend.dto.response.TimeSlotResponse;
import com.smithlife.backend.service.FacilityService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
@Tag(name = "Facility", description = "시설 API")
public class FacilityController {

    private final FacilityService facilityService;

    @Operation(summary = "날짜별 시간 슬롯 목록 조회", description = "date 파라미터가 없으면 오늘 날짜 기준으로 조회합니다.")
    @GetMapping("/timeslots")
    public ResponseEntity<ApiResponse<List<TimeSlotResponse>>> getTimeSlots(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        if (date == null) {
            date = LocalDate.now();
        }
        List<TimeSlotResponse> response = facilityService.getTimeSlotsByDate(date);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @Operation(summary = "시설 혼잡도 조회", description = "현재 시간 기준 각 시설의 혼잡도를 조회합니다.")
    @GetMapping("/facility/congestion")
    public ResponseEntity<ApiResponse<List<FacilityCongestionResponse>>> getFacilityCongestion() {
        List<FacilityCongestionResponse> response = facilityService.getFacilityCongestion();
        return ResponseEntity.ok(ApiResponse.ok(response));
    }
}
