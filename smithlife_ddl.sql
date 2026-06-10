-- ============================================================
-- SmithLife (스미스라이프) Database DDL
-- MySQL 8.0+
-- 19개 UI 화면 분석 기반 ERD → SQL 변환
-- ============================================================

DROP DATABASE IF EXISTS smithlife;
CREATE DATABASE smithlife
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE smithlife;

-- ============================================================
-- 1. User (회원)
-- 관련 화면: 로그인, 회원가입, 내정보(김스미스님), 설정(smith@example.com)
-- ============================================================
CREATE TABLE `user` (
    `user_id`           BIGINT          NOT NULL AUTO_INCREMENT,
    `email`             VARCHAR(100)    NOT NULL COMMENT '로그인 이메일 (아이디)',
    `password_hash`     VARCHAR(255)    NOT NULL COMMENT 'bcrypt 암호화 비밀번호',
    `name`              VARCHAR(50)     NOT NULL COMMENT '회원 이름 (예: 김스미스)',
    `phone`             VARCHAR(20)     NOT NULL COMMENT '전화번호 (010-XXXX-XXXX)',
    `profile_image_url` VARCHAR(500)    NULL     COMMENT '프로필 사진 URL',
    `role`              ENUM('USER', 'ADMIN') NOT NULL DEFAULT 'USER' COMMENT '역할',
    `is_active`         BOOLEAN         NOT NULL DEFAULT TRUE COMMENT '활성 여부 (탈퇴 시 FALSE)',
    `created_at`        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '가입일시',
    `updated_at`        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시',

    PRIMARY KEY (`user_id`),
    UNIQUE KEY `uk_user_email` (`email`),
    UNIQUE KEY `uk_user_phone` (`phone`)
) ENGINE=InnoDB COMMENT='회원 (로그인/회원가입/내정보)';


