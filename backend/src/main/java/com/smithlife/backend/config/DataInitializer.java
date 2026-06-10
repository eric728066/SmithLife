package com.smithlife.backend.config;

import com.smithlife.backend.entity.*;
import com.smithlife.backend.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@Component
@RequiredArgsConstructor
public class DataInitializer implements ApplicationRunner {

    private final FacilityRepository facilityRepository;
    private final ExerciseRepository exerciseRepository;
    private final RoutineRepository routineRepository;
    private final RoutineExerciseRepository routineExerciseRepository;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final AnnouncementRepository announcementRepository;

    @Override
    public void run(ApplicationArguments args) {
        seedAdminUser();
        seedFacility();
        seedExercises();
        seedRecommendedRoutines();
        seedAnnouncements();
    }

    // ─────────────────────────────────────────
    // 관리자 계정 시딩
    // ─────────────────────────────────────────
    private void seedAdminUser() {
        if (userRepository.existsByEmail("admin@smithlife.com")) return;
        User admin = User.builder()
                .email("admin@smithlife.com")
                .passwordHash(passwordEncoder.encode("admin1234"))
                .name("관리자")
                .phone("010-0000-0000")
                .role(User.Role.ADMIN)
                .isActive(true)
                .build();
        userRepository.save(admin);
        log.info("관리자 계정 초기화 완료: admin@smithlife.com");
    }

    // ─────────────────────────────────────────
    // 시설 시딩
    // ─────────────────────────────────────────
    private void seedFacility() {
        if (facilityRepository.count() > 0) return;
        Facility facility = Facility.builder()
                .name("메인 피트니스 존")
                .description("스미스라이프 메인 운동 공간")
                .maxCapacity(20)
                .isActive(true)
                .build();
        facilityRepository.save(facility);
        log.info("기본 시설 데이터 초기화 완료");
    }

