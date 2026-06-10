package com.smithlife.backend.service;

import com.smithlife.backend.common.ApiResponse;
import com.smithlife.backend.dto.request.RoutineCreateRequest;
import com.smithlife.backend.dto.response.RoutineResponse;
import com.smithlife.backend.entity.Exercise;
import com.smithlife.backend.entity.Routine;
import com.smithlife.backend.entity.RoutineExercise;
import com.smithlife.backend.entity.User;
import com.smithlife.backend.exception.CustomException;
import com.smithlife.backend.common.ErrorCode;
import com.smithlife.backend.repository.ExerciseRepository;
import com.smithlife.backend.repository.RoutineExerciseRepository;
import com.smithlife.backend.repository.RoutineRepository;
import com.smithlife.backend.repository.UserRepository;
import com.smithlife.backend.security.SecurityUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class RoutineService {

    private final RoutineRepository routineRepository;
    private final ExerciseRepository exerciseRepository;
    private final UserRepository userRepository;
    private final RoutineExerciseRepository routineExerciseRepository;

    /** 추천 루틴 목록 (DB 시딩된 기본 제공 루틴) */
    public List<RoutineResponse> getRecommendedRoutines() {
        return routineRepository.findAllByIsRecommendedTrueOrderByRoutineIdAsc()
                .stream()
                .map(RoutineResponse::from)
                .collect(Collectors.toList());
    }

    /** 공유 루틴 목록 (유저가 공개로 등록한 루틴) */
    public List<RoutineResponse> getSharedRoutines() {
        return routineRepository.findAllByIsPublicTrueAndIsRecommendedFalseOrderByCreatedAtDesc()
                .stream()
                .map(RoutineResponse::from)
                .collect(Collectors.toList());
    }

    /** 내 공유 루틴 목록 */
    public List<RoutineResponse> getMySharedRoutines() {
        Long userId = SecurityUtil.getCurrentUserId();
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
        return routineRepository.findAllByCreatorAndIsPublicTrueOrderByCreatedAtDesc(user)
                .stream()
                .map(RoutineResponse::from)
                .collect(Collectors.toList());
    }

    /** 공유 루틴 생성 (isPublic = true) */
    @Transactional
    public RoutineResponse createSharedRoutine(RoutineCreateRequest request) {
        Long userId = SecurityUtil.getCurrentUserId();
        User creator = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        // Goal, Difficulty 매핑
        Routine.Goal goal = parseGoal(request.getGoal());
        Routine.Difficulty difficulty = parseDifficulty(request.getDifficulty());

        int estimatedMin = request.getExercises() == null ? 30
                : Math.min(request.getExercises().size() * 12, 120);

        Routine routine = Routine.builder()
                .creator(creator)
                .name(request.getName())
                .goal(goal)
                .difficulty(difficulty)
                .estimatedMin(estimatedMin)
                .frequency(request.getFrequency() != null ? request.getFrequency() : "주 3회")
                .description(request.getDescription())
                .isPublic(true)
                .isRecommended(false)
                .build();

        Routine saved = routineRepository.save(routine);

        // 운동 연결
        if (request.getExercises() != null) {
            int order = 1;
            for (RoutineCreateRequest.ExerciseItem item : request.getExercises()) {
                final int finalOrder = order++;
                exerciseRepository.findAll().stream()
                        .filter(e -> e.getName().equals(item.getExerciseName()))
                        .findFirst()
                        .ifPresent(exercise -> routineExerciseRepository.save(
                                RoutineExercise.builder()
                                        .routine(saved)
                                        .exercise(exercise)
                                        .orderIndex(finalOrder)
                                        .targetSets(item.getTargetSets() != null ? item.getTargetSets() : 3)
                                        .targetRepsMin(item.getTargetRepsMin() != null ? item.getTargetRepsMin() : 8)
                                        .targetRepsMax(item.getTargetRepsMax() != null ? item.getTargetRepsMax() : 12)
                                        .build()
                        ));
            }
        }

        return RoutineResponse.from(saved);
    }

    /** 내 공유 루틴 삭제 */
    @Transactional
    public void deleteSharedRoutine(Long routineId) {
        Long userId = SecurityUtil.getCurrentUserId();
        Routine routine = routineRepository.findById(routineId)
                .orElseThrow(() -> new CustomException(ErrorCode.ROUTINE_NOT_FOUND));

        if (routine.getCreator() == null || !routine.getCreator().getUserId().equals(userId)) {
            throw new CustomException(ErrorCode.FORBIDDEN);
        }
        routineRepository.delete(routine);
    }

    // ────────────────────────────────────
    // 헬퍼: Flutter 문자열 → Enum 변환
    // ────────────────────────────────────
    private Routine.Goal parseGoal(String goal) {
        return switch (goal) {
            case "MUSCLE_GAIN", "근성장" -> Routine.Goal.MUSCLE_GAIN;
            case "DIET", "다이어트" -> Routine.Goal.DIET;
            case "STAMINA", "체력 증진", "근력 향상" -> Routine.Goal.STAMINA;
            default -> Routine.Goal.MUSCLE_GAIN;
        };
    }

    private Routine.Difficulty parseDifficulty(String difficulty) {
        return switch (difficulty) {
            case "BEGINNER", "입문" -> Routine.Difficulty.BEGINNER;
            case "INTERMEDIATE", "중급" -> Routine.Difficulty.INTERMEDIATE;
            case "ADVANCED", "고급" -> Routine.Difficulty.ADVANCED;
            default -> Routine.Difficulty.INTERMEDIATE;
        };
    }
}
