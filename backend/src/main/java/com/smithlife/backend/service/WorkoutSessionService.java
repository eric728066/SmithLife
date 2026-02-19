package com.smithlife.backend.service;

import com.smithlife.backend.common.ErrorCode;
import com.smithlife.backend.dto.request.ExerciseAddRequest;
import com.smithlife.backend.dto.request.SessionStartRequest;
import com.smithlife.backend.dto.request.SetRecordRequest;
import com.smithlife.backend.dto.response.ExerciseSetResponse;
import com.smithlife.backend.dto.response.SessionExerciseResponse;
import com.smithlife.backend.dto.response.WorkoutSessionResponse;
import com.smithlife.backend.entity.*;
import com.smithlife.backend.exception.CustomException;
import com.smithlife.backend.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class WorkoutSessionService {

    private final WorkoutSessionRepository sessionRepository;
    private final SessionExerciseRepository sessionExerciseRepository;
    private final ExerciseSetRepository exerciseSetRepository;
    private final ExerciseRepository exerciseRepository;
    private final PersonalRecordRepository personalRecordRepository;
    private final UserRepository userRepository;

    /**
     * 세션 시작
     */
    @Transactional
    public WorkoutSessionResponse startSession(Long userId, SessionStartRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        // 이미 진행 중인 세션 확인
        sessionRepository.findByUserUserIdAndStatus(userId, WorkoutSession.Status.ACTIVE)
                .ifPresent(s -> { throw new CustomException(ErrorCode.SESSION_ALREADY_ACTIVE); });

        WorkoutSession session = WorkoutSession.builder()
                .user(user)
                .sessionName(request.getSessionName())
                .startTime(LocalDateTime.now())
                .totalDurationSec(0)
                .totalVolumeKg(BigDecimal.ZERO)
                .totalCalories(BigDecimal.ZERO)
                .status(WorkoutSession.Status.ACTIVE)
                .build();

        WorkoutSession saved = sessionRepository.save(session);
        return WorkoutSessionResponse.from(saved);
    }

    /**
     * 세션 종료
     */
    @Transactional
    public WorkoutSessionResponse endSession(Long userId, Long sessionId) {
        WorkoutSession session = getSessionOrThrow(userId, sessionId);

        if (session.getStatus() == WorkoutSession.Status.COMPLETED) {
            throw new CustomException(ErrorCode.SESSION_ALREADY_ENDED);
        }

        LocalDateTime endTime = LocalDateTime.now();
        int durationSec = (int) ChronoUnit.SECONDS.between(session.getStartTime(), endTime);

        // 총 볼륨 계산
        BigDecimal totalVolume = exerciseSetRepository.sumVolumeBySessionId(sessionId);
        if (totalVolume == null) totalVolume = BigDecimal.ZERO;

        // 칼로리 계산 (볼륨 * 0.005 kcal 간단 추정)
        BigDecimal calories = totalVolume.multiply(new BigDecimal("0.005"));

        sessionRepository.updateSessionEnd(sessionId, WorkoutSession.Status.COMPLETED,
                endTime, durationSec, totalVolume, calories);

        // 개인 기록 업데이트
        updatePersonalRecords(userId, sessionId);

        WorkoutSession updated = sessionRepository.findByIdWithDetails(sessionId)
                .orElseThrow(() -> new CustomException(ErrorCode.SESSION_NOT_FOUND));
        return WorkoutSessionResponse.fromDetail(updated);
    }

    /**
     * 진행 중인 세션 조회
     */
    @Transactional(readOnly = true)
    public WorkoutSessionResponse getActiveSession(Long userId) {
        WorkoutSession session = sessionRepository
                .findByUserUserIdAndStatus(userId, WorkoutSession.Status.ACTIVE)
                .orElseThrow(() -> new CustomException(ErrorCode.NO_ACTIVE_SESSION));

        WorkoutSession detail = sessionRepository.findByIdWithDetails(session.getSessionId())
                .orElseThrow(() -> new CustomException(ErrorCode.SESSION_NOT_FOUND));
        return WorkoutSessionResponse.fromDetail(detail);
    }

    /**
     * 세션 목록 조회
     */
    @Transactional(readOnly = true)
    public List<WorkoutSessionResponse> getSessionList(Long userId) {
        return sessionRepository.findByUserUserIdOrderByStartTimeDesc(userId)
                .stream()
                .map(WorkoutSessionResponse::from)
                .collect(Collectors.toList());
    }

    /**
     * 세션 상세 조회
     */
    @Transactional(readOnly = true)
    public WorkoutSessionResponse getSessionDetail(Long userId, Long sessionId) {
        getSessionOrThrow(userId, sessionId); // 권한 확인
        WorkoutSession detail = sessionRepository.findByIdWithDetails(sessionId)
                .orElseThrow(() -> new CustomException(ErrorCode.SESSION_NOT_FOUND));
        return WorkoutSessionResponse.fromDetail(detail);
    }

    /**
     * 운동 추가
     */
    @Transactional
    public SessionExerciseResponse addExercise(Long userId, Long sessionId, ExerciseAddRequest request) {
        WorkoutSession session = getSessionOrThrow(userId, sessionId);

        if (session.getStatus() != WorkoutSession.Status.ACTIVE) {
            throw new CustomException(ErrorCode.SESSION_ALREADY_ENDED);
        }

        Exercise exercise = exerciseRepository.findById(request.getExerciseId())
                .orElseThrow(() -> new CustomException(ErrorCode.EXERCISE_NOT_FOUND));

        int orderIndex = sessionExerciseRepository.countBySessionSessionId(sessionId) + 1;

        SessionExercise sessionExercise = SessionExercise.builder()
                .session(session)
                .exercise(exercise)
                .orderIndex(orderIndex)
                .targetSets(request.getTargetSets())
                .targetReps(request.getTargetReps())
                .status(SessionExercise.Status.PENDING)
                .build();

        SessionExercise saved = sessionExerciseRepository.save(sessionExercise);
        return SessionExerciseResponse.from(saved);
    }

    /**
     * 세트 기록
     */
    @Transactional
    public ExerciseSetResponse recordSet(Long userId, Long sessionId, Long sessionExerciseId,
                                         SetRecordRequest request) {
        getSessionOrThrow(userId, sessionId); // 권한 확인

        SessionExercise sessionExercise = sessionExerciseRepository.findById(sessionExerciseId)
                .orElseThrow(() -> new CustomException(ErrorCode.EXERCISE_NOT_FOUND));

        ExerciseSet set = ExerciseSet.builder()
                .sessionExercise(sessionExercise)
                .setNumber(request.getSetNumber())
                .weightKg(request.getWeightKg())
                .reps(request.getReps())
                .isCompleted(request.getIsCompleted())
                .restTimeSec(request.getRestTimeSec())
                .completedAt(request.getIsCompleted() ? LocalDateTime.now() : null)
                .build();

        ExerciseSet saved = exerciseSetRepository.save(set);

        // 완료 세트 수가 목표 세트 수에 도달하면 운동 상태 COMPLETED로 변경
        long completedSets = exerciseSetRepository
                .countBySessionExerciseSessionExerciseIdAndIsCompletedTrue(sessionExerciseId);
        if (completedSets >= sessionExercise.getTargetSets()) {
            sessionExerciseRepository.updateStatus(sessionExerciseId, SessionExercise.Status.COMPLETED);
        } else if (completedSets > 0) {
            sessionExerciseRepository.updateStatus(sessionExerciseId, SessionExercise.Status.IN_PROGRESS);
        }

        return ExerciseSetResponse.from(saved);
    }

    /**
     * 세션 종료 시 개인 기록 갱신
     */
    private void updatePersonalRecords(Long userId, Long sessionId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        List<SessionExercise> exercises = sessionExerciseRepository
                .findBySessionSessionIdOrderByOrderIndexAsc(sessionId);

        for (SessionExercise se : exercises) {
            List<ExerciseSet> sets = exerciseSetRepository
                    .findBySessionExerciseSessionExerciseIdOrderBySetNumberAsc(se.getSessionExerciseId());

            sets.stream()
                .filter(ExerciseSet::getIsCompleted)
                .forEach(set -> {
                    if (set.getWeightKg() != null && set.getReps() != null) {
                        // 1RM 추정 (Epley 공식: weight * (1 + reps/30))
                        BigDecimal oneRm = set.getWeightKg()
                                .multiply(BigDecimal.ONE.add(
                                        new BigDecimal(set.getReps()).divide(new BigDecimal("30"), 2,
                                                java.math.RoundingMode.HALF_UP)));

                        updateRecordIfBetter(user, se.getExercise(),
                                PersonalRecord.RecordType.ONE_RM, oneRm);
                    }
                });
        }
    }

    private void updateRecordIfBetter(User user, Exercise exercise,
                                       PersonalRecord.RecordType type, BigDecimal newValue) {
        personalRecordRepository
                .findByUserUserIdAndExerciseExerciseIdAndRecordType(
                        user.getUserId(), exercise.getExerciseId(), type)
                .ifPresentOrElse(
                        existing -> {
                            if (newValue.compareTo(existing.getValue()) > 0) {
                                PersonalRecord updated = PersonalRecord.builder()
                                        .recordId(existing.getRecordId())
                                        .user(user)
                                        .exercise(exercise)
                                        .recordType(type)
                                        .value(newValue)
                                        .achievedAt(LocalDate.now())
                                        .build();
                                personalRecordRepository.save(updated);
                            }
                        },
                        () -> {
                            PersonalRecord newRecord = PersonalRecord.builder()
                                    .user(user)
                                    .exercise(exercise)
                                    .recordType(type)
                                    .value(newValue)
                                    .achievedAt(LocalDate.now())
                                    .build();
                            personalRecordRepository.save(newRecord);
                        }
                );
    }

    private WorkoutSession getSessionOrThrow(Long userId, Long sessionId) {
        WorkoutSession session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new CustomException(ErrorCode.SESSION_NOT_FOUND));
        if (!session.getUser().getUserId().equals(userId)) {
            throw new CustomException(ErrorCode.FORBIDDEN);
        }
        return session;
    }
}
