package com.smithlife.backend.repository;

import com.smithlife.backend.entity.Exercise;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ExerciseRepository extends JpaRepository<Exercise, Long> {

    List<Exercise> findAllByOrderByBodyPartAscNameAsc();

    List<Exercise> findAllByBodyPartOrderByNameAsc(String bodyPart);

    boolean existsByName(String name);

    long count();
}