    // ─────────────────────────────────────────
    // 운동 목록 시딩 (89개)
    // ─────────────────────────────────────────
    private void seedExercises() {
        if (exerciseRepository.count() > 0) return;

        List<Exercise> exercises = List.of(
                // ── 가슴 ──
                ex("바벨 벤치 프레스",         "가슴", "가슴"),
                ex("인클라인 바벨 프레스",      "가슴", "가슴 상부"),
                ex("디클라인 바벨 프레스",      "가슴", "가슴 하부"),
                ex("인클라인 덤벨 프레스",      "가슴", "가슴 상부"),
                ex("덤벨 플라이",              "가슴", "가슴"),
                ex("인클라인 덤벨 플라이",      "가슴", "가슴 상부"),
                ex("케이블 크로스오버",         "가슴", "가슴 내측"),
                ex("딥스",                     "가슴", "가슴/삼두"),
                ex("푸쉬업",                   "가슴", "가슴"),
                ex("머신 체스트 프레스",        "가슴", "가슴"),
                ex("펙덱 플라이",              "가슴", "가슴 내측"),
                ex("클로즈그립 벤치 프레스",    "가슴", "가슴/삼두"),

                // ── 등 ──
                ex("바벨 로우",                "등", "등 중부"),
                ex("덤벨 로우",                "등", "등"),
                ex("원암 덤벨 로우",            "등", "등 측면"),
                ex("풀업",                     "등", "광배근"),
                ex("친업",                     "등", "광배근/이두"),
                ex("랫 풀다운",                "등", "광배근"),
                ex("시티드 케이블 로우",        "등", "등 하부"),
                ex("T바 로우",                 "등", "등 중부"),
                ex("페이스 풀",                "등", "후면 삼각근/등"),
                ex("스트레이트암 풀다운",        "등", "광배근"),
                ex("하이퍼익스텐션",            "등", "척추기립근"),
                ex("슈러그",                   "등", "승모근"),
                ex("머신 로우",                "등", "등 중부"),

                // ── 어깨 ──
                ex("바벨 오버헤드 프레스",      "어깨", "전면 삼각근"),
                ex("덤벨 숄더 프레스",          "어깨", "삼각근"),
                ex("아놀드 프레스",             "어깨", "삼각근"),
                ex("사이드 레터럴 레이즈",       "어깨", "측면 삼각근"),
                ex("프론트 레이즈",             "어깨", "전면 삼각근"),
                ex("리어 델트 플라이",          "어깨", "후면 삼각근"),
                ex("업라이트 로우",             "어깨", "삼각근/승모근"),
                ex("케이블 레터럴 레이즈",       "어깨", "측면 삼각근"),
                ex("머신 숄더 프레스",          "어깨", "삼각근"),
                ex("케이블 페이스 풀",          "어깨", "후면 삼각근"),

                // ── 삼두 ──
                ex("케이블 푸쉬다운",            "삼두", "삼두"),
                ex("로프 푸쉬다운",              "삼두", "삼두"),
                ex("오버헤드 트라이셉스 익스텐션", "삼두", "삼두 장두"),
                ex("스컬크러셔",                 "삼두", "삼두"),
                ex("킥백",                       "삼두", "삼두"),
                ex("다이아몬드 푸쉬업",           "삼두", "삼두"),
                ex("벤치 딥스",                  "삼두", "삼두"),

                // ── 이두 ──
                ex("바벨 컬",                    "이두", "이두"),
                ex("덤벨 컬",                    "이두", "이두"),
                ex("해머 컬",                    "이두", "이두/완요골근"),
                ex("인클라인 덤벨 컬",            "이두", "이두 장두"),
                ex("케이블 컬",                  "이두", "이두"),
                ex("컨센트레이션 컬",             "이두", "이두"),
                ex("프리처 컬",                  "이두", "이두 단두"),
                ex("리버스 컬",                  "이두", "완요골근"),
                ex("머신 컬",                    "이두", "이두"),

                // ── 하체 ──
                ex("바벨 스쿼트",                "하체", "대퇴사두/둔근"),
                ex("레그 프레스",                "하체", "대퇴사두"),
                ex("루마니안 데드리프트",          "하체", "햄스트링/둔근"),
                ex("레그 컬",                    "하체", "햄스트링"),
                ex("레그 익스텐션",               "하체", "대퇴사두"),
                ex("카프 레이즈",                "하체", "종아리"),
                ex("런지",                       "하체", "대퇴사두/둔근"),
                ex("불가리안 스플릿 스쿼트",       "하체", "대퇴사두/둔근"),
                ex("고블릿 스쿼트",               "하체", "대퇴사두"),
                ex("핵 스쿼트",                  "하체", "대퇴사두"),
                ex("힙 스러스트",                "하체", "둔근"),
                ex("수모 스쿼트",                "하체", "내전근/둔근"),
                ex("스텝업",                     "하체", "대퇴사두/둔근"),
                ex("시시 스쿼트",                "하체", "대퇴사두"),
                ex("씨티드 카프 레이즈",           "하체", "종아리 가자미근"),
                ex("힙 어브덕션",                "하체", "둔근 중부"),

                // ── 코어 ──
                ex("플랭크",                     "코어", "코어"),
                ex("크런치",                     "코어", "복직근"),
                ex("레그 레이즈",                "코어", "하복부"),
                ex("러시안 트위스트",             "코어", "복사근"),
                ex("AB 롤아웃",                  "코어", "코어"),
                ex("케이블 크런치",               "코어", "복직근"),
                ex("사이드 플랭크",               "코어", "복사근"),
                ex("마운틴 클라이머",             "코어", "코어/전신"),
                ex("바이시클 크런치",             "코어", "복사근"),
                ex("행잉 레그 레이즈",            "코어", "하복부"),
                ex("브이업",                     "코어", "복직근"),
                ex("드래곤 플래그",               "코어", "코어"),

                // ── 전신 ──
                ex("데드리프트",                 "전신", "전신/척추기립근"),
                ex("파워 클린",                  "전신", "전신"),
                ex("케틀벨 스윙",                "전신", "전신/둔근"),
                ex("박스 점프",                  "전신", "전신"),
                ex("버피",                       "전신", "전신"),
                ex("배틀 로프",                  "전신", "전신"),
                ex("바벨 스내치",                "전신", "전신"),
                ex("터키시 겟업",                "전신", "전신"),
                ex("메디신볼 슬램",              "전신", "전신/코어")
        );

        exerciseRepository.saveAll(exercises);
        log.info("운동 데이터 초기화 완료: {}개", exercises.size());
    }

