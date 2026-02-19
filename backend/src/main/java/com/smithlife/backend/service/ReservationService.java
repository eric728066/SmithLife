package com.smithlife.backend.service;

import com.smithlife.backend.common.ErrorCode;
import com.smithlife.backend.dto.request.ReservationRequest;
import com.smithlife.backend.dto.response.ReservationResponse;
import com.smithlife.backend.entity.Reservation;
import com.smithlife.backend.entity.TimeSlot;
import com.smithlife.backend.entity.User;
import com.smithlife.backend.exception.CustomException;
import com.smithlife.backend.repository.ReservationRepository;
import com.smithlife.backend.repository.TimeSlotRepository;
import com.smithlife.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReservationService {

    private final ReservationRepository reservationRepository;
    private final TimeSlotRepository timeSlotRepository;
    private final UserRepository userRepository;

    /**
     * 예약 생성
     */
    @Transactional
    public ReservationResponse createReservation(Long userId, ReservationRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        TimeSlot slot = timeSlotRepository.findById(request.getSlotId())
                .orElseThrow(() -> new CustomException(ErrorCode.SLOT_NOT_FOUND));

        // 과거 날짜 예약 방지
        if (slot.getDate().isBefore(LocalDate.now())) {
            throw new CustomException(ErrorCode.PAST_DATE_RESERVATION);
        }

        // 정원 초과 확인
        if (slot.getCurrentCount() >= slot.getMaxCapacity()) {
            throw new CustomException(ErrorCode.SLOT_FULL);
        }

        // 동일 슬롯 중복 예약 확인
        if (reservationRepository.existsByUserUserIdAndSlotSlotIdAndStatusNot(
                userId, slot.getSlotId(), Reservation.Status.CANCELLED)) {
            throw new CustomException(ErrorCode.DUPLICATE_RESERVATION);
        }

        String reservationNo = generateReservationNo();

        Reservation reservation = Reservation.builder()
                .user(user)
                .slot(slot)
                .reservationNo(reservationNo)
                .status(Reservation.Status.CONFIRMED)
                .reservedAt(LocalDateTime.now())
                .build();

        Reservation saved = reservationRepository.save(reservation);

        // currentCount 증가
        timeSlotRepository.incrementCurrentCount(slot.getSlotId());

        return ReservationResponse.from(saved);
    }

    /**
     * 예약 취소
     */
    @Transactional
    public void cancelReservation(Long userId, Long reservationId) {
        Reservation reservation = reservationRepository.findById(reservationId)
                .orElseThrow(() -> new CustomException(ErrorCode.RESERVATION_NOT_FOUND));

        // 본인 예약 확인
        if (!reservation.getUser().getUserId().equals(userId)) {
            throw new CustomException(ErrorCode.FORBIDDEN);
        }

        // 이미 취소된 예약 확인
        if (reservation.getStatus() == Reservation.Status.CANCELLED) {
            throw new CustomException(ErrorCode.ALREADY_CANCELLED);
        }

        Reservation cancelled = Reservation.builder()
                .reservationId(reservation.getReservationId())
                .user(reservation.getUser())
                .slot(reservation.getSlot())
                .reservationNo(reservation.getReservationNo())
                .status(Reservation.Status.CANCELLED)
                .reservedAt(reservation.getReservedAt())
                .cancelledAt(LocalDateTime.now())
                .build();

        reservationRepository.save(cancelled);

        // currentCount 감소
        timeSlotRepository.decrementCurrentCount(reservation.getSlot().getSlotId());
    }

    /**
     * 내 예약 목록 조회
     */
    @Transactional(readOnly = true)
    public List<ReservationResponse> getMyReservations(Long userId) {
        return reservationRepository.findByUserUserIdOrderByReservedAtDesc(userId)
                .stream()
                .map(ReservationResponse::from)
                .collect(Collectors.toList());
    }

    /**
     * 다음 예약 조회 (홈 화면용)
     */
    @Transactional(readOnly = true)
    public ReservationResponse getNextReservation(Long userId) {
        List<Reservation> upcoming = reservationRepository.findUpcomingReservations(userId, LocalDate.now());

        if (upcoming.isEmpty()) {
            return null;
        }

        return ReservationResponse.from(upcoming.get(0));
    }

    private String generateReservationNo() {
        String date = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        String suffix = UUID.randomUUID().toString().replace("-", "").substring(0, 6).toUpperCase();
        return "RV" + date + suffix;
    }
}
