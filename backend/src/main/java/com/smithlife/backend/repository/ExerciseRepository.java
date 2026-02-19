package com.smithlife.backend.repository;

import com.smithlife.backend.entity.Exercise;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ExerciseRepository extends JpaRepository<Exercise, Long> {

    List<Exercise> findByNameContainingIgnoreCaseOrBodyPartContainingIgnoreCase(String name, String bodyPart);

    List<Exercise> findByBodyPartIgnoreCase(String bodyPart);
}