    // ─────────────────────────────────────────
    // 추천 루틴 시딩 (6개)
    // ─────────────────────────────────────────
    private void seedRecommendedRoutines() {
        if (routineRepository.existsByIsRecommendedTrue()) return;

        Map<String, Exercise> exMap = exerciseRepository.findAll().stream()
                .collect(Collectors.toMap(Exercise::getName, e -> e));

        // 1. 가슴 & 삼두 (PPL Push Day)
        Routine r1 = saveRoutine("가슴 & 삼두",
                Routine.Goal.MUSCLE_GAIN, Routine.Difficulty.INTERMEDIATE,
                60, "주 2회", "PPL 루틴의 Push Day. 가슴과 삼두를 집중 공략합니다.");
        addEx(exMap, r1, "바벨 벤치 프레스",          1, 4);
        addEx(exMap, r1, "인클라인 덤벨 프레스",       2, 4);
        addEx(exMap, r1, "딥스",                      3, 3);
        addEx(exMap, r1, "케이블 크로스오버",           4, 3);
        addEx(exMap, r1, "케이블 푸쉬다운",             5, 4);
        addEx(exMap, r1, "오버헤드 트라이셉스 익스텐션", 6, 3);

        // 2. 등 & 이두 (PPL Pull Day)
        Routine r2 = saveRoutine("등 & 이두",
                Routine.Goal.MUSCLE_GAIN, Routine.Difficulty.INTERMEDIATE,
                65, "주 2회", "PPL 루틴의 Pull Day. 광배근과 이두를 집중 공략합니다.");
        addEx(exMap, r2, "바벨 로우",        1, 4);
        addEx(exMap, r2, "풀업",             2, 4);
        addEx(exMap, r2, "랫 풀다운",        3, 4);
        addEx(exMap, r2, "시티드 케이블 로우", 4, 3);
        addEx(exMap, r2, "바벨 컬",          5, 4);
        addEx(exMap, r2, "해머 컬",          6, 3);

        // 3. 하체 데이 (Leg Day)
        Routine r3 = saveRoutine("하체 데이",
                Routine.Goal.MUSCLE_GAIN, Routine.Difficulty.ADVANCED,
                70, "주 2회", "PPL 루틴의 Leg Day. 대퇴사두, 햄스트링, 종아리를 모두 자극합니다.");
        addEx(exMap, r3, "바벨 스쿼트",      1, 5);
        addEx(exMap, r3, "레그 프레스",       2, 4);
        addEx(exMap, r3, "루마니안 데드리프트", 3, 4);
        addEx(exMap, r3, "레그 컬",          4, 4);
        addEx(exMap, r3, "레그 익스텐션",     5, 3);
        addEx(exMap, r3, "카프 레이즈",       6, 5);

        // 4. 어깨 & 코어 (Shoulder + Core)
        Routine r4 = saveRoutine("어깨 & 코어",
                Routine.Goal.MUSCLE_GAIN, Routine.Difficulty.INTERMEDIATE,
                55, "주 2회", "삼각근 3두와 코어를 함께 단련하는 루틴입니다.");
        addEx(exMap, r4, "바벨 오버헤드 프레스", 1, 4);
        addEx(exMap, r4, "덤벨 숄더 프레스",    2, 4);
        addEx(exMap, r4, "사이드 레터럴 레이즈", 3, 4);
        addEx(exMap, r4, "리어 델트 플라이",    4, 4);
        addEx(exMap, r4, "페이스 풀",           5, 3);
        addEx(exMap, r4, "플랭크",              6, 3);

        // 5. 전신 스트렝스 (Full Body — Beginner)
        Routine r5 = saveRoutine("전신 스트렝스",
                Routine.Goal.STAMINA, Routine.Difficulty.BEGINNER,
                60, "주 3회", "초보자를 위한 전신 스트렝스 루틴. 3대 운동 기반으로 체력을 키웁니다.");
        addEx(exMap, r5, "바벨 스쿼트",      1, 4);
        addEx(exMap, r5, "바벨 벤치 프레스",  2, 4);
        addEx(exMap, r5, "바벨 로우",         3, 4);
        addEx(exMap, r5, "바벨 오버헤드 프레스", 4, 3);
        addEx(exMap, r5, "풀업",              5, 3);
        addEx(exMap, r5, "루마니안 데드리프트", 6, 3);

        // 6. 파워리프팅 3대 (Big 3)
        Routine r6 = saveRoutine("파워리프팅 3대",
                Routine.Goal.MUSCLE_GAIN, Routine.Difficulty.ADVANCED,
                75, "주 3회", "스쿼트·벤치·데드를 중심으로 최대 근력을 끌어올리는 파워리프팅 루틴.");
        addEx(exMap, r6, "바벨 스쿼트",         1, 5);
        addEx(exMap, r6, "바벨 벤치 프레스",    2, 5);
        addEx(exMap, r6, "데드리프트",          3, 3);
        addEx(exMap, r6, "바벨 오버헤드 프레스", 4, 4);
        addEx(exMap, r6, "바벨 로우",           5, 4);

        log.info("추천 루틴 데이터 초기화 완료: 6개");
    }

