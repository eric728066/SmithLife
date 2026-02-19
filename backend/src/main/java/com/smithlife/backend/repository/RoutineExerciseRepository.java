package com.smithlife.backend.repository;

import com.smithlife.backend.entity.RoutineExercise;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RoutineExerciseRepository extends JpaRepository<RoutineExercise, Long> {

    List<RoutineExercise> findByRoutineRoutineIdOrderByOrderIndexAsc(Long routineId);

    void deleteByRoutineRoutineId(Long routineId);
}
