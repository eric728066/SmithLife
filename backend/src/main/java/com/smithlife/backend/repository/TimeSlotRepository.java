package com.smithlife.backend.repository;

import com.smithlife.backend.entity.TimeSlot;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;

public interface TimeSlotRepository extends JpaRepository<TimeSlot, Long> {

    List<TimeSlot> findAllByDateOrderByStartTimeAsc(LocalDate date);

    boolean existsByDateAndFacilityFacilityId(LocalDate date, Long facilityId);

    @Modifying
    @Query("UPDATE TimeSlot t SET t.currentCount = t.currentCount + 1 WHERE t.slotId = :slotId AND t.currentCount < t.maxCapacity")
    int incrementCurrentCount(@Param("slotId") Long slotId);

    @Modifying
    @Query("UPDATE TimeSlot t SET t.currentCount = t.currentCount - 1 WHERE t.slotId = :slotId AND t.currentCount > 0")
    int decrementCurrentCount(@Param("slotId") Long slotId);
}
