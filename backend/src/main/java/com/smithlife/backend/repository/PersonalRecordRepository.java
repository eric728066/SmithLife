package com.smithlife.backend.repository;

import com.smithlife.backend.entity.PersonalRecord;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface PersonalRecordRepository extends JpaRepository<PersonalRecord, Long> {

    List<PersonalRecord> findByUserUserIdOrderByAchievedAtDesc(Long userId);

    Optional<PersonalRecord> findByUserUserIdAndExerciseExerciseIdAndRecordType(
            Long userId, Long exerciseId, PersonalRecord.RecordType recordType);
}
