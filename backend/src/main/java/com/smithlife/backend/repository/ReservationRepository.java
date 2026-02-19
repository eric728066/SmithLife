package com.smithlife.backend.repository;

import com.smithlife.backend.entity.Reservation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface ReservationRepository extends JpaRepository<Reservation, Long> {

    List<Reservation> findByUserUserIdOrderByReservedAtDesc(Long userId);

    @Query("SELECT r FROM Reservation r JOIN r.slot s " +
           "WHERE r.user.userId = :userId AND r.status = 'CONFIRMED' " +
           "AND (s.date > :today OR (s.date = :today)) " +
           "ORDER BY s.date ASC, s.startTime ASC")
    List<Reservation> findUpcomingReservations(@Param("userId") Long userId,
                                               @Param("today") LocalDate today);

    boolean existsByUserUserIdAndSlotSlotIdAndStatusNot(Long userId, Long slotId,
                                                        Reservation.Status status);
}