-- ============================================================
-- 2. Membership (회원권)
-- 관련 화면: 홈(D-45일 카드), 내정보(3개월 정기권, D-42), 알림(회원권 만료 D-7)
-- ============================================================
CREATE TABLE `membership` (
    `membership_id`     BIGINT          NOT NULL AUTO_INCREMENT,
    `user_id`           BIGINT          NOT NULL COMMENT '회원 FK',
    `type`              VARCHAR(50)     NOT NULL COMMENT '회원권 종류 (1개월/3개월/6개월/12개월)',
    `start_date`        DATE            NOT NULL COMMENT '시작일',
    `end_date`          DATE            NOT NULL COMMENT '만료일',
    `status`            ENUM('ACTIVE', 'EXPIRED', 'PAUSED', 'CANCELLED') NOT NULL DEFAULT 'ACTIVE' COMMENT '상태',
    `created_at`        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (`membership_id`),
    KEY `idx_membership_user` (`user_id`),
    KEY `idx_membership_status` (`status`),
    KEY `idx_membership_end_date` (`end_date`),

    CONSTRAINT `fk_membership_user`
        FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='회원권 (홈 D-day, 내정보 정기권)';


-- ============================================================
-- 3. UserSettings (사용자 설정)
-- 관련 화면: 설정(알림설정, 다크모드 "시스템 설정", 언어 "한국어")
-- ============================================================
CREATE TABLE `user_settings` (
    `setting_id`            BIGINT      NOT NULL AUTO_INCREMENT,
    `user_id`               BIGINT      NOT NULL COMMENT '회원 FK (1:1)',
    `notification_enabled`  BOOLEAN     NOT NULL DEFAULT TRUE COMMENT '알림 수신 여부',
    `dark_mode`             ENUM('SYSTEM', 'ON', 'OFF') NOT NULL DEFAULT 'SYSTEM' COMMENT '다크모드 (시스템설정/켜기/끄기)',
    `language`              VARCHAR(10) NOT NULL DEFAULT 'ko' COMMENT '언어 (ko/en/ja 등)',
    `updated_at`            DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (`setting_id`),
    UNIQUE KEY `uk_settings_user` (`user_id`),

    CONSTRAINT `fk_settings_user`
        FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='사용자 설정 (알림/다크모드/언어)';


-- ============================================================
-- 4. Attendance (출석)
-- 관련 화면: QR 체크인 모달(QR코드), 내정보(참석율 92%)
-- ============================================================
CREATE TABLE `attendance` (
    `attendance_id`     BIGINT          NOT NULL AUTO_INCREMENT,
    `user_id`           BIGINT          NOT NULL COMMENT '회원 FK',
    `check_in_time`     DATETIME        NOT NULL COMMENT '입장(체크인) 시간',
    `check_out_time`    DATETIME        NULL     COMMENT '퇴장(체크아웃) 시간',
    `qr_token`          VARCHAR(255)    NOT NULL COMMENT 'QR 인증 토큰 (1회성, 시간 제한)',
    `status`            ENUM('CHECKED_IN', 'CHECKED_OUT') NOT NULL DEFAULT 'CHECKED_IN' COMMENT '상태',
    `created_at`        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (`attendance_id`),
    KEY `idx_attendance_user` (`user_id`),
    KEY `idx_attendance_date` (`check_in_time`),

    CONSTRAINT `fk_attendance_user`
        FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='출석 기록 (QR 체크인)';


-- ============================================================
-- 5. Facility (시설)
-- 관련 화면: 홈(메인 피트니스 존), 예약 시간표, 이용내역
-- ============================================================
CREATE TABLE `facility` (
    `facility_id`       BIGINT          NOT NULL AUTO_INCREMENT,
    `name`              VARCHAR(100)    NOT NULL COMMENT '시설명 (메인 피트니스 존, 스튜디오 A 등)',
    `description`       VARCHAR(500)    NULL     COMMENT '시설 설명',
    `max_capacity`      INT             NOT NULL COMMENT '최대 수용 인원',
    `is_active`         BOOLEAN         NOT NULL DEFAULT TRUE,

    PRIMARY KEY (`facility_id`)
) ENGINE=InnoDB COMMENT='시설 (메인 피트니스 존, 스튜디오 등)';


-- ============================================================
-- 6. TimeSlot (시간 슬롯)
-- 관련 화면: 예약 시간표(09:00~16:00, 초록 원활/노랑 보통/빨강 혼잡)
-- ============================================================
CREATE TABLE `time_slot` (
    `slot_id`           BIGINT          NOT NULL AUTO_INCREMENT,
    `facility_id`       BIGINT          NOT NULL COMMENT '시설 FK',
    `date`              DATE            NOT NULL COMMENT '날짜 (2026년 2월 10일)',
    `start_time`        TIME            NOT NULL COMMENT '시작 시간 (09:00)',
    `end_time`          TIME            NOT NULL COMMENT '종료 시간 (10:00)',
    `max_capacity`      INT             NOT NULL COMMENT '슬롯별 최대 수용',
    `current_count`     INT             NOT NULL DEFAULT 0 COMMENT '현재 예약 인원',

    PRIMARY KEY (`slot_id`),
    UNIQUE KEY `uk_slot` (`facility_id`, `date`, `start_time`),
    KEY `idx_slot_date` (`date`),

    CONSTRAINT `fk_slot_facility`
        FOREIGN KEY (`facility_id`) REFERENCES `facility` (`facility_id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='시간 슬롯 (예약 시간표 09:00~16:00)';


-- ============================================================
-- 7. Reservation (예약)
-- 관련 화면: 예약 모달(예약하기/닫기), 취소 모달(취소하기/닫기),
--           홈(다음 예약 09:00-10:30 메인 피트니스 존),
--           이용내역(예약번호 #8812), 알림(예약 확정)
-- ============================================================
CREATE TABLE `reservation` (
    `reservation_id`    BIGINT          NOT NULL AUTO_INCREMENT,
    `user_id`           BIGINT          NOT NULL COMMENT '회원 FK',
    `slot_id`           BIGINT          NOT NULL COMMENT '시간 슬롯 FK',
    `reservation_no`    VARCHAR(20)     NOT NULL COMMENT '예약번호 (예: #8812)',
    `status`            ENUM('CONFIRMED', 'CANCELLED', 'COMPLETED', 'NO_SHOW') NOT NULL DEFAULT 'CONFIRMED' COMMENT '상태',
    `reserved_at`       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '예약일시',
    `cancelled_at`      DATETIME        NULL     COMMENT '취소일시',

    PRIMARY KEY (`reservation_id`),
    UNIQUE KEY `uk_reservation_no` (`reservation_no`),
    KEY `idx_reservation_user` (`user_id`),
    KEY `idx_reservation_slot` (`slot_id`),
    KEY `idx_reservation_status` (`status`),

    CONSTRAINT `fk_reservation_user`
        FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_reservation_slot`
        FOREIGN KEY (`slot_id`) REFERENCES `time_slot` (`slot_id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='예약 (예약하기/취소하기 모달, 홈 다음 예약 카드)';


-- ============================================================
-- 8. UsageHistory (이용내역)
-- 관련 화면: 이용내역 리스트(시설 이용 09:00-11:00, 2026.01.28, 예약번호 #8812, 이용완료)
-- ============================================================
CREATE TABLE `usage_history` (
    `usage_id`          BIGINT          NOT NULL AUTO_INCREMENT,
    `user_id`           BIGINT          NOT NULL COMMENT '회원 FK',
    `reservation_id`    BIGINT          NULL     COMMENT '예약 FK (예약 기반 이용일 때)',
    `facility_name`     VARCHAR(100)    NOT NULL COMMENT '시설명 (시설 이용)',
    `usage_date`        DATE            NOT NULL COMMENT '이용 날짜',
    `start_time`        TIME            NOT NULL COMMENT '시작 시간 (09:00)',
    `end_time`          TIME            NOT NULL COMMENT '종료 시간 (11:00)',
    `status`            ENUM('COMPLETED', 'CANCELLED', 'NO_SHOW') NOT NULL COMMENT '상태 (이용완료/취소/노쇼)',
    `created_at`        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (`usage_id`),
    KEY `idx_usage_user` (`user_id`),
    KEY `idx_usage_date` (`usage_date` DESC),
    KEY `idx_usage_reservation` (`reservation_id`),

    CONSTRAINT `fk_usage_user`
        FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_usage_reservation`
        FOREIGN KEY (`reservation_id`) REFERENCES `reservation` (`reservation_id`)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='이용내역 (시설이용 09:00-11:00, 예약번호#8812, 이용완료)';


-- ============================================================
-- 9. Exercise (운동 종목)
-- 관련 화면: 운동 상세(벤치 프레스, 가슴 태그, 목표 4세트 12회),
--           루틴 상세(벤치프레스 가슴-바벨 3세트 10-12회, 바벨스쿼트 하체-바벨, 랫풀다운 등-케이블)
--           운동 메인(벤치 프레스 가슴, 케이블 푸쉬다운 삼두)
-- ============================================================
CREATE TABLE `exercise` (
    `exercise_id`       BIGINT          NOT NULL AUTO_INCREMENT,
    `name`              VARCHAR(100)    NOT NULL COMMENT '운동명 (벤치 프레스, 케이블 푸쉬다운, 바벨 스쿼트 등)',
    `body_part`         VARCHAR(50)     NOT NULL COMMENT '부위 (가슴/하체/등/어깨/삼두/코어 등)',
    `equipment`         VARCHAR(50)     NULL     COMMENT '장비 (바벨/덤벨/케이블/머신/맨몸 등)',
    `image_url`         VARCHAR(500)    NULL     COMMENT '운동 이미지 URL',
    `description`       TEXT            NULL     COMMENT '운동 설명',
    `created_at`        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (`exercise_id`),
    KEY `idx_exercise_body_part` (`body_part`),
    KEY `idx_exercise_name` (`name`)
) ENGINE=InnoDB COMMENT='운동 종목 (벤치프레스/스쿼트/랫풀다운 등)';


-- ============================================================
-- 10. Routine (루틴)
-- 관련 화면: 추천 루틴 목록(파워빌딩 주3회 45분 입문, 데일리컷팅 매일 30분 중급...8개),
--           루틴 만들기(루틴이름, 운동목표 근성장/다이어트/체력증진, 공유토글),
--           루틴 상세(초보자 파워빌딩, 45분, 근비대, 초보자)
-- ============================================================
CREATE TABLE `routine` (
    `routine_id`        BIGINT          NOT NULL AUTO_INCREMENT,
    `creator_id`        BIGINT          NULL     COMMENT '생성자 FK (추천 루틴은 NULL)',
    `name`              VARCHAR(100)    NOT NULL COMMENT '루틴명 (파워 빌딩, 데일리 컷팅 등)',
    `goal`              ENUM('MUSCLE_GAIN', 'DIET', 'STAMINA') NOT NULL COMMENT '목표 (근성장/다이어트/체력증진)',
    `difficulty`        ENUM('BEGINNER', 'INTERMEDIATE', 'ADVANCED') NOT NULL COMMENT '난이도 (입문/중급/고급)',
    `estimated_min`     INT             NOT NULL COMMENT '소요시간(분) (45, 30, 60 등)',
    `frequency`         VARCHAR(50)     NULL     COMMENT '빈도 (주 3회, 매일, 주 5회 등)',
    `description`       TEXT            NULL     COMMENT '설명 (기초 근력 향상과 근비대를 위한...)',
    `image_url`         VARCHAR(500)    NULL     COMMENT '대표 이미지 URL',
    `is_public`         BOOLEAN         NOT NULL DEFAULT FALSE COMMENT '탐색 탭 공유 여부',
    `is_recommended`    BOOLEAN         NOT NULL DEFAULT FALSE COMMENT '추천 루틴 여부',
    `created_at`        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (`routine_id`),
    KEY `idx_routine_creator` (`creator_id`),
    KEY `idx_routine_recommended` (`is_recommended`),
    KEY `idx_routine_goal` (`goal`),

    CONSTRAINT `fk_routine_creator`
        FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='루틴 (추천 루틴 + 나만의 루틴)';


-- ============================================================
-- 11. RoutineExercise (루틴-운동 구성)
-- 관련 화면: 루틴 상세(벤치프레스 3세트 10-12회, 바벨스쿼트 4세트 8-10회,
--           랫풀다운 3세트 12회, 덤벨숄더프레스 4세트 12-15회)
-- ============================================================
CREATE TABLE `routine_exercise` (
    `routine_exercise_id` BIGINT        NOT NULL AUTO_INCREMENT,
    `routine_id`        BIGINT          NOT NULL COMMENT '루틴 FK',
    `exercise_id`       BIGINT          NOT NULL COMMENT '운동 FK',
    `order_index`       INT             NOT NULL COMMENT '운동 순서 (1, 2, 3, 4...)',
    `target_sets`       INT             NOT NULL COMMENT '목표 세트 수 (3, 4)',
    `target_reps_min`   INT             NOT NULL COMMENT '최소 목표 횟수 (10, 8, 12)',
    `target_reps_max`   INT             NULL     COMMENT '최대 목표 횟수 (12, 10, 15) NULL이면 고정횟수',

    PRIMARY KEY (`routine_exercise_id`),
    UNIQUE KEY `uk_routine_exercise_order` (`routine_id`, `order_index`),
    KEY `idx_re_exercise` (`exercise_id`),

    CONSTRAINT `fk_re_routine`
        FOREIGN KEY (`routine_id`) REFERENCES `routine` (`routine_id`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_re_exercise`
        FOREIGN KEY (`exercise_id`) REFERENCES `exercise` (`exercise_id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='루틴-운동 구성 (벤치 3세트 10-12회 등)';


-- ============================================================
-- 12. FavoriteRoutine (루틴 찜/즐겨찾기)
-- 관련 화면: 루틴 상세(우상단 하트 버튼)
-- ============================================================
CREATE TABLE `favorite_routine` (
    `favorite_id`       BIGINT          NOT NULL AUTO_INCREMENT,
    `user_id`           BIGINT          NOT NULL COMMENT '회원 FK',
    `routine_id`        BIGINT          NOT NULL COMMENT '루틴 FK',
    `created_at`        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (`favorite_id`),
    UNIQUE KEY `uk_favorite` (`user_id`, `routine_id`),

    CONSTRAINT `fk_fav_user`
        FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_fav_routine`
        FOREIGN KEY (`routine_id`) REFERENCES `routine` (`routine_id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='루틴 찜 (하트 버튼)';


-- ============================================================
-- 13. WorkoutSession (운동 세션)
-- 관련 화면: 운동 메인(ACTIVE SESSION 카드 - "가슴 & 삼두 데이", 24:15, 320 kcal, 재생 버튼),
--           "오늘의 워크아웃 종료" 버튼 → 리포트로 이동
-- ============================================================
CREATE TABLE `workout_session` (
    `session_id`        BIGINT          NOT NULL AUTO_INCREMENT,
    `user_id`           BIGINT          NOT NULL COMMENT '회원 FK',
    `routine_id`        BIGINT          NULL     COMMENT '루틴 FK (루틴으로 시작한 경우)',
    `session_name`      VARCHAR(100)    NOT NULL COMMENT '세션명 (가슴 & 삼두 데이)',
    `start_time`        DATETIME        NOT NULL COMMENT '세션 시작 시간',
    `end_time`          DATETIME        NULL     COMMENT '세션 종료 시간',
    `total_duration_sec` INT            NOT NULL DEFAULT 0 COMMENT '총 운동 시간(초) (예: 1455 = 24:15)',
    `total_volume_kg`   DECIMAL(10,2)   NOT NULL DEFAULT 0.00 COMMENT '총 볼륨(kg)',
    `total_calories`    DECIMAL(8,2)    NOT NULL DEFAULT 0.00 COMMENT '추정 소모 칼로리(kcal) (예: 320)',
    `status`            ENUM('ACTIVE', 'COMPLETED', 'PAUSED') NOT NULL DEFAULT 'ACTIVE' COMMENT '세션 상태',
    `created_at`        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (`session_id`),
    KEY `idx_session_user` (`user_id`),
    KEY `idx_session_status` (`status`),
    KEY `idx_session_start` (`start_time` DESC),

    CONSTRAINT `fk_session_user`
        FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_session_routine`
        FOREIGN KEY (`routine_id`) REFERENCES `routine` (`routine_id`)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='운동 세션 (ACTIVE SESSION 카드)';


-- ============================================================
-- 14. SessionExercise (세션-운동 매핑)
-- 관련 화면: 운동 메인 "진행중인 운동" 리스트
--   - 벤치 프레스 (체크 완료, 가슴 • 4세트 완료, > 화살표)
--   - 케이블 푸쉬다운 (UP NEXT 태그, 삼두 • 0/3세트, 재생 버튼)
--   - "+ 운동 추가하기" 점선 영역
-- ============================================================
CREATE TABLE `session_exercise` (
    `session_exercise_id` BIGINT        NOT NULL AUTO_INCREMENT,
    `session_id`        BIGINT          NOT NULL COMMENT '세션 FK',
    `exercise_id`       BIGINT          NOT NULL COMMENT '운동 FK',
    `order_index`       INT             NOT NULL COMMENT '운동 순서',
    `target_sets`       INT             NOT NULL DEFAULT 4 COMMENT '목표 세트 수',
    `target_reps`       INT             NOT NULL DEFAULT 12 COMMENT '목표 횟수',
    `status`            ENUM('PENDING', 'IN_PROGRESS', 'COMPLETED') NOT NULL DEFAULT 'PENDING' COMMENT '상태 (대기/진행중=UP NEXT/완료)',

    PRIMARY KEY (`session_exercise_id`),
    UNIQUE KEY `uk_se_order` (`session_id`, `order_index`),
    KEY `idx_se_exercise` (`exercise_id`),

    CONSTRAINT `fk_se_session`
        FOREIGN KEY (`session_id`) REFERENCES `workout_session` (`session_id`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_se_exercise`
        FOREIGN KEY (`exercise_id`) REFERENCES `exercise` (`exercise_id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='세션-운동 (진행중인 운동 리스트, UP NEXT)';


-- ============================================================
-- 15. ExerciseSet (세트 기록)
-- 관련 화면: 운동 상세 세트 테이블
--   세트 | KG  | 회 | 완료
--   1    | 60  | 12 | [V] (초록 체크)
--   2    | 60  | 0  | [ ] (빈 원, 볼드 입력중)
--   3    | --  | -- | [ ]
--   4    | --  | -- | [ ]
--   + 세트 추가하기
--   하단: 타이머 01:24 휴식 중... [-] [+]
-- ============================================================
CREATE TABLE `exercise_set` (
    `set_id`                BIGINT      NOT NULL AUTO_INCREMENT,
    `session_exercise_id`   BIGINT      NOT NULL COMMENT '세션운동 FK',
    `set_number`            INT         NOT NULL COMMENT '세트 번호 (1, 2, 3, 4...)',
    `weight_kg`             DECIMAL(6,2) NULL    COMMENT '무게(kg) (60.00, NULL이면 미입력 "--")',
    `reps`                  INT          NULL    COMMENT '횟수 (12, 0, NULL이면 미입력 "--")',
    `is_completed`          BOOLEAN     NOT NULL DEFAULT FALSE COMMENT '완료 체크 (TRUE=초록체크, FALSE=빈원)',
    `rest_time_sec`         INT         NULL     COMMENT '세트 후 휴식시간(초) (84 = 01:24)',
    `completed_at`          DATETIME    NULL     COMMENT '완료 시각',

    PRIMARY KEY (`set_id`),
    UNIQUE KEY `uk_set_number` (`session_exercise_id`, `set_number`),

    CONSTRAINT `fk_set_session_exercise`
        FOREIGN KEY (`session_exercise_id`) REFERENCES `session_exercise` (`session_exercise_id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='세트 기록 (세트테이블: KG/회/완료체크)';


-- ============================================================
-- 16. PersonalRecord (개인 최고 기록)
-- 관련 화면: 운동 상세 "지난 최고 기록 (1RM) 75 kg" 카드
-- ============================================================
CREATE TABLE `personal_record` (
    `record_id`         BIGINT          NOT NULL AUTO_INCREMENT,
    `user_id`           BIGINT          NOT NULL COMMENT '회원 FK',
    `exercise_id`       BIGINT          NOT NULL COMMENT '운동 FK',
    `record_type`       ENUM('ONE_RM', 'MAX_VOLUME', 'MAX_REPS') NOT NULL COMMENT '기록 유형 (1RM/최대볼륨/최대횟수)',
    `value`             DECIMAL(8,2)    NOT NULL COMMENT '기록 값 (75.00 kg)',
    `achieved_at`       DATE            NOT NULL COMMENT '달성일',
    `created_at`        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (`record_id`),
    KEY `idx_pr_user_exercise` (`user_id`, `exercise_id`),

    CONSTRAINT `fk_pr_user`
        FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_pr_exercise`
        FOREIGN KEY (`exercise_id`) REFERENCES `exercise` (`exercise_id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='개인 최고 기록 (1RM: 75kg)';


-- ============================================================
-- 17. WorkoutReport (운동 리포트)
-- 관련 화면: 오늘 기록 요약
--   메달 아이콘 + "오늘 하루도 SmithLife 하세요! 김스미스님"
--   시간 45:12 | 총 볼륨 4,250kg | 칼로리 380kcal
--   주간 운동량 바 차트 (+12% 지난주 대비)
--   오늘의 운동 요약: 백 스쿼트 4세트 x 10회 100KG [V]
--   "오늘의 기록 공유하기" 버튼
-- ============================================================
CREATE TABLE `workout_report` (
    `report_id`         BIGINT          NOT NULL AUTO_INCREMENT,
    `user_id`           BIGINT          NOT NULL COMMENT '회원 FK',
    `session_id`        BIGINT          NOT NULL COMMENT '세션 FK',
    `report_date`       DATE            NOT NULL COMMENT '리포트 날짜',
    `total_time_sec`    INT             NOT NULL COMMENT '총 운동 시간(초) (2712 = 45:12)',
    `total_volume_kg`   DECIMAL(10,2)   NOT NULL COMMENT '총 볼륨(kg) (4250.00)',
    `total_calories`    DECIMAL(8,2)    NOT NULL COMMENT '소모 칼로리(kcal) (380.00)',
    `weekly_change_pct` DECIMAL(5,2)    NULL     COMMENT '주간 변화율(%) (+12.00)',
    `motivation_msg`    VARCHAR(200)    NULL     COMMENT '동기부여 메시지 (오늘도 한계를 넘으셨군요!)',
    `shared_at`         DATETIME        NULL     COMMENT '공유 일시 (공유 안했으면 NULL)',
    `created_at`        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (`report_id`),
    KEY `idx_report_user` (`user_id`),
    KEY `idx_report_date` (`report_date` DESC),
    UNIQUE KEY `uk_report_session` (`session_id`),

    CONSTRAINT `fk_report_user`
        FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_report_session`
        FOREIGN KEY (`session_id`) REFERENCES `workout_session` (`session_id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='운동 리포트 (45:12 / 4,250kg / 380kcal)';


-- ============================================================
-- 18. Notification (알림)
-- 관련 화면: 알림 탭
--   "예약 확정" 골드라벨 + "방금 전" + "오전 10:00 요가 수업 예약이 확정되었습니다."
--     + "강사: 김수연 | 스튜디오 A"
--   "회원권 만료 D-7" 빨강! + "2시간 전" + "회원권 만료 7일 전입니다!"
--     + "지금 연장하고 재등록 할인 혜택을 받으세요."
-- ============================================================
CREATE TABLE `notification` (
    `notification_id`   BIGINT          NOT NULL AUTO_INCREMENT,
    `user_id`           BIGINT          NOT NULL COMMENT '수신 회원 FK',
    `type`              ENUM('RESERVATION', 'MEMBERSHIP', 'WORKOUT', 'SYSTEM') NOT NULL COMMENT '알림 유형',
    `title`             VARCHAR(200)    NOT NULL COMMENT '제목 (예약 확정, 회원권 만료 D-7)',
    `message`           TEXT            NOT NULL COMMENT '내용',
    `sub_message`       VARCHAR(500)    NULL     COMMENT '부가 정보 (강사: 김수연 | 스튜디오 A)',
    `is_read`           BOOLEAN         NOT NULL DEFAULT FALSE COMMENT '읽음 여부',
    `related_url`       VARCHAR(500)    NULL     COMMENT '클릭 시 이동할 딥링크/경로',
    `created_at`        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (`notification_id`),
    KEY `idx_noti_user_read` (`user_id`, `is_read`),
    KEY `idx_noti_created` (`created_at` DESC),

    CONSTRAINT `fk_noti_user`
        FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='알림 (예약확정, 회원권만료 D-7 등)';


-- ============================================================
-- 19. Announcement (공지사항)
-- 관련 화면:
--   홈 공지 가로스크롤: "안내" 태그 "설날 연휴 운영 시간 안내" + "이벤트" 태그 "오운완 챌..."
--   알림/공지 탭: "NEW" 태그 "센터 정기 휴무 및 대청소 안내" 2023.12.10 + 이미지
--               "EVENT" 태그 "SMITHLIFE 챌린지 3기 모집 시작" 2023.12.08
-- ============================================================
CREATE TABLE `announcement` (
    `announcement_id`   BIGINT          NOT NULL AUTO_INCREMENT,
    `title`             VARCHAR(200)    NOT NULL COMMENT '제목',
    `content`           TEXT            NOT NULL COMMENT '내용',
    `tag`               ENUM('NOTICE', 'EVENT') NOT NULL COMMENT '태그 (안내/이벤트)',
    `image_url`         VARCHAR(500)    NULL     COMMENT '대표 이미지 URL',
    `is_new`            BOOLEAN         NOT NULL DEFAULT TRUE COMMENT 'NEW 배지 표시 여부',
    `published_at`      DATETIME        NOT NULL COMMENT '게시일시',
    `is_active`         BOOLEAN         NOT NULL DEFAULT TRUE COMMENT '노출 여부',
    `created_at`        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (`announcement_id`),
    KEY `idx_ann_published` (`published_at` DESC),
    KEY `idx_ann_active` (`is_active`)
) ENGINE=InnoDB COMMENT='공지사항 (안내/이벤트 태그, NEW 배지)';


-- ============================================================
-- 20. Inquiry (1:1 문의)
-- 관련 화면: 문의하기
--   "답변 완료" 골드태그 + 2024.05.12 + "회원권 기간 연장 문의드립니다." + 내용미리보기
--   "접수 중" 골드태그 + 2024.05.15 + "PT 예약 변경 시스템 오류" + 내용미리보기
--   "답변 완료" + 2024.04.28 + "라커룸 비밀번호 분실"
--   하단: "새로운 문의하기" 골드 버튼
-- ============================================================
CREATE TABLE `inquiry` (
    `inquiry_id`        BIGINT          NOT NULL AUTO_INCREMENT,
    `user_id`           BIGINT          NOT NULL COMMENT '작성자 FK',
    `category`          VARCHAR(50)     NOT NULL COMMENT '카테고리 (시설/예약/회원권/기타)',
    `title`             VARCHAR(200)    NOT NULL COMMENT '제목 (회원권 기간 연장 문의드립니다)',
    `content`           TEXT            NOT NULL COMMENT '내용',
    `image_url`         VARCHAR(500)    NULL     COMMENT '첨부 이미지 URL',
    `status`            ENUM('RECEIVED', 'IN_PROGRESS', 'REPLIED') NOT NULL DEFAULT 'RECEIVED' COMMENT '상태 (접수중/처리중/답변완료)',
    `created_at`        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (`inquiry_id`),
    KEY `idx_inquiry_user` (`user_id`),
    KEY `idx_inquiry_status` (`status`),
    KEY `idx_inquiry_created` (`created_at` DESC),

    CONSTRAINT `fk_inquiry_user`
        FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='1:1 문의 (답변완료/접수중 태그)';


-- ============================================================
-- 21. InquiryReply (문의 답변)
-- 관련 화면: 문의 상세 답변 내용
-- ============================================================
CREATE TABLE `inquiry_reply` (
    `reply_id`          BIGINT          NOT NULL AUTO_INCREMENT,
    `inquiry_id`        BIGINT          NOT NULL COMMENT '문의 FK',
    `admin_name`        VARCHAR(50)     NOT NULL COMMENT '답변자명',
    `content`           TEXT            NOT NULL COMMENT '답변 내용',
    `created_at`        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (`reply_id`),
    KEY `idx_reply_inquiry` (`inquiry_id`),

    CONSTRAINT `fk_reply_inquiry`
        FOREIGN KEY (`inquiry_id`) REFERENCES `inquiry` (`inquiry_id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='문의 답변';


-- ============================================================
-- 22. FAQ (자주 묻는 질문)
-- 관련 화면: 문의하기(자주 묻는 질문 카드 → 아코디언)
-- ============================================================
CREATE TABLE `faq` (
    `faq_id`            BIGINT          NOT NULL AUTO_INCREMENT,
    `category`          VARCHAR(50)     NOT NULL COMMENT '카테고리',
    `question`          VARCHAR(500)    NOT NULL COMMENT '질문',
    `answer`            TEXT            NOT NULL COMMENT '답변',
    `order_index`       INT             NOT NULL DEFAULT 0 COMMENT '표시 순서',
    `is_active`         BOOLEAN         NOT NULL DEFAULT TRUE COMMENT '노출 여부',
    `created_at`        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (`faq_id`),
    KEY `idx_faq_active_order` (`is_active`, `order_index`)
) ENGINE=InnoDB COMMENT='자주 묻는 질문 (FAQ)';


-- ============================================================
-- 초기 데이터 (UI 스크린샷에서 확인된 실제 데이터)
-- ============================================================

-- 시설
INSERT INTO `facility` (`name`, `description`, `max_capacity`) VALUES
('메인 피트니스 존', '메인 웨이트/유산소 시설', 50),
('스튜디오 A', '그룹 수업 전용 스튜디오', 20),
('스튜디오 B', '요가/필라테스 전용', 15);

-- 운동 종목 (루틴 상세 + 운동 메인에서 확인)
INSERT INTO `exercise` (`name`, `body_part`, `equipment`) VALUES
('벤치 프레스', '가슴', '바벨'),
('바벨 스쿼트', '하체', '바벨'),
('랫 풀 다운', '등', '케이블'),
('덤벨 숄더 프레스', '어깨', '덤벨'),
('케이블 푸쉬다운', '삼두', '케이블'),
('백 스쿼트', '하체', '바벨'),
('데드리프트', '등', '바벨'),
('레그 프레스', '하체', '머신'),
('사이드 레터럴 레이즈', '어깨', '덤벨'),
('바이셉 컬', '이두', '덤벨'),
('플랭크', '코어', '맨몸'),
('크런치', '코어', '맨몸'),
('러닝', '전신', '트레드밀'),
('스트레칭', '전신', '맨몸');

-- 추천 루틴 (루틴 목록 화면 8개)
INSERT INTO `routine` (`creator_id`, `name`, `goal`, `difficulty`, `estimated_min`, `frequency`, `description`, `is_public`, `is_recommended`) VALUES
(NULL, '파워 빌딩',     'MUSCLE_GAIN',  'BEGINNER',     45, '주 3회', '기초 근력 향상과 근비대를 위한 완벽한 입문 프로그램', TRUE, TRUE),
(NULL, '데일리 컷팅',   'DIET',         'INTERMEDIATE', 30, '매일',   '매일 짧은 시간 효율적인 체지방 커팅 루틴', TRUE, TRUE),
(NULL, '린 매스업',     'MUSCLE_GAIN',  'ADVANCED',     60, '주 5회', '고급자를 위한 린매스 벌크업 루틴', TRUE, TRUE),
(NULL, '홈 트레이닝',   'STAMINA',      'BEGINNER',     20, '주 4회', '집에서도 할 수 있는 기초 체력 루틴', TRUE, TRUE),
(NULL, '상체 집중',     'MUSCLE_GAIN',  'INTERMEDIATE', 50, '주 2회', '상체 근력 집중 강화 루틴', TRUE, TRUE),
(NULL, '하체 챌린지',   'MUSCLE_GAIN',  'ADVANCED',     40, '주 3회', '하체 근력 극한 도전 루틴', TRUE, TRUE),
(NULL, '코어 강화',     'STAMINA',      'BEGINNER',     15, '주 3회', '코어 안정성 강화 루틴', TRUE, TRUE),
(NULL, '스트레칭',      'STAMINA',      'BEGINNER',     10, '매일',   '유연성 향상을 위한 데일리 스트레칭', TRUE, TRUE);

-- 파워 빌딩 루틴 운동 구성 (루틴 상세 화면 "운동 구성 5")
INSERT INTO `routine_exercise` (`routine_id`, `exercise_id`, `order_index`, `target_sets`, `target_reps_min`, `target_reps_max`) VALUES
(1, 1, 1, 3, 10, 12),   -- 벤치 프레스 3세트 10-12회
(1, 2, 2, 4, 8,  10),   -- 바벨 스쿼트 4세트 8-10회
(1, 3, 3, 3, 12, NULL),  -- 랫 풀 다운 3세트 12회
(1, 4, 4, 4, 12, 15),   -- 덤벨 숄더 프레스 4세트 12-15회
(1, 7, 5, 3, 8,  10);   -- 데드리프트 3세트 8-10회

-- FAQ 예시
INSERT INTO `faq` (`category`, `question`, `answer`, `order_index`) VALUES
('회원권', '회원권 일시정지는 어떻게 하나요?', '내정보 > 회원권 관리에서 일시정지를 신청할 수 있습니다. 최대 30일까지 가능합니다.', 1),
('예약', '예약 취소는 언제까지 가능한가요?', '예약 시간 1시간 전까지 앱에서 자유롭게 취소할 수 있습니다.', 2),
('시설', '운영 시간이 어떻게 되나요?', '평일 06:00~23:00, 주말 08:00~20:00, 공휴일 10:00~18:00 입니다.', 3),
('기타', '라커룸 비밀번호를 잊어버렸어요.', '프론트 데스크에서 본인 확인 후 재설정해드립니다.', 4);
