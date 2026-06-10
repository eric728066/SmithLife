package com.smithlife.backend.service;

import com.smithlife.backend.dto.request.WorkoutSessionSaveRequest;
import com.smithlife.backend.dto.response.WorkoutSessionResponse;
import com.smithlife.backend.entity.*;
import com.smithlife.backend.exception.CustomException;
import com.smithlife.backend.common.ErrorCode;
import com.smithlife.backend.repository.*;
import com.smithlife.backend.security.SecurityUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class WorkoutService {

    private final WorkoutSessionRepository workoutSessionRepository;
    private final SessionExerciseRepository sessionExerciseRepository;
    private final UserRepository userRepository;
    private final RoutineRepository routineRepository;
    private final ExerciseRepository exerciseRepository;

    /** 운동 완료 후 세션 저장 */
    @Transactional
    public WorkoutSessionResponse saveSession(WorkoutSessionSaveRequest request) {
        Long userId = SecurityUtil.getCurrentUserId();
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        // 루틴 조회 (선택사항)
        Routine routine = null;
        if (request.getRoutineId() != null) {
            routine = routineRepository.findById(request.getRoutineId()).orElse(null);
        }

        LocalDateTime now = LocalDateTime.now();
        int durationSec = request.getTotalDurationSec() != null ? request.getTotalDurationSec() : 0;

        // request 전체 운동 수 및 완료 수 (DB 매칭 여부와 무관하게 실제 수행 기준)
        int requestTotal = request.getExercises() != null ? request.getExercises().size() : 0;
        int requestCompleted = request.getExercises() != null
                ? (int) request.getExercises().stream()
                        .filter(e -> "COMPLETED".equals(e.getStatus()))
                        .count()
                : 0;

        WorkoutSession session = WorkoutSession.builder()
                .user(user)
                .routine(routine)
                .sessionName(request.getSessionName())
                .startTime(now.minusSeconds(durationSec))
                .endTime(now)
                .totalDurationSec(durationSec)
                .totalVolumeKg(BigDecimal.ZERO)
                .totalCalories(BigDecimal.ZERO)
                .totalExercises(requestTotal)
                .completedExercises(requestCompleted)
                .status(WorkoutSession.Status.COMPLETED)
                .build();

        WorkoutSession saved = workoutSessionRepository.save(session);

        // SessionExercise 저장
        List<SessionExercise> savedExercises = new ArrayList<>();
        BigDecimal totalVolume = BigDecimal.ZERO;

        if (request.getExercises() != null) {
            for (WorkoutSessionSaveRequest.ExerciseData exData : request.getExercises()) {
                Optional<Exercise> exerciseOpt = exerciseRepository.findAll().stream()
                        .filter(e -> e.getName().equals(exData.getExerciseName()))
                        .findFirst();

                if (exerciseOpt.isEmpty()) continue;

                Exercise exercise = exerciseOpt.get();
                SessionExercise.Status status = parseExerciseStatus(exData.getStatus());

                SessionExercise sessionExercise = SessionExercise.builder()
                        .session(saved)
                        .exercise(exercise)
                        .orderIndex(exData.getOrderIndex() != null ? exData.getOrderIndex() : 0)
                        .targetSets(exData.getSets() != null ? exData.getSets().size() : 3)
                        .targetReps(10)
                        .status(status)
                        .build();

                savedExercises.add(sessionExerciseRepository.save(sessionExercise));

                // 세트별 볼륨 계산
                if (exData.getSets() != null) {
                    for (WorkoutSessionSaveRequest.SetData setData : exData.getSets()) {
                        if (Boolean.TRUE.equals(setData.getIsCompleted())
                                && setData.getWeightKg() != null
                                && setData.getReps() != null) {
                            totalVolume = totalVolume.add(
                                    BigDecimal.valueOf(setData.getWeightKg())
                                            .multiply(BigDecimal.valueOf(setData.getReps())));
                        }
                    }
                }
            }

            // 클라이언트가 미리 계산한 볼륨이 있으면 우선 사용
            if (request.getTotalVolumeKgOverride() != null && request.getTotalVolumeKgOverride() > 0) {
                totalVolume = BigDecimal.valueOf(request.getTotalVolumeKgOverride());
            }

            // 총 볼륨 업데이트
            saved = workoutSessionRepository.save(WorkoutSession.builder()
                    .sessionId(saved.getSessionId())
                    .user(saved.getUser())
                    .routine(saved.getRoutine())
                    .sessionName(saved.getSessionName())
                    .startTime(saved.getStartTime())
                    .endTime(saved.getEndTime())
                    .totalDurationSec(saved.getTotalDurationSec())
                    .totalVolumeKg(totalVolume)
                    .totalCalories(BigDecimal.ZERO)
                    .totalExercises(requestTotal)
                    .completedExercises(requestCompleted)
                    .status(saved.getStatus())
                    .build());
        }

        return buildResponse(saved, savedExercises, requestTotal, requestCompleted);
    }

    /** 내 운동 기록 목록 */
    public List<WorkoutSessionResponse> getMyHistory() {
        Long userId = SecurityUtil.getCurrentUserId();
        return workoutSessionRepository.findAllByUserUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(WorkoutSessionResponse::from)
                .collect(Collectors.toList());
    }

    /** 특정 세션 상세 */
    public WorkoutSessionResponse getSession(Long sessionId) {
        Long userId = SecurityUtil.getCurrentUserId();
        WorkoutSession session = workoutSessionRepository.findById(sessionId)
                .orElseThrow(() -> new CustomException(ErrorCode.SESSION_NOT_FOUND));

        if (!session.getUser().getUserId().equals(userId)) {
            throw new CustomException(ErrorCode.FORBIDDEN);
        }
        return WorkoutSessionResponse.from(session);
    }

    /** 세션 삭제 */
    @Transactional
    public void deleteSession(Long sessionId) {
        Long userId = SecurityUtil.getCurrentUserId();
        WorkoutSession session = workoutSessionRepository.findById(sessionId)
                .orElseThrow(() -> new CustomException(ErrorCode.SESSION_NOT_FOUND));
        if (!session.getUser().getUserId().equals(userId)) {
            throw new CustomException(ErrorCode.FORBIDDEN);
        }
        workoutSessionRepository.delete(session);
    }

    /** saveSession 직후 저장된 exercises 기반으로 응답 생성 (total/completed는 request 기준) */
    private WorkoutSessionResponse buildResponse(WorkoutSession session, List<SessionExercise> exercises,
                                                  int totalExercises, int completedExercises) {
        List<WorkoutSessionResponse.SessionExerciseItem> items = exercises.stream()
                .sorted((a, b) -> a.getOrderIndex().compareTo(b.getOrderIndex()))
                .map(WorkoutSessionResponse.SessionExerciseItem::from)
                .collect(Collectors.toList());

        int durationSec = session.getTotalDurationSec() != null ? session.getTotalDurationSec() : 0;
        int m = durationSec / 60;
        int s = durationSec % 60;

        return WorkoutSessionResponse.builder()
                .sessionId(session.getSessionId())
                .sessionName(session.getSessionName())
                .startTime(session.getStartTime())
                .endTime(session.getEndTime())
                .totalDurationSec(durationSec)
                .timerLabel(String.format("%02d:%02d", m, s))
                .completedExercises(completedExercises)
                .totalExercises(totalExercises)
                .completionPercent(totalExercises > 0 ? (completedExercises * 100 / totalExercises) : 0)
                .totalVolumeKg(session.getTotalVolumeKg() != null ? session.getTotalVolumeKg() : java.math.BigDecimal.ZERO)
                .exercises(items)
                .build();
    }

    private SessionExercise.Status parseExerciseStatus(String status) {
        if (status == null) return SessionExercise.Status.PENDING;
        return switch (status) {
            case "COMPLETED" -> SessionExercise.Status.COMPLETED;
            case "IN_PROGRESS" -> SessionExercise.Status.IN_PROGRESS;
            default -> SessionExercise.Status.PENDING;
        };
    }
}
