package com.smithlife.backend.repository;

import com.smithlife.backend.entity.TimeSlot;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

public interface TimeSlotRepository extends JpaRepository<TimeSlot, Long> {

    List<TimeSlot> findByDateOrderByStartTimeAsc(LocalDate date);

    Optional<TimeSlot> findByFacilityFacilityIdAndDateAndStartTimeLessThanEqualAndEndTimeGreaterThan(
            Long facilityId, LocalDate date, LocalTime startTime, LocalTime endTime);

    @Modifying
    @Query("UPDATE TimeSlot ts SET ts.currentCount = ts.currentCount + 1 WHERE ts.slotId = :slotId")
    void incrementCurrentCount(@Param("slotId") Long slotId);

    @Modifying
    @Query("UPDATE TimeSlot ts SET ts.currentCount = ts.currentCount - 1 WHERE ts.slotId = :slotId AND ts.currentCount > 0")
    void decrementCurrentCount(@Param("slotId") Long slotId);
}
