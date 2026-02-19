package com.smithlife.backend.repository;

import com.smithlife.backend.entity.FavoriteRoutine;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.Set;

public interface FavoriteRoutineRepository extends JpaRepository<FavoriteRoutine, Long> {

    Optional<FavoriteRoutine> findByUserUserIdAndRoutineRoutineId(Long userId, Long routineId);

    boolean existsByUserUserIdAndRoutineRoutineId(Long userId, Long routineId);

    List<FavoriteRoutine> findByUserUserIdOrderByCreatedAtDesc(Long userId);

    @Query("SELECT fr.routine.routineId FROM FavoriteRoutine fr WHERE fr.user.userId = :userId")
    Set<Long> findFavoriteRoutineIdsByUserId(@Param("userId") Long userId);
}
