package com.smithlife.backend.service;

import com.smithlife.backend.common.ErrorCode;
import com.smithlife.backend.dto.request.RoutineCreateRequest;
import com.smithlife.backend.dto.response.RoutineResponse;
import com.smithlife.backend.entity.*;
import com.smithlife.backend.exception.CustomException;
import com.smithlife.backend.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RoutineService {

    private final RoutineRepository routineRepository;
    private final RoutineExerciseRepository routineExerciseRepository;
    private final FavoriteRoutineRepository favoriteRoutineRepository;
    private final ExerciseRepository exerciseRepository;
    private final UserRepository userRepository;

    /**
     * 공개 루틴 목록 조회 (추천 루틴 우선 정렬)
     */
    @Transactional(readOnly = true)
    public List<RoutineResponse> getPublicRoutines(Long userId) {
        Set<Long> favoriteIds = favoriteRoutineRepository.findFavoriteRoutineIdsByUserId(userId);
        return routineRepository.findPublicRoutinesWithExercises()
                .stream()
                .map(r -> RoutineResponse.from(r, favoriteIds.contains(r.getRoutineId())))
                .collect(Collectors.toList());
    }

    /**
     * 내가 만든 루틴 목록 조회
     */
    @Transactional(readOnly = true)
    public List<RoutineResponse> getMyRoutines(Long userId) {
        Set<Long> favoriteIds = favoriteRoutineRepository.findFavoriteRoutineIdsByUserId(userId);
        return routineRepository.findMyRoutinesWithExercises(userId)
                .stream()
                .map(r -> RoutineResponse.from(r, favoriteIds.contains(r.getRoutineId())))
                .collect(Collectors.toList());
    }

    /**
     * 즐겨찾기 루틴 목록 조회
     */
    @Transactional(readOnly = true)
    public List<RoutineResponse> getFavoriteRoutines(Long userId) {
        return favoriteRoutineRepository.findByUserUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(fav -> {
                    Routine routine = routineRepository
                            .findByIdWithExercises(fav.getRoutine().getRoutineId())
                            .orElseThrow(() -> new CustomException(ErrorCode.ROUTINE_NOT_FOUND));
                    return RoutineResponse.from(routine, true);
                })
                .collect(Collectors.toList());
    }

    /**
     * 루틴 상세 조회
     */
    @Transactional(readOnly = true)
    public RoutineResponse getRoutineDetail(Long userId, Long routineId) {
        Routine routine = routineRepository.findByIdWithExercises(routineId)
                .orElseThrow(() -> new CustomException(ErrorCode.ROUTINE_NOT_FOUND));

        if (!routine.getIsPublic() &&
                (routine.getCreator() == null || !routine.getCreator().getUserId().equals(userId))) {
            throw new CustomException(ErrorCode.FORBIDDEN);
        }

        boolean isFavorited = favoriteRoutineRepository.existsByUserUserIdAndRoutineRoutineId(userId, routineId);
        return RoutineResponse.from(routine, isFavorited);
    }

    /**
     * 루틴 생성
     */
    @Transactional
    public RoutineResponse createRoutine(Long userId, RoutineCreateRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        Routine routine = Routine.builder()
                .creator(user)
                .name(request.getName())
                .goal(Routine.Goal.valueOf(request.getGoal()))
                .difficulty(Routine.Difficulty.valueOf(request.getDifficulty()))
                .estimatedMin(request.getEstimatedMin())
                .frequency(request.getFrequency())
                .description(request.getDescription())
                .isPublic(request.getIsPublic() != null ? request.getIsPublic() : true)
                .isRecommended(false)
                .build();

        Routine saved = routineRepository.save(routine);

        // 운동 목록 저장
        for (RoutineCreateRequest.RoutineExerciseItem item : request.getExercises()) {
            Exercise exercise = exerciseRepository.findById(item.getExerciseId())
                    .orElseThrow(() -> new CustomException(ErrorCode.EXERCISE_NOT_FOUND));

            RoutineExercise re = RoutineExercise.builder()
                    .routine(saved)
                    .exercise(exercise)
                    .orderIndex(item.getOrderIndex())
                    .targetSets(item.getTargetSets())
                    .targetRepsMin(item.getTargetRepsMin())
                    .targetRepsMax(item.getTargetRepsMax())
                    .build();
            routineExerciseRepository.save(re);
        }

        Routine result = routineRepository.findByIdWithExercises(saved.getRoutineId())
                .orElseThrow(() -> new CustomException(ErrorCode.ROUTINE_NOT_FOUND));
        return RoutineResponse.from(result, false);
    }

    /**
     * 루틴 삭제
     */
    @Transactional
    public void deleteRoutine(Long userId, Long routineId) {
        Routine routine = routineRepository.findById(routineId)
                .orElseThrow(() -> new CustomException(ErrorCode.ROUTINE_NOT_FOUND));

        if (routine.getCreator() == null || !routine.getCreator().getUserId().equals(userId)) {
            throw new CustomException(ErrorCode.FORBIDDEN);
        }

        routineExerciseRepository.deleteByRoutineRoutineId(routineId);
        routineRepository.delete(routine);
    }

    /**
     * 즐겨찾기 추가
     */
    @Transactional
    public void addFavorite(Long userId, Long routineId) {
        if (favoriteRoutineRepository.existsByUserUserIdAndRoutineRoutineId(userId, routineId)) {
            throw new CustomException(ErrorCode.ALREADY_FAVORITED);
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
        Routine routine = routineRepository.findById(routineId)
                .orElseThrow(() -> new CustomException(ErrorCode.ROUTINE_NOT_FOUND));

        FavoriteRoutine favorite = FavoriteRoutine.builder()
                .user(user)
                .routine(routine)
                .build();
        favoriteRoutineRepository.save(favorite);
    }

    /**
     * 즐겨찾기 제거
     */
    @Transactional
    public void removeFavorite(Long userId, Long routineId) {
        FavoriteRoutine favorite = favoriteRoutineRepository
                .findByUserUserIdAndRoutineRoutineId(userId, routineId)
                .orElseThrow(() -> new CustomException(ErrorCode.ROUTINE_NOT_FOUND));
        favoriteRoutineRepository.delete(favorite);
    }
}
