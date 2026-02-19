package com.smithlife.backend.repository;

import com.smithlife.backend.entity.Routine;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface RoutineRepository extends JpaRepository<Routine, Long> {

    @Query("SELECT DISTINCT r FROM Routine r " +
           "LEFT JOIN FETCH r.routineExercises re " +
           "LEFT JOIN FETCH re.exercise " +
           "WHERE r.isPublic = true " +
           "ORDER BY r.isRecommended DESC, r.createdAt DESC")
    List<Routine> findPublicRoutinesWithExercises();

    @Query("SELECT DISTINCT r FROM Routine r " +
           "LEFT JOIN FETCH r.routineExercises re " +
           "LEFT JOIN FETCH re.exercise " +
           "WHERE r.creator.userId = :userId " +
           "ORDER BY r.createdAt DESC")
    List<Routine> findMyRoutinesWithExercises(@Param("userId") Long userId);

    @Query("SELECT DISTINCT r FROM Routine r " +
           "LEFT JOIN FETCH r.routineExercises re " +
           "LEFT JOIN FETCH re.exercise " +
           "WHERE r.routineId = :routineId")
    Optional<Routine> findByIdWithExercises(@Param("routineId") Long routineId);
}
