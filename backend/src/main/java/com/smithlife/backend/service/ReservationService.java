package com.smithlife.backend.service;

import com.smithlife.backend.common.ErrorCode;
import com.smithlife.backend.dto.request.ReservationRequest;
import com.smithlife.backend.dto.response.ReservationResponse;
import com.smithlife.backend.dto.response.TimeSlotResponse;
import com.smithlife.backend.entity.Facility;
import com.smithlife.backend.entity.Reservation;
import com.smithlife.backend.entity.TimeSlot;
import com.smithlife.backend.entity.User;
import com.smithlife.backend.exception.CustomException;
import com.smithlife.backend.repository.FacilityRepository;
import com.smithlife.backend.repository.ReservationRepository;
import com.smithlife.backend.repository.TimeSlotRepository;
import com.smithlife.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReservationService {

    private final TimeSlotRepository timeSlotRepository;
    private final ReservationRepository reservationRepository;
    private final UserRepository userRepository;
    private final FacilityRepository facilityRepository;

    private static final int SLOT_CAPACITY = 20;
    private static final int SLOT_START_HOUR = 9;
    private static final int SLOT_END_HOUR = 22;

    // 날짜별 타임슬롯 조회 (없으면 자동 생성)
    @Transactional
    public List<TimeSlotResponse> getTimeSlots(LocalDate date, Long userId) {
        Facility facility = facilityRepository.findFirstByIsActiveTrue()
                .orElseThrow(() -> new CustomException(ErrorCode.RESOURCE_NOT_FOUND));

        if (!timeSlotRepository.existsByDateAndFacilityFacilityId(date, facility.getFacilityId())) {
            createTimeSlotsForDate(date, facility);
        }

        List<TimeSlot> slots = timeSlotRepository.findAllByDateOrderByStartTimeAsc(date);

        Set<Long> mySlotIds = reservationRepository
                .findAllByUserUserIdAndStatusOrderByReservedAtDesc(userId, Reservation.Status.CONFIRMED)
                .stream()
                .map(r -> r.getSlot().getSlotId())
                .collect(Collectors.toSet());

        return slots.stream()
                .map(slot -> TimeSlotResponse.from(slot, mySlotIds.contains(slot.getSlotId())))
                .collect(Collectors.toList());
    }

    // 슬롯의 예약자 목록 조회
    @Transactional(readOnly = true)
    public List<ReservationResponse> getSlotReservations(Long slotId) {
        TimeSlot slot = timeSlotRepository.findById(slotId)
                .orElseThrow(() -> new CustomException(ErrorCode.RESOURCE_NOT_FOUND));
        TimeSlotResponse slotResponse = TimeSlotResponse.from(slot, false);

        return reservationRepository.findAllBySlotSlotIdAndStatus(slotId, Reservation.Status.CONFIRMED)
                .stream()
                .map(r -> ReservationResponse.from(r, slotResponse))
                .collect(Collectors.toList());
    }

    // 예약 생성
    @Transactional
    public ReservationResponse createReservation(Long userId, ReservationRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        TimeSlot slot = timeSlotRepository.findById(request.getSlotId())
                .orElseThrow(() -> new CustomException(ErrorCode.RESOURCE_NOT_FOUND));

        if (reservationRepository.existsByUserUserIdAndSlotSlotIdAndStatus(userId, slot.getSlotId(), Reservation.Status.CONFIRMED)) {
            throw new CustomException(ErrorCode.DUPLICATE_RESERVATION);
        }

        if (slot.getCurrentCount() >= slot.getMaxCapacity()) {
            throw new CustomException(ErrorCode.SLOT_FULL);
        }

        String reservationNo = "RSV" + System.currentTimeMillis();
        Reservation reservation = Reservation.builder()
                .user(user)
                .slot(slot)
                .reservationNo(reservationNo)
                .status(Reservation.Status.CONFIRMED)
                .reservedAt(LocalDateTime.now())
                .build();

        Reservation saved = reservationRepository.save(reservation);
        timeSlotRepository.incrementCurrentCount(slot.getSlotId());

        // 저장 후 최신 슬롯 상태 조회
        TimeSlot updatedSlot = timeSlotRepository.findById(slot.getSlotId()).orElse(slot);
        return ReservationResponse.from(saved, TimeSlotResponse.from(updatedSlot, true));
    }

    // 예약 취소
    @Transactional
    public void cancelReservation(Long userId, Long reservationId) {
        Reservation reservation = reservationRepository.findById(reservationId)
                .orElseThrow(() -> new CustomException(ErrorCode.RESERVATION_NOT_FOUND));

        if (!reservation.getUser().getUserId().equals(userId)) {
            throw new CustomException(ErrorCode.FORBIDDEN);
        }

        if (reservation.getStatus() == Reservation.Status.CANCELLED) {
            throw new CustomException(ErrorCode.ALREADY_CANCELLED);
        }

        reservationRepository.updateStatus(
                reservationId,
                Reservation.Status.CANCELLED,
                LocalDateTime.now()
        );
        timeSlotRepository.decrementCurrentCount(reservation.getSlot().getSlotId());
    }

    // 내 예약 목록
    @Transactional(readOnly = true)
    public List<ReservationResponse> getMyReservations(Long userId) {
        return reservationRepository
                .findAllByUserUserIdAndStatusOrderByReservedAtDesc(userId, Reservation.Status.CONFIRMED)
                .stream()
                .map(r -> ReservationResponse.from(r, TimeSlotResponse.from(r.getSlot(), true)))
                .collect(Collectors.toList());
    }

    // 내 다음 예약 (오늘 이후의 첫 번째)
    @Transactional(readOnly = true)
    public ReservationResponse getNextReservation(Long userId) {
        return reservationRepository
                .findAllByUserUserIdAndStatusOrderByReservedAtDesc(userId, Reservation.Status.CONFIRMED)
                .stream()
                .filter(r -> !r.getSlot().getDate().isBefore(LocalDate.now()))
                .findFirst()
                .map(r -> ReservationResponse.from(r, TimeSlotResponse.from(r.getSlot(), true)))
                .orElse(null);
    }

    // 내 전체 예약 이력 (모든 상태)
    @Transactional(readOnly = true)
    public List<ReservationResponse> getAllMyReservations(Long userId) {
        return reservationRepository
                .findAllByUserUserIdOrderByReservedAtDesc(userId)
                .stream()
                .map(r -> ReservationResponse.from(r, TimeSlotResponse.from(r.getSlot(), r.getStatus() == Reservation.Status.CONFIRMED)))
                .collect(Collectors.toList());
    }

    // 날짜별 타임슬롯 자동 생성 (09:00-22:00)
    private void createTimeSlotsForDate(LocalDate date, Facility facility) {
        for (int hour = SLOT_START_HOUR; hour < SLOT_END_HOUR; hour++) {
            TimeSlot slot = TimeSlot.builder()
                    .facility(facility)
                    .date(date)
                    .startTime(LocalTime.of(hour, 0))
                    .endTime(LocalTime.of(hour + 1, 0))
                    .maxCapacity(SLOT_CAPACITY)
                    .currentCount(0)
                    .build();
            timeSlotRepository.save(slot);
        }
    }
}
