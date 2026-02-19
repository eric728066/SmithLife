package com.smithlife.backend.service;

import com.smithlife.backend.common.ErrorCode;
import com.smithlife.backend.dto.response.WeeklyStatsResponse;
import com.smithlife.backend.dto.response.WorkoutReportResponse;
import com.smithlife.backend.entity.User;
import com.smithlife.backend.entity.WorkoutReport;
import com.smithlife.backend.entity.WorkoutSession;
import com.smithlife.backend.exception.CustomException;
import com.smithlife.backend.repository.UserRepository;
import com.smithlife.backend.repository.WorkoutReportRepository;
import com.smithlife.backend.repository.WorkoutSessionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class WorkoutReportService {

    private final WorkoutReportRepository reportRepository;
    private final WorkoutSessionRepository sessionRepository;
    private final UserRepository userRepository;

    private static final String[] MOTIVATION_MESSAGES = {
            "오늘도 최선을 다했어요! 내일은 더 강해질 거예요.",
            "꾸준함이 실력이 됩니다. 계속 화이팅!",
            "운동하는 습관, 당신의 미래를 바꿉니다.",
            "오늘의 땀이 내일의 결과를 만들어요.",
            "포기하지 않는 당신이 진짜 챔피언입니다!"
    };

    /**
     * 세션 종료 후 리포트 생성
     */
    @Transactional
    public WorkoutReportResponse generateReport(Long userId, Long sessionId) {
        // 이미 리포트가 있으면 반환
        return reportRepository.findBySessionSessionId(sessionId)
                .map(WorkoutReportResponse::from)
                .orElseGet(() -> createReport(userId, sessionId));
    }

    private WorkoutReportResponse createReport(Long userId, Long sessionId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        WorkoutSession session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new CustomException(ErrorCode.SESSION_NOT_FOUND));

        if (!session.getUser().getUserId().equals(userId)) {
            throw new CustomException(ErrorCode.FORBIDDEN);
        }

        if (session.getStatus() != WorkoutSession.Status.COMPLETED) {
            throw new CustomException(ErrorCode.SESSION_ALREADY_ENDED);
        }

        // 주간 변화율 계산
        LocalDate today = LocalDate.now();
        LocalDate thisWeekStart = today.with(DayOfWeek.MONDAY);
        LocalDate lastWeekStart = thisWeekStart.minusWeeks(1);
        LocalDate lastWeekEnd = thisWeekStart.minusDays(1);

        BigDecimal thisWeekVolume = reportRepository.sumVolumeByUserAndDateRange(
                userId, thisWeekStart, today);
        BigDecimal lastWeekVolume = reportRepository.sumVolumeByUserAndDateRange(
                userId, lastWeekStart, lastWeekEnd);

        BigDecimal weeklyChangePct = null;
        if (lastWeekVolume.compareTo(BigDecimal.ZERO) > 0) {
            weeklyChangePct = thisWeekVolume.subtract(lastWeekVolume)
                    .divide(lastWeekVolume, 2, RoundingMode.HALF_UP)
                    .multiply(new BigDecimal("100"));
        }

        // 동기 메시지 선택
        String motivationMsg = selectMotivationMsg(weeklyChangePct);

        WorkoutReport report = WorkoutReport.builder()
                .user(user)
                .session(session)
                .reportDate(today)
                .totalTimeSec(session.getTotalDurationSec())
                .totalVolumeKg(session.getTotalVolumeKg())
                .totalCalories(session.getTotalCalories())
                .weeklyChangePct(weeklyChangePct)
                .motivationMsg(motivationMsg)
                .build();

        WorkoutReport saved = reportRepository.save(report);
        return WorkoutReportResponse.from(saved);
    }

    /**
     * 리포트 상세 조회
     */
    @Transactional(readOnly = true)
    public WorkoutReportResponse getReportDetail(Long userId, Long reportId) {
        WorkoutReport report = reportRepository.findById(reportId)
                .orElseThrow(() -> new CustomException(ErrorCode.RESOURCE_NOT_FOUND));

        if (!report.getUser().getUserId().equals(userId)) {
            throw new CustomException(ErrorCode.FORBIDDEN);
        }

        return WorkoutReportResponse.from(report);
    }

    /**
     * 내 리포트 목록 조회
     */
    @Transactional(readOnly = true)
    public List<WorkoutReportResponse> getMyReports(Long userId) {
        return reportRepository.findByUserUserIdOrderByReportDateDesc(userId)
                .stream()
                .map(WorkoutReportResponse::from)
                .collect(Collectors.toList());
    }

    /**
     * 주간 통계 조회
     */
    @Transactional(readOnly = true)
    public WeeklyStatsResponse getWeeklyStats(Long userId) {
        LocalDate today = LocalDate.now();
        LocalDate weekStart = today.with(DayOfWeek.MONDAY);
        LocalDate weekEnd = weekStart.plusDays(6);

        List<WorkoutReport> weeklyReports = reportRepository
                .findByUserUserIdAndReportDateBetweenOrderByReportDateAsc(userId, weekStart, weekEnd);

        // 날짜별 그룹핑
        Map<LocalDate, List<WorkoutReport>> byDate = weeklyReports.stream()
                .collect(Collectors.groupingBy(WorkoutReport::getReportDate));

        // 7일치 일별 통계 생성
        List<WeeklyStatsResponse.DailyStatResponse> dailyStats = new ArrayList<>();
        for (int i = 0; i < 7; i++) {
            LocalDate date = weekStart.plusDays(i);
            List<WorkoutReport> dayReports = byDate.getOrDefault(date, List.of());

            BigDecimal dailyVolume = dayReports.stream()
                    .map(WorkoutReport::getTotalVolumeKg)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            int dailyTime = dayReports.stream()
                    .mapToInt(WorkoutReport::getTotalTimeSec)
                    .sum();

            dailyStats.add(WeeklyStatsResponse.DailyStatResponse.builder()
                    .date(date)
                    .workoutCount(dayReports.size())
                    .volumeKg(dailyVolume)
                    .timeSec(dailyTime)
                    .build());
        }

        // 주간 합계
        BigDecimal totalVolume = weeklyReports.stream()
                .map(WorkoutReport::getTotalVolumeKg)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal totalCalories = weeklyReports.stream()
                .map(WorkoutReport::getTotalCalories)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        int totalTime = weeklyReports.stream()
                .mapToInt(WorkoutReport::getTotalTimeSec)
                .sum();

        return WeeklyStatsResponse.builder()
                .weekStart(weekStart)
                .weekEnd(weekEnd)
                .totalWorkouts(weeklyReports.size())
                .totalTimeSec(totalTime)
                .totalVolumeKg(totalVolume)
                .totalCalories(totalCalories)
                .dailyStats(dailyStats)
                .build();
    }

    private String selectMotivationMsg(BigDecimal weeklyChangePct) {
        if (weeklyChangePct == null) {
            return MOTIVATION_MESSAGES[0];
        }
        if (weeklyChangePct.compareTo(BigDecimal.TEN) >= 0) {
            return "지난주보다 " + weeklyChangePct.setScale(1, RoundingMode.HALF_UP) + "% 더 열심히 했어요! 대단해요!";
        }
        if (weeklyChangePct.compareTo(BigDecimal.ZERO) >= 0) {
            return MOTIVATION_MESSAGES[1];
        }
        return MOTIVATION_MESSAGES[4];
    }
}
