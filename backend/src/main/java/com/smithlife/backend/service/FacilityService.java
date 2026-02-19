package com.smithlife.backend.service;

import com.smithlife.backend.dto.response.FacilityCongestionResponse;
import com.smithlife.backend.dto.response.TimeSlotResponse;
import com.smithlife.backend.entity.Facility;
import com.smithlife.backend.entity.TimeSlot;
import com.smithlife.backend.repository.FacilityRepository;
import com.smithlife.backend.repository.TimeSlotRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FacilityService {

    private final FacilityRepository facilityRepository;
    private final TimeSlotRepository timeSlotRepository;

    /**
     * 날짜별 시간 슬롯 목록 조회
     */
    @Transactional(readOnly = true)
    public List<TimeSlotResponse> getTimeSlotsByDate(LocalDate date) {
        return timeSlotRepository.findByDateOrderByStartTimeAsc(date)
                .stream()
                .map(TimeSlotResponse::from)
                .collect(Collectors.toList());
    }

    /**
     * 시설별 현재 혼잡도 조회
     */
    @Transactional(readOnly = true)
    public List<FacilityCongestionResponse> getFacilityCongestion() {
        List<Facility> facilities = facilityRepository.findByIsActiveTrue();
        LocalDate today = LocalDate.now();
        LocalTime now = LocalTime.now();

        return facilities.stream()
                .map(facility -> {
                    Optional<TimeSlot> currentSlot = timeSlotRepository
                            .findByFacilityFacilityIdAndDateAndStartTimeLessThanEqualAndEndTimeGreaterThan(
                                    facility.getFacilityId(), today, now, now);

                    int currentCount = currentSlot.map(TimeSlot::getCurrentCount).orElse(0);
                    int maxCapacity = facility.getMaxCapacity();

                    return FacilityCongestionResponse.of(
                            facility.getFacilityId(),
                            facility.getName(),
                            maxCapacity,
                            currentCount
                    );
                })
                .collect(Collectors.toList());
    }
}