    // ─────────────────────────────────────────
    // 공지사항 시딩
    // ─────────────────────────────────────────
    private void seedAnnouncements() {
        announcementRepository.deleteAll();

        List<Announcement> announcements = List.of(
            Announcement.builder()
                .title("스미스라이프 헬스장 오픈 안내")
                .content("안녕하세요, 스미스라이프입니다.\n\n저희 헬스장이 정식 오픈하였습니다.\n\n운영 시간: 평일 06:00 ~ 23:00 / 주말 08:00 ~ 21:00\n\n회원 여러분의 많은 이용 바랍니다.")
                .tag(Announcement.Tag.NOTICE)
                .isNew(true)
                .isActive(true)
                .publishedAt(java.time.LocalDateTime.now().minusDays(1))
                .build(),
            Announcement.builder()
                .title("3월 휴관 안내 (3/25 정기점검)")
                .content("안녕하세요, 스미스라이프입니다.\n\n2025년 3월 25일(화)은 시설 정기점검으로 인해 하루 휴관합니다.\n\n이용에 불편을 드려 죄송합니다.")
                .tag(Announcement.Tag.NOTICE)
                .isNew(true)
                .isActive(true)
                .publishedAt(java.time.LocalDateTime.now().minusDays(3))
                .build(),
            Announcement.builder()
                .title("신규 장비 입고 안내 — 케이블 머신 추가")
                .content("회원 여러분의 요청으로 케이블 크로스오버 머신이 추가 입고되었습니다.\n\n위치: 2층 프리웨이트 구역\n\n더 쾌적한 환경을 위해 지속적으로 시설을 개선하겠습니다.")
                .tag(Announcement.Tag.NOTICE)
                .isNew(false)
                .isActive(true)
                .publishedAt(java.time.LocalDateTime.now().minusDays(7))
                .build(),
            Announcement.builder()
                .title("4월 신규 회원 등록 이벤트")
                .content("4월 한 달간 신규 등록 회원에게 특별 혜택을 드립니다!\n\n✅ 3개월 등록 시 1개월 무료 연장\n✅ PT 체험권 1회 증정\n\n기간: 2025년 4월 1일 ~ 4월 30일\n\n친구와 함께 등록하면 추가 할인 혜택도 있으니 많이 이용해주세요.")
                .tag(Announcement.Tag.EVENT)
                .isNew(true)
                .isActive(true)
                .publishedAt(java.time.LocalDateTime.now().minusDays(5))
                .build(),
            Announcement.builder()
                .title("샤워실 리모델링 완료 안내")
                .content("그동안 불편을 드렸던 샤워실 리모델링이 완료되었습니다.\n\n새로 교체된 사항:\n- 온수 시스템 전면 교체\n- 개인 락커 추가 (총 50개)\n- 드라이어 설치\n\n쾌적한 이용 환경을 만들기 위해 노력하겠습니다.")
                .tag(Announcement.Tag.NOTICE)
                .isNew(false)
                .isActive(true)
                .publishedAt(java.time.LocalDateTime.now().minusDays(14))
                .build()
        );

        announcementRepository.saveAll(announcements);
        log.info("공지사항 데이터 초기화 완료: {}개", announcements.size());
    }

    // ─────────────────────────────────────────
    // 헬퍼 메서드
    // ─────────────────────────────────────────
    private Exercise ex(String name, String bodyPart, String equipment) {
        return Exercise.builder()
                .name(name)
                .bodyPart(bodyPart)
                .equipment(equipment)
                .build();
    }

    private Routine saveRoutine(String name, Routine.Goal goal, Routine.Difficulty difficulty,
                                int estimatedMin, String frequency, String description) {
        return routineRepository.save(Routine.builder()
                .name(name)
                .goal(goal)
                .difficulty(difficulty)
                .estimatedMin(estimatedMin)
                .frequency(frequency)
                .description(description)
                .isPublic(true)
                .isRecommended(true)
                .build());
    }

    private void addEx(Map<String, Exercise> exMap, Routine routine,
                       String exerciseName, int order, int sets) {
        Exercise exercise = exMap.get(exerciseName);
        if (exercise == null) {
            log.warn("운동을 찾을 수 없습니다: {}", exerciseName);
            return;
        }
        routineExerciseRepository.save(RoutineExercise.builder()
                .routine(routine)
                .exercise(exercise)
                .orderIndex(order)
                .targetSets(sets)
                .targetRepsMin(8)
                .targetRepsMax(12)
                .build());
    }
}
