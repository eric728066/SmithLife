package com.smithlife.backend.repository;

import com.smithlife.backend.entity.Reservation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface ReservationRepository extends JpaRepository<Reservation, Long> {

    List<Reservation> findAllByUserUserIdAndStatusOrderByReservedAtDesc(Long userId, Reservation.Status status);

    boolean existsByUserUserIdAndSlotSlotIdAndStatus(Long userId, Long slotId, Reservation.Status status);

    long countBySlotSlotIdAndStatus(Long slotId, Reservation.Status status);

    List<Reservation> findAllBySlotSlotIdAndStatus(Long slotId, Reservation.Status status);

    Optional<Reservation> findByUserUserIdAndSlotDateAndStatus(Long userId, LocalDate date, Reservation.Status status);

    List<Reservation> findAllByUserUserIdOrderByReservedAtDesc(Long userId);

    long countByUserUserIdAndStatusAndSlotDateBefore(Long userId, Reservation.Status status, LocalDate date);

    @Modifying
    @Query("UPDATE Reservation r SET r.status = :status, r.cancelledAt = :cancelledAt WHERE r.reservationId = :id")
    int updateStatus(@Param("id") Long id, @Param("status") Reservation.Status status, @Param("cancelledAt") LocalDateTime cancelledAt);
}
