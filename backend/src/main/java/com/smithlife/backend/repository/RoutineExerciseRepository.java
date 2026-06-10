package com.smithlife.backend.repository;

import com.smithlife.backend.entity.RoutineExercise;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RoutineExerciseRepository extends JpaRepository<RoutineExercise, Long> {

    List<RoutineExercise> findAllByRoutineRoutineIdOrderByOrderIndexAsc(Long routineId);
}
