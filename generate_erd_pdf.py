# -*- coding: utf-8 -*-
"""
SmithLife ERD 다이어그램 PDF 생성
19개 UI 스크린샷 분석 기반
"""
import sys
sys.stdout.reconfigure(encoding='utf-8')

from fpdf import FPDF
import os, math

# ─── 색상 정의 ───
C_HEADER_BG = (40, 60, 110)       # 엔티티 헤더 배경 (짙은 남색)
C_HEADER_FG = (255, 255, 255)     # 헤더 텍스트 (흰색)
C_PK_BG     = (255, 245, 220)     # PK 행 배경 (연한 골드)
C_FK_BG     = (230, 240, 255)     # FK 행 배경 (연한 파랑)
C_BODY_BG   = (255, 255, 255)     # 일반 행 배경
C_BORDER    = (100, 100, 100)     # 테두리
C_LINE      = (180, 60, 60)       # 관계선 (빨간계열)
C_TITLE     = (30, 50, 100)       # 제목

class ERD_PDF(FPDF):
    def __init__(self):
        super().__init__(orientation='L', format='A4')
        font_path = "C:/Windows/Fonts/malgun.ttf"
        font_bold_path = "C:/Windows/Fonts/malgunbd.ttf"
        self.add_font("malgun", "", font_path)
        self.add_font("malgun", "B", font_bold_path)
        self.set_auto_page_break(auto=False)

    def footer(self):
        self.set_y(-10)
        self.set_font("malgun", "", 7)
        self.set_text_color(150, 150, 150)
        self.cell(0, 5, f"SmithLife ERD - {self.page_no()} / {{nb}}", align="C")

    def draw_entity(self, x, y, name, columns, w=56):
        """
        columns: list of (col_name, col_type, constraint)
        constraint: 'PK', 'FK', ''
        """
        row_h = 5.5
        header_h = 7
        total_h = header_h + len(columns) * row_h + 1

        # 그림자
        self.set_fill_color(200, 200, 200)
        self.rect(x + 0.7, y + 0.7, w, total_h, 'F')

        # 헤더
        self.set_fill_color(*C_HEADER_BG)
        self.set_draw_color(*C_BORDER)
        self.set_line_width(0.3)
        self.rect(x, y, w, header_h, 'FD')
        self.set_font("malgun", "B", 7.5)
        self.set_text_color(*C_HEADER_FG)
        self.set_xy(x, y)
        self.cell(w, header_h, name, align="C")

        # 컬럼
        cy = y + header_h
        for col_name, col_type, constraint in columns:
            if constraint == 'PK':
                self.set_fill_color(*C_PK_BG)
            elif constraint == 'FK':
                self.set_fill_color(*C_FK_BG)
            else:
                self.set_fill_color(*C_BODY_BG)

            self.rect(x, cy, w, row_h, 'FD')

            # constraint marker
            self.set_font("malgun", "B", 5.5)
            self.set_text_color(180, 60, 60) if constraint == 'PK' else self.set_text_color(60, 60, 180) if constraint == 'FK' else self.set_text_color(100,100,100)
            self.set_xy(x + 0.5, cy)
            marker = 'PK' if constraint == 'PK' else 'FK' if constraint == 'FK' else ''
            self.cell(7, row_h, marker, align="L")

            # column name
            self.set_font("malgun", "B" if constraint == 'PK' else "", 6)
            self.set_text_color(30, 30, 30)
            self.set_xy(x + 8, cy)
            self.cell(24, row_h, col_name, align="L")

            # column type
            self.set_font("malgun", "", 5.5)
            self.set_text_color(100, 100, 100)
            self.set_xy(x + 32, cy)
            self.cell(w - 33, row_h, col_type, align="R")

            cy += row_h

        # 하단 테두리
        self.rect(x, y, w, total_h, 'D')

        return total_h

    def draw_relation(self, x1, y1, x2, y2, label="", card1="1", card2="N"):
        """두 점 사이에 관계선 그리기"""
        self.set_draw_color(*C_LINE)
        self.set_line_width(0.35)
        self.line(x1, y1, x2, y2)

        # 중간점에 라벨
        if label:
            mx, my = (x1 + x2) / 2, (y1 + y2) / 2
            self.set_font("malgun", "", 5)
            self.set_text_color(150, 40, 40)
            tw = self.get_string_width(label)
            self.set_fill_color(255, 255, 255)
            self.rect(mx - tw/2 - 1, my - 3, tw + 2, 5, 'F')
            self.set_xy(mx - tw/2, my - 2.5)
            self.cell(tw, 4, label, align="C")

        # cardinality 표시
        self.set_font("malgun", "B", 5.5)
        self.set_text_color(180, 60, 60)

        # 시작점 cardinality
        dx = x2 - x1
        dy = y2 - y1
        dist = math.sqrt(dx*dx + dy*dy)
        if dist > 0:
            ux, uy = dx/dist, dy/dist
            # card1 near (x1,y1)
            self.set_xy(x1 + ux*4 - 3, y1 + uy*4 - 2)
            self.cell(6, 4, card1, align="C")
            # card2 near (x2,y2)
            self.set_xy(x2 - ux*4 - 3, y2 - uy*4 - 2)
            self.cell(6, 4, card2, align="C")


def main():
    pdf = ERD_PDF()
    pdf.alias_nb_pages()

    # ════════════════════════════════════════════════════
    # 페이지 1: 전체 ERD 개요 다이어그램
    # ════════════════════════════════════════════════════
    pdf.add_page()
    pdf.set_font("malgun", "B", 18)
    pdf.set_text_color(*C_TITLE)
    pdf.cell(0, 10, "SmithLife ERD (Entity Relationship Diagram)", align="C", new_x="LMARGIN", new_y="NEXT")
    pdf.set_font("malgun", "", 9)
    pdf.set_text_color(100, 100, 100)
    pdf.cell(0, 5, "19개 UI 화면 분석 기반 | 총 17개 엔티티 | 스미스라이프 UI_v2.docx", align="C", new_x="LMARGIN", new_y="NEXT")
    pdf.ln(2)

    # 범례
    lx = 220
    ly = 18
    pdf.set_font("malgun", "B", 7)
    pdf.set_text_color(50, 50, 50)
    pdf.set_xy(lx, ly)
    pdf.cell(30, 5, "[범례]")

    pdf.set_fill_color(*C_PK_BG)
    pdf.rect(lx, ly+6, 8, 4, 'F')
    pdf.set_xy(lx+9, ly+5.5)
    pdf.set_font("malgun", "", 6)
    pdf.cell(20, 5, "PK (Primary Key)")

    pdf.set_fill_color(*C_FK_BG)
    pdf.rect(lx, ly+11, 8, 4, 'F')
    pdf.set_xy(lx+9, ly+10.5)
    pdf.cell(20, 5, "FK (Foreign Key)")

    pdf.set_draw_color(*C_LINE)
    pdf.set_line_width(0.4)
    pdf.line(lx, ly+18, lx+8, ly+18)
    pdf.set_xy(lx+9, ly+15.5)
    pdf.cell(30, 5, "Relationship (1:N)")

    # ── 엔티티 배치 (5행 x 4열 대략 배치) ──

    # Row 1: User, Membership, Attendance, UserSettings
    h = pdf.draw_entity(10, 35, "User (회원)", [
        ("user_id", "BIGINT", "PK"),
        ("email", "VARCHAR(100)", ""),
        ("password_hash", "VARCHAR(255)", ""),
        ("name", "VARCHAR(50)", ""),
        ("phone", "VARCHAR(20)", ""),
        ("profile_image_url", "VARCHAR(500)", ""),
        ("role", "ENUM", ""),
        ("created_at", "DATETIME", ""),
        ("updated_at", "DATETIME", ""),
        ("is_active", "BOOLEAN", ""),
    ])

    pdf.draw_entity(75, 35, "Membership (회원권)", [
        ("membership_id", "BIGINT", "PK"),
        ("user_id", "BIGINT", "FK"),
        ("type", "VARCHAR(50)", ""),
        ("start_date", "DATE", ""),
        ("end_date", "DATE", ""),
        ("remaining_days", "INT", ""),
        ("status", "ENUM", ""),
        ("created_at", "DATETIME", ""),
    ])

    pdf.draw_entity(140, 35, "Attendance (출석)", [
        ("attendance_id", "BIGINT", "PK"),
        ("user_id", "BIGINT", "FK"),
        ("check_in_time", "DATETIME", ""),
        ("check_out_time", "DATETIME", ""),
        ("qr_token", "VARCHAR(255)", ""),
        ("status", "ENUM", ""),
        ("created_at", "DATETIME", ""),
    ])

    pdf.draw_entity(205, 35, "UserSettings (설정)", [
        ("setting_id", "BIGINT", "PK"),
        ("user_id", "BIGINT", "FK"),
        ("notification_enabled", "BOOLEAN", ""),
        ("dark_mode", "ENUM", ""),
        ("language", "VARCHAR(10)", ""),
        ("updated_at", "DATETIME", ""),
    ])

    # Row 2: TimeSlot, Reservation, UsageHistory
    pdf.draw_entity(10, 105, "TimeSlot (시간 슬롯)", [
        ("slot_id", "BIGINT", "PK"),
        ("date", "DATE", ""),
        ("start_time", "TIME", ""),
        ("end_time", "TIME", ""),
        ("max_capacity", "INT", ""),
        ("current_count", "INT", ""),
        ("congestion", "ENUM", ""),
        ("facility_name", "VARCHAR(100)", ""),
    ])

    pdf.draw_entity(75, 105, "Reservation (예약)", [
        ("reservation_id", "BIGINT", "PK"),
        ("user_id", "BIGINT", "FK"),
        ("slot_id", "BIGINT", "FK"),
        ("reservation_no", "VARCHAR(20)", ""),
        ("status", "ENUM", ""),
        ("reserved_at", "DATETIME", ""),
        ("cancelled_at", "DATETIME", ""),
    ])

    pdf.draw_entity(140, 105, "UsageHistory (이용내역)", [
        ("usage_id", "BIGINT", "PK"),
        ("user_id", "BIGINT", "FK"),
        ("reservation_id", "BIGINT", "FK"),
        ("facility_name", "VARCHAR(100)", ""),
        ("start_time", "DATETIME", ""),
        ("end_time", "DATETIME", ""),
        ("status", "ENUM", ""),
    ])

    # Row 3: WorkoutSession, Exercise, ExerciseSet, PersonalRecord
    pdf.draw_entity(10, 170, "WorkoutSession (운동세션)", [
        ("session_id", "BIGINT", "PK"),
        ("user_id", "BIGINT", "FK"),
        ("routine_id", "BIGINT", "FK"),
        ("session_name", "VARCHAR(100)", ""),
        ("start_time", "DATETIME", ""),
        ("end_time", "DATETIME", ""),
        ("total_duration_sec", "INT", ""),
        ("total_volume_kg", "DECIMAL", ""),
        ("total_calories", "DECIMAL", ""),
        ("status", "ENUM", ""),
    ])

    pdf.draw_entity(75, 170, "Exercise (운동종목)", [
        ("exercise_id", "BIGINT", "PK"),
        ("name", "VARCHAR(100)", ""),
        ("body_part", "VARCHAR(50)", ""),
        ("equipment", "VARCHAR(50)", ""),
        ("image_url", "VARCHAR(500)", ""),
        ("description", "TEXT", ""),
    ])

    pdf.draw_entity(140, 170, "SessionExercise (세션운동)", [
        ("session_exercise_id", "BIGINT", "PK"),
        ("session_id", "BIGINT", "FK"),
        ("exercise_id", "BIGINT", "FK"),
        ("order_index", "INT", ""),
        ("target_sets", "INT", ""),
        ("target_reps", "INT", ""),
        ("status", "ENUM", ""),
    ])

    pdf.draw_entity(205, 170, "ExerciseSet (세트기록)", [
        ("set_id", "BIGINT", "PK"),
        ("session_exercise_id", "BIGINT", "FK"),
        ("set_number", "INT", ""),
        ("weight_kg", "DECIMAL", ""),
        ("reps", "INT", ""),
        ("is_completed", "BOOLEAN", ""),
        ("rest_time_sec", "INT", ""),
    ])

    # ── 관계선 그리기 (Row 1 ~ Row 2) ──
    # User -> Membership (1:N)
    pdf.draw_relation(66, 60, 75, 60, "", "1", "N")
    # User -> Attendance (1:N)
    pdf.draw_relation(66, 50, 140, 50, "", "1", "N")
    # User -> UserSettings (1:1)
    pdf.draw_relation(66, 45, 205, 45, "", "1", "1")

    # User -> Reservation (1:N)
    pdf.draw_relation(35, 35+h, 35, 105, "", "1", "N")
    # We need to draw relation from User down to Reservation
    # Actually let me use entity connection points more carefully

    # User -> Reservation
    pdf.draw_relation(40, 93, 90, 105, "", "1", "N")
    # TimeSlot -> Reservation
    pdf.draw_relation(66, 125, 75, 125, "", "1", "N")
    # Reservation -> UsageHistory
    pdf.draw_relation(131, 125, 140, 125, "", "1", "1")
    # User -> UsageHistory
    pdf.draw_relation(50, 93, 155, 105, "", "1", "N")

    # User -> WorkoutSession
    pdf.draw_relation(30, 93, 30, 170, "", "1", "N")
    # WorkoutSession -> SessionExercise
    pdf.draw_relation(66, 195, 140, 195, "", "1", "N")
    # Exercise -> SessionExercise
    pdf.draw_relation(131, 190, 140, 190, "", "1", "N")
    # SessionExercise -> ExerciseSet
    pdf.draw_relation(196, 195, 205, 195, "", "1", "N")

    # ════════════════════════════════════════════════════
    # 페이지 2: 루틴/알림/문의 엔티티
    # ════════════════════════════════════════════════════
    pdf.add_page()
    pdf.set_font("malgun", "B", 14)
    pdf.set_text_color(*C_TITLE)
    pdf.cell(0, 10, "SmithLife ERD - 루틴 / 알림 / 문의 / 리포트", align="C", new_x="LMARGIN", new_y="NEXT")
    pdf.ln(2)

    # Row 1: Routine, RoutineExercise, FavoriteRoutine
    pdf.draw_entity(10, 25, "Routine (루틴)", [
        ("routine_id", "BIGINT", "PK"),
        ("creator_id", "BIGINT", "FK"),
        ("name", "VARCHAR(100)", ""),
        ("goal", "ENUM", ""),
        ("difficulty", "ENUM", ""),
        ("duration_min", "INT", ""),
        ("frequency", "VARCHAR(50)", ""),
        ("description", "TEXT", ""),
        ("image_url", "VARCHAR(500)", ""),
        ("is_public", "BOOLEAN", ""),
        ("is_recommended", "BOOLEAN", ""),
        ("created_at", "DATETIME", ""),
    ])

    pdf.draw_entity(80, 25, "RoutineExercise (루틴운동)", [
        ("routine_exercise_id", "BIGINT", "PK"),
        ("routine_id", "BIGINT", "FK"),
        ("exercise_id", "BIGINT", "FK"),
        ("order_index", "INT", ""),
        ("target_sets", "INT", ""),
        ("target_reps_min", "INT", ""),
        ("target_reps_max", "INT", ""),
    ])

    pdf.draw_entity(150, 25, "FavoriteRoutine (찜)", [
        ("favorite_id", "BIGINT", "PK"),
        ("user_id", "BIGINT", "FK"),
        ("routine_id", "BIGINT", "FK"),
        ("created_at", "DATETIME", ""),
    ])

    # Routine -> RoutineExercise
    pdf.draw_relation(66, 55, 80, 55, "", "1", "N")
    # Routine -> FavoriteRoutine
    pdf.draw_relation(66, 45, 150, 45, "", "1", "N")

    # Row 2: PersonalRecord, WorkoutReport
    pdf.draw_entity(10, 105, "PersonalRecord (개인기록)", [
        ("record_id", "BIGINT", "PK"),
        ("user_id", "BIGINT", "FK"),
        ("exercise_id", "BIGINT", "FK"),
        ("record_type", "ENUM", ""),
        ("value_kg", "DECIMAL", ""),
        ("achieved_at", "DATE", ""),
    ])

    pdf.draw_entity(80, 105, "WorkoutReport (리포트)", [
        ("report_id", "BIGINT", "PK"),
        ("user_id", "BIGINT", "FK"),
        ("session_id", "BIGINT", "FK"),
        ("report_date", "DATE", ""),
        ("total_time_sec", "INT", ""),
        ("total_volume_kg", "DECIMAL", ""),
        ("total_calories", "DECIMAL", ""),
        ("weekly_change_pct", "DECIMAL", ""),
        ("motivation_msg", "VARCHAR(200)", ""),
        ("shared_at", "DATETIME", ""),
    ])

    # Row 3: Notification, Announcement
    pdf.draw_entity(10, 175, "Notification (알림)", [
        ("notification_id", "BIGINT", "PK"),
        ("user_id", "BIGINT", "FK"),
        ("type", "ENUM", ""),
        ("title", "VARCHAR(200)", ""),
        ("message", "TEXT", ""),
        ("is_read", "BOOLEAN", ""),
        ("related_url", "VARCHAR(500)", ""),
        ("created_at", "DATETIME", ""),
    ])

    pdf.draw_entity(80, 175, "Announcement (공지사항)", [
        ("announcement_id", "BIGINT", "PK"),
        ("title", "VARCHAR(200)", ""),
        ("content", "TEXT", ""),
        ("tag", "ENUM", ""),
        ("image_url", "VARCHAR(500)", ""),
        ("published_at", "DATETIME", ""),
        ("is_active", "BOOLEAN", ""),
    ])

    # Row 3 right: Inquiry, InquiryReply, FAQ
    pdf.draw_entity(150, 105, "Inquiry (1:1 문의)", [
        ("inquiry_id", "BIGINT", "PK"),
        ("user_id", "BIGINT", "FK"),
        ("category", "VARCHAR(50)", ""),
        ("title", "VARCHAR(200)", ""),
        ("content", "TEXT", ""),
        ("image_url", "VARCHAR(500)", ""),
        ("status", "ENUM", ""),
        ("created_at", "DATETIME", ""),
    ])

    pdf.draw_entity(220, 105, "InquiryReply (문의답변)", [
        ("reply_id", "BIGINT", "PK"),
        ("inquiry_id", "BIGINT", "FK"),
        ("admin_name", "VARCHAR(50)", ""),
        ("content", "TEXT", ""),
        ("created_at", "DATETIME", ""),
    ])

    pdf.draw_entity(150, 175, "FAQ (자주묻는질문)", [
        ("faq_id", "BIGINT", "PK"),
        ("category", "VARCHAR(50)", ""),
        ("question", "VARCHAR(500)", ""),
        ("answer", "TEXT", ""),
        ("order_index", "INT", ""),
        ("is_active", "BOOLEAN", ""),
    ])

    # Inquiry -> InquiryReply
    pdf.draw_relation(206, 135, 220, 135, "", "1", "N")

    # ════════════════════════════════════════════════════
    # 페이지 3: 상세 테이블 명세 (텍스트)
    # ════════════════════════════════════════════════════
    pdf.add_page()
    pdf.set_font("malgun", "B", 16)
    pdf.set_text_color(*C_TITLE)
    pdf.cell(0, 10, "테이블 상세 명세", align="C", new_x="LMARGIN", new_y="NEXT")
    pdf.set_font("malgun", "", 8)
    pdf.set_text_color(100, 100, 100)
    pdf.cell(0, 5, "각 테이블의 컬럼, 타입, 제약조건, UI 화면 매핑 상세", align="C", new_x="LMARGIN", new_y="NEXT")
    pdf.ln(3)

    tables = [
        {
            "name": "User (회원)",
            "desc": "회원가입/로그인/마이페이지 화면에서 사용. 이메일 기반 인증, 프로필 관리.",
            "screens": "스플래쉬, 로그인, 회원가입, 내정보, 설정",
            "cols": [
                ("user_id", "BIGINT", "PK, AUTO_INCREMENT", "회원 고유 ID"),
                ("email", "VARCHAR(100)", "UNIQUE, NOT NULL", "로그인 이메일 (아이디)"),
                ("password_hash", "VARCHAR(255)", "NOT NULL", "bcrypt 암호화 비밀번호"),
                ("name", "VARCHAR(50)", "NOT NULL", "회원 이름"),
                ("phone", "VARCHAR(20)", "UNIQUE, NOT NULL", "전화번호 (010-XXXX-XXXX)"),
                ("profile_image_url", "VARCHAR(500)", "NULLABLE", "프로필 사진 URL"),
                ("role", "ENUM('USER','ADMIN')", "DEFAULT 'USER'", "사용자 역할"),
                ("created_at", "DATETIME", "NOT NULL", "가입일시"),
                ("updated_at", "DATETIME", "NOT NULL", "최종 수정일시"),
                ("is_active", "BOOLEAN", "DEFAULT TRUE", "활성 여부 (탈퇴 시 FALSE)"),
            ]
        },
        {
            "name": "Membership (회원권)",
            "desc": "홈 화면 D-day 카드, 내정보 프로필 카드에서 사용. 정기권 종류/잔여기간 관리.",
            "screens": "홈(D-45일), 내정보(3개월 정기권), 알림(만료 D-7)",
            "cols": [
                ("membership_id", "BIGINT", "PK, AUTO_INCREMENT", "회원권 고유 ID"),
                ("user_id", "BIGINT", "FK -> User", "회원 ID"),
                ("type", "VARCHAR(50)", "NOT NULL", "회원권 종류 (1개월/3개월/6개월/12개월)"),
                ("start_date", "DATE", "NOT NULL", "시작일"),
                ("end_date", "DATE", "NOT NULL", "만료일"),
                ("remaining_days", "INT", "COMPUTED", "남은 일수 (D-day)"),
                ("status", "ENUM('ACTIVE','EXPIRED','PAUSED')", "NOT NULL", "상태"),
                ("created_at", "DATETIME", "NOT NULL", "등록일시"),
            ]
        },
        {
            "name": "Attendance (출석)",
            "desc": "QR 체크인 모달에서 생성. QR 스캔 시 출석 기록.",
            "screens": "QR 체크인 팝업, 홈(참석율)",
            "cols": [
                ("attendance_id", "BIGINT", "PK, AUTO_INCREMENT", "출석 고유 ID"),
                ("user_id", "BIGINT", "FK -> User", "회원 ID"),
                ("check_in_time", "DATETIME", "NOT NULL", "입장 시간"),
                ("check_out_time", "DATETIME", "NULLABLE", "퇴장 시간"),
                ("qr_token", "VARCHAR(255)", "NOT NULL", "QR 인증 토큰 (1회성)"),
                ("status", "ENUM('CHECKED_IN','CHECKED_OUT')", "NOT NULL", "상태"),
                ("created_at", "DATETIME", "NOT NULL", "생성일시"),
            ]
        },
        {
            "name": "UserSettings (사용자설정)",
            "desc": "설정 화면의 앱 설정 항목 저장.",
            "screens": "설정(알림설정, 다크모드 '시스템설정', 언어 '한국어')",
            "cols": [
                ("setting_id", "BIGINT", "PK, AUTO_INCREMENT", "설정 고유 ID"),
                ("user_id", "BIGINT", "FK -> User, UNIQUE", "회원 ID (1:1)"),
                ("notification_enabled", "BOOLEAN", "DEFAULT TRUE", "알림 수신 여부"),
                ("dark_mode", "ENUM('SYSTEM','ON','OFF')", "DEFAULT 'SYSTEM'", "다크 모드"),
                ("language", "VARCHAR(10)", "DEFAULT 'ko'", "언어 설정"),
                ("updated_at", "DATETIME", "NOT NULL", "최종 변경일시"),
            ]
        },
        {
            "name": "TimeSlot (시간 슬롯)",
            "desc": "예약 시간표 화면의 시간별 슬롯. 혼잡도(원활/보통/혼잡) 표시.",
            "screens": "예약 시간표(09:00~16:00, 초록/노랑/빨강 dot)",
            "cols": [
                ("slot_id", "BIGINT", "PK, AUTO_INCREMENT", "슬롯 고유 ID"),
                ("date", "DATE", "NOT NULL", "날짜"),
                ("start_time", "TIME", "NOT NULL", "시작 시간 (예: 09:00)"),
                ("end_time", "TIME", "NOT NULL", "종료 시간 (예: 10:00)"),
                ("max_capacity", "INT", "NOT NULL", "최대 수용 인원"),
                ("current_count", "INT", "DEFAULT 0", "현재 예약 인원"),
                ("congestion", "ENUM('SMOOTH','MODERATE','CROWDED')", "COMPUTED", "혼잡도 (원활/보통/혼잡)"),
                ("facility_name", "VARCHAR(100)", "NOT NULL", "시설명 (메인 피트니스 존 등)"),
            ]
        },
        {
            "name": "Reservation (예약)",
            "desc": "예약하기/취소하기 모달에서 생성/취소. 홈 '다음 예약' 카드에 표시.",
            "screens": "예약 시간표, 예약 모달, 취소 모달, 홈(다음 예약 09:00-10:30)",
            "cols": [
                ("reservation_id", "BIGINT", "PK, AUTO_INCREMENT", "예약 고유 ID"),
                ("user_id", "BIGINT", "FK -> User", "회원 ID"),
                ("slot_id", "BIGINT", "FK -> TimeSlot", "시간 슬롯 ID"),
                ("reservation_no", "VARCHAR(20)", "UNIQUE", "예약번호 (예: #8812)"),
                ("status", "ENUM('CONFIRMED','CANCELLED','NO_SHOW','COMPLETED')", "NOT NULL", "상태"),
                ("reserved_at", "DATETIME", "NOT NULL", "예약일시"),
                ("cancelled_at", "DATETIME", "NULLABLE", "취소일시"),
            ]
        },
        {
            "name": "UsageHistory (이용내역)",
            "desc": "이용내역 리스트 화면. 시설 이용 기록 + 예약번호/상태 표시.",
            "screens": "이용내역(시설 이용 09:00-11:00, 예약번호 #8812, 이용완료)",
            "cols": [
                ("usage_id", "BIGINT", "PK, AUTO_INCREMENT", "이용 고유 ID"),
                ("user_id", "BIGINT", "FK -> User", "회원 ID"),
                ("reservation_id", "BIGINT", "FK -> Reservation", "예약 ID"),
                ("facility_name", "VARCHAR(100)", "NOT NULL", "시설명"),
                ("start_time", "DATETIME", "NOT NULL", "이용 시작 시간"),
                ("end_time", "DATETIME", "NOT NULL", "이용 종료 시간"),
                ("status", "ENUM('COMPLETED','CANCELLED','NO_SHOW')", "NOT NULL", "이용 상태"),
            ]
        },
    ]

    tables2 = [
        {
            "name": "WorkoutSession (운동세션)",
            "desc": "운동 메인 ACTIVE SESSION. 경과시간/칼로리/볼륨 실시간 추적.",
            "screens": "운동 메인(가슴&삼두 데이, 24:15, 320kcal)",
            "cols": [
                ("session_id", "BIGINT", "PK, AUTO_INCREMENT", "세션 고유 ID"),
                ("user_id", "BIGINT", "FK -> User", "회원 ID"),
                ("routine_id", "BIGINT", "FK -> Routine, NULLABLE", "루틴 ID (루틴 기반 세션일 때)"),
                ("session_name", "VARCHAR(100)", "NOT NULL", "세션명 (예: 가슴 & 삼두 데이)"),
                ("start_time", "DATETIME", "NOT NULL", "시작 시간"),
                ("end_time", "DATETIME", "NULLABLE", "종료 시간"),
                ("total_duration_sec", "INT", "DEFAULT 0", "총 운동 시간(초)"),
                ("total_volume_kg", "DECIMAL(10,2)", "DEFAULT 0", "총 볼륨(kg)"),
                ("total_calories", "DECIMAL(8,2)", "DEFAULT 0", "추정 소모 칼로리(kcal)"),
                ("status", "ENUM('ACTIVE','COMPLETED','PAUSED')", "NOT NULL", "세션 상태"),
            ]
        },
        {
            "name": "Exercise (운동종목)",
            "desc": "운동 상세 화면의 운동 정보. 루틴 상세의 운동 구성 목록.",
            "screens": "운동 상세(벤치프레스, 가슴 태그), 루틴 상세(바벨 스쿼트/랫풀다운 등)",
            "cols": [
                ("exercise_id", "BIGINT", "PK, AUTO_INCREMENT", "운동 고유 ID"),
                ("name", "VARCHAR(100)", "NOT NULL", "운동명 (벤치 프레스, 케이블 푸쉬다운 등)"),
                ("body_part", "VARCHAR(50)", "NOT NULL", "운동 부위 (가슴/하체/등/어깨/삼두 등)"),
                ("equipment", "VARCHAR(50)", "NULLABLE", "장비 (바벨/덤벨/케이블/머신 등)"),
                ("image_url", "VARCHAR(500)", "NULLABLE", "운동 이미지 URL"),
                ("description", "TEXT", "NULLABLE", "운동 설명"),
            ]
        },
        {
            "name": "SessionExercise (세션운동)",
            "desc": "운동 메인 진행중인 운동 리스트. 완료/UP NEXT 상태 관리.",
            "screens": "운동 메인(벤치프레스 4세트완료, 케이블 푸쉬다운 UP NEXT 0/3세트)",
            "cols": [
                ("session_exercise_id", "BIGINT", "PK, AUTO_INCREMENT", "세션운동 고유 ID"),
                ("session_id", "BIGINT", "FK -> WorkoutSession", "세션 ID"),
                ("exercise_id", "BIGINT", "FK -> Exercise", "운동 ID"),
                ("order_index", "INT", "NOT NULL", "운동 순서"),
                ("target_sets", "INT", "NOT NULL", "목표 세트 수"),
                ("target_reps", "INT", "NOT NULL", "목표 횟수"),
                ("status", "ENUM('PENDING','IN_PROGRESS','COMPLETED')", "NOT NULL", "상태"),
            ]
        },
        {
            "name": "ExerciseSet (세트기록)",
            "desc": "운동 상세 세트 테이블. KG/횟수/완료 체크 기록.",
            "screens": "운동 상세(세트1: 60kg/12회/완료V, 세트2: 60kg/0회, 세트3-4: --/--)",
            "cols": [
                ("set_id", "BIGINT", "PK, AUTO_INCREMENT", "세트 고유 ID"),
                ("session_exercise_id", "BIGINT", "FK -> SessionExercise", "세션운동 ID"),
                ("set_number", "INT", "NOT NULL", "세트 번호 (1, 2, 3, 4...)"),
                ("weight_kg", "DECIMAL(6,2)", "NULLABLE", "무게 (kg)"),
                ("reps", "INT", "NULLABLE", "횟수"),
                ("is_completed", "BOOLEAN", "DEFAULT FALSE", "완료 여부 (체크)"),
                ("rest_time_sec", "INT", "NULLABLE", "휴식 시간(초) (01:24 등)"),
            ]
        },
        {
            "name": "PersonalRecord (개인기록)",
            "desc": "운동 상세 '지난 최고 기록(1RM)' 카드.",
            "screens": "운동 상세(지난 최고 기록 1RM: 75kg)",
            "cols": [
                ("record_id", "BIGINT", "PK, AUTO_INCREMENT", "기록 고유 ID"),
                ("user_id", "BIGINT", "FK -> User", "회원 ID"),
                ("exercise_id", "BIGINT", "FK -> Exercise", "운동 ID"),
                ("record_type", "ENUM('1RM','MAX_VOLUME','MAX_REPS')", "NOT NULL", "기록 유형"),
                ("value_kg", "DECIMAL(8,2)", "NOT NULL", "기록 값 (kg)"),
                ("achieved_at", "DATE", "NOT NULL", "달성일"),
            ]
        },
    ]

    tables3 = [
        {
            "name": "Routine (루틴)",
            "desc": "추천 루틴 목록 + 나만의 루틴. 루틴 상세 정보.",
            "screens": "추천 루틴 목록(파워빌딩 주3회 45분 입문), 루틴 만들기, 루틴 상세(초보자 파워빌딩 45분 근비대 초보자)",
            "cols": [
                ("routine_id", "BIGINT", "PK, AUTO_INCREMENT", "루틴 고유 ID"),
                ("creator_id", "BIGINT", "FK -> User, NULLABLE", "생성자 (추천 루틴은 NULL/ADMIN)"),
                ("name", "VARCHAR(100)", "NOT NULL", "루틴명 (파워 빌딩, 데일리 컷팅 등)"),
                ("goal", "ENUM('MUSCLE','DIET','STAMINA')", "NOT NULL", "목표 (근성장/다이어트/체력증진)"),
                ("difficulty", "ENUM('BEGINNER','INTERMEDIATE','ADVANCED')", "NOT NULL", "난이도 (입문/중급/고급)"),
                ("duration_min", "INT", "NOT NULL", "소요시간 (분)"),
                ("frequency", "VARCHAR(50)", "NULLABLE", "빈도 (주 3회, 매일 등)"),
                ("description", "TEXT", "NULLABLE", "설명"),
                ("image_url", "VARCHAR(500)", "NULLABLE", "대표 이미지 URL"),
                ("is_public", "BOOLEAN", "DEFAULT FALSE", "공개 여부 (탐색 탭 공유)"),
                ("is_recommended", "BOOLEAN", "DEFAULT FALSE", "추천 루틴 여부"),
                ("created_at", "DATETIME", "NOT NULL", "생성일시"),
            ]
        },
        {
            "name": "RoutineExercise (루틴운동구성)",
            "desc": "루틴 상세 운동 구성 리스트.",
            "screens": "루틴 상세(벤치프레스 3세트 10-12회, 바벨스쿼트 4세트 8-10회, 랫풀다운 3세트 12회)",
            "cols": [
                ("routine_exercise_id", "BIGINT", "PK, AUTO_INCREMENT", "루틴운동 고유 ID"),
                ("routine_id", "BIGINT", "FK -> Routine", "루틴 ID"),
                ("exercise_id", "BIGINT", "FK -> Exercise", "운동 ID"),
                ("order_index", "INT", "NOT NULL", "순서"),
                ("target_sets", "INT", "NOT NULL", "목표 세트 수 (3, 4 등)"),
                ("target_reps_min", "INT", "NOT NULL", "최소 목표 횟수 (10, 8 등)"),
                ("target_reps_max", "INT", "NULLABLE", "최대 목표 횟수 (12, 10 등)"),
            ]
        },
        {
            "name": "FavoriteRoutine (루틴 찜)",
            "desc": "루틴 상세 하트 버튼 즐겨찾기.",
            "screens": "루틴 상세(우상단 하트 버튼)",
            "cols": [
                ("favorite_id", "BIGINT", "PK, AUTO_INCREMENT", "찜 고유 ID"),
                ("user_id", "BIGINT", "FK -> User", "회원 ID"),
                ("routine_id", "BIGINT", "FK -> Routine", "루틴 ID"),
                ("created_at", "DATETIME", "NOT NULL", "찜한 일시"),
            ]
        },
        {
            "name": "WorkoutReport (운동리포트)",
            "desc": "오늘 기록 요약 화면. 시간/볼륨/칼로리/주간차트/공유.",
            "screens": "리포트(시간 45:12, 총볼륨 4,250kg, 칼로리 380kcal, 주간운동량 +12%)",
            "cols": [
                ("report_id", "BIGINT", "PK, AUTO_INCREMENT", "리포트 고유 ID"),
                ("user_id", "BIGINT", "FK -> User", "회원 ID"),
                ("session_id", "BIGINT", "FK -> WorkoutSession", "세션 ID"),
                ("report_date", "DATE", "NOT NULL", "리포트 날짜"),
                ("total_time_sec", "INT", "NOT NULL", "총 운동 시간(초)"),
                ("total_volume_kg", "DECIMAL(10,2)", "NOT NULL", "총 볼륨(kg)"),
                ("total_calories", "DECIMAL(8,2)", "NOT NULL", "소모 칼로리(kcal)"),
                ("weekly_change_pct", "DECIMAL(5,2)", "NULLABLE", "주간 변화율(%) (+12% 등)"),
                ("motivation_msg", "VARCHAR(200)", "NULLABLE", "동기부여 메시지"),
                ("shared_at", "DATETIME", "NULLABLE", "공유일시 (공유 안하면 NULL)"),
            ]
        },
    ]

    tables4 = [
        {
            "name": "Notification (알림)",
            "desc": "알림 화면 개인 알림. 예약 확정, 만료 경고 등.",
            "screens": "알림(예약확정 '오전10:00 요가수업 확정', 회원권만료 D-7 '만료 7일 전!')",
            "cols": [
                ("notification_id", "BIGINT", "PK, AUTO_INCREMENT", "알림 고유 ID"),
                ("user_id", "BIGINT", "FK -> User", "대상 회원 ID"),
                ("type", "ENUM('RESERVATION','MEMBERSHIP','WORKOUT','SYSTEM')", "NOT NULL", "알림 유형"),
                ("title", "VARCHAR(200)", "NOT NULL", "알림 제목 (예약 확정, 회원권 만료 D-7)"),
                ("message", "TEXT", "NOT NULL", "알림 내용"),
                ("is_read", "BOOLEAN", "DEFAULT FALSE", "읽음 여부"),
                ("related_url", "VARCHAR(500)", "NULLABLE", "관련 페이지 URL/딥링크"),
                ("created_at", "DATETIME", "NOT NULL", "생성일시"),
            ]
        },
        {
            "name": "Announcement (공지사항)",
            "desc": "홈 공지 미리보기 + 알림/공지 탭.",
            "screens": "홈(설날 연휴 안내 태그, 오운완 챌 이벤트 태그), 알림/공지(NEW '대청소 안내', EVENT '챌린지 3기')",
            "cols": [
                ("announcement_id", "BIGINT", "PK, AUTO_INCREMENT", "공지 고유 ID"),
                ("title", "VARCHAR(200)", "NOT NULL", "제목"),
                ("content", "TEXT", "NOT NULL", "내용"),
                ("tag", "ENUM('NOTICE','EVENT','NEW')", "NOT NULL", "태그 (안내/이벤트/NEW)"),
                ("image_url", "VARCHAR(500)", "NULLABLE", "대표 이미지 URL"),
                ("published_at", "DATETIME", "NOT NULL", "게시일시"),
                ("is_active", "BOOLEAN", "DEFAULT TRUE", "노출 여부"),
            ]
        },
        {
            "name": "Inquiry (1:1 문의)",
            "desc": "문의하기 화면 문의 내역.",
            "screens": "문의하기(답변완료 '회원권 연장 문의', 접수중 'PT 예약 변경 오류', 답변완료 '라커룸 비밀번호')",
            "cols": [
                ("inquiry_id", "BIGINT", "PK, AUTO_INCREMENT", "문의 고유 ID"),
                ("user_id", "BIGINT", "FK -> User", "작성자 ID"),
                ("category", "VARCHAR(50)", "NOT NULL", "카테고리"),
                ("title", "VARCHAR(200)", "NOT NULL", "제목"),
                ("content", "TEXT", "NOT NULL", "내용"),
                ("image_url", "VARCHAR(500)", "NULLABLE", "첨부 이미지 URL"),
                ("status", "ENUM('RECEIVED','IN_PROGRESS','REPLIED')", "NOT NULL", "상태 (접수중/처리중/답변완료)"),
                ("created_at", "DATETIME", "NOT NULL", "작성일시"),
            ]
        },
        {
            "name": "InquiryReply (문의답변)",
            "desc": "1:1 문의에 대한 관리자 답변.",
            "screens": "문의하기(답변 내용 확인)",
            "cols": [
                ("reply_id", "BIGINT", "PK, AUTO_INCREMENT", "답변 고유 ID"),
                ("inquiry_id", "BIGINT", "FK -> Inquiry", "문의 ID"),
                ("admin_name", "VARCHAR(50)", "NOT NULL", "답변자명"),
                ("content", "TEXT", "NOT NULL", "답변 내용"),
                ("created_at", "DATETIME", "NOT NULL", "답변일시"),
            ]
        },
        {
            "name": "FAQ (자주묻는질문)",
            "desc": "문의하기 화면 자주 묻는 질문 목록.",
            "screens": "문의하기(자주 묻는 질문 카드)",
            "cols": [
                ("faq_id", "BIGINT", "PK, AUTO_INCREMENT", "FAQ 고유 ID"),
                ("category", "VARCHAR(50)", "NOT NULL", "카테고리"),
                ("question", "VARCHAR(500)", "NOT NULL", "질문"),
                ("answer", "TEXT", "NOT NULL", "답변"),
                ("order_index", "INT", "NOT NULL", "표시 순서"),
                ("is_active", "BOOLEAN", "DEFAULT TRUE", "노출 여부"),
            ]
        },
    ]

    def draw_table_spec(pdf, table_info, start_new_page=False):
        if start_new_page:
            pdf.add_page()

        if pdf.get_y() > 150:
            pdf.add_page()

        # 테이블 제목
        pdf.set_font("malgun", "B", 10)
        pdf.set_text_color(30, 50, 100)
        pdf.cell(0, 7, table_info["name"], new_x="LMARGIN", new_y="NEXT")

        # 설명
        pdf.set_font("malgun", "", 7)
        pdf.set_text_color(80, 80, 80)
        pdf.cell(0, 4, f"설명: {table_info['desc']}", new_x="LMARGIN", new_y="NEXT")
        pdf.cell(0, 4, f"관련 화면: {table_info['screens']}", new_x="LMARGIN", new_y="NEXT")
        pdf.ln(1)

        # 테이블 헤더
        pdf.set_font("malgun", "B", 7)
        pdf.set_fill_color(50, 50, 50)
        pdf.set_text_color(255, 255, 255)
        pdf.set_draw_color(150, 150, 150)
        pdf.cell(40, 6, "컬럼명", border=1, fill=True, align="C")
        pdf.cell(35, 6, "타입", border=1, fill=True, align="C")
        pdf.cell(50, 6, "제약조건", border=1, fill=True, align="C")
        pdf.cell(120, 6, "설명 (UI 매핑)", border=1, fill=True, align="C", new_x="LMARGIN", new_y="NEXT")

        # 컬럼
        pdf.set_font("malgun", "", 6.5)
        pdf.set_text_color(30, 30, 30)
        fill = False
        for col_name, col_type, constraint, desc in table_info["cols"]:
            if pdf.get_y() > 190:
                pdf.add_page()
                # redraw header
                pdf.set_font("malgun", "B", 10)
                pdf.set_text_color(30, 50, 100)
                pdf.cell(0, 7, table_info["name"] + " (계속)", new_x="LMARGIN", new_y="NEXT")
                pdf.set_font("malgun", "B", 7)
                pdf.set_fill_color(50, 50, 50)
                pdf.set_text_color(255, 255, 255)
                pdf.cell(40, 6, "컬럼명", border=1, fill=True, align="C")
                pdf.cell(35, 6, "타입", border=1, fill=True, align="C")
                pdf.cell(50, 6, "제약조건", border=1, fill=True, align="C")
                pdf.cell(120, 6, "설명 (UI 매핑)", border=1, fill=True, align="C", new_x="LMARGIN", new_y="NEXT")
                pdf.set_font("malgun", "", 6.5)
                pdf.set_text_color(30, 30, 30)
                fill = False

            if 'PK' in constraint:
                pdf.set_fill_color(*C_PK_BG)
            elif 'FK' in constraint:
                pdf.set_fill_color(*C_FK_BG)
            elif fill:
                pdf.set_fill_color(248, 248, 248)
            else:
                pdf.set_fill_color(255, 255, 255)

            is_pk_or_fk = 'PK' in constraint or 'FK' in constraint
            pdf.set_font("malgun", "B" if 'PK' in constraint else "", 6.5)
            pdf.cell(40, 5.5, col_name, border=1, fill=True)
            pdf.set_font("malgun", "", 6.5)
            pdf.cell(35, 5.5, col_type, border=1, fill=True)
            pdf.cell(50, 5.5, constraint, border=1, fill=True)
            pdf.cell(120, 5.5, desc, border=1, fill=True, new_x="LMARGIN", new_y="NEXT")
            fill = not fill

        pdf.ln(4)

    for t in tables:
        draw_table_spec(pdf, t)

    for t in tables2:
        draw_table_spec(pdf, t)

    for t in tables3:
        draw_table_spec(pdf, t)

    for t in tables4:
        draw_table_spec(pdf, t)

    # ════════════════════════════════════════════════════
    # 마지막 페이지: 관계 요약표
    # ════════════════════════════════════════════════════
    pdf.add_page()
    pdf.set_font("malgun", "B", 14)
    pdf.set_text_color(*C_TITLE)
    pdf.cell(0, 10, "엔티티 관계 요약표", align="C", new_x="LMARGIN", new_y="NEXT")
    pdf.ln(3)

    pdf.set_font("malgun", "B", 8)
    pdf.set_fill_color(50, 50, 50)
    pdf.set_text_color(255, 255, 255)
    pdf.set_draw_color(150, 150, 150)
    pdf.cell(10, 7, "No", border=1, fill=True, align="C")
    pdf.cell(50, 7, "부모 엔티티", border=1, fill=True, align="C")
    pdf.cell(20, 7, "관계", border=1, fill=True, align="C")
    pdf.cell(50, 7, "자식 엔티티", border=1, fill=True, align="C")
    pdf.cell(120, 7, "설명", border=1, fill=True, align="C", new_x="LMARGIN", new_y="NEXT")

    relations = [
        ("1", "User", "1 : N", "Membership", "한 회원은 여러 회원권을 보유할 수 있다 (1개월, 3개월 등 갱신)"),
        ("2", "User", "1 : 1", "UserSettings", "한 회원은 하나의 설정 레코드를 갖는다"),
        ("3", "User", "1 : N", "Attendance", "한 회원은 여러 번 출석(QR 체크인)할 수 있다"),
        ("4", "User", "1 : N", "Reservation", "한 회원은 여러 예약을 할 수 있다"),
        ("5", "TimeSlot", "1 : N", "Reservation", "한 시간 슬롯에 여러 회원이 예약할 수 있다"),
        ("6", "Reservation", "1 : 1", "UsageHistory", "하나의 예약은 하나의 이용내역으로 전환된다"),
        ("7", "User", "1 : N", "UsageHistory", "한 회원은 여러 이용내역을 갖는다"),
        ("8", "User", "1 : N", "WorkoutSession", "한 회원은 여러 운동 세션을 생성할 수 있다"),
        ("9", "Routine", "1 : N", "WorkoutSession", "하나의 루틴으로 여러 세션을 시작할 수 있다 (NULLABLE)"),
        ("10", "WorkoutSession", "1 : N", "SessionExercise", "한 세션에는 여러 운동이 포함된다"),
        ("11", "Exercise", "1 : N", "SessionExercise", "하나의 운동종목은 여러 세션에 포함될 수 있다"),
        ("12", "SessionExercise", "1 : N", "ExerciseSet", "한 세션운동에는 여러 세트 기록이 있다"),
        ("13", "User", "1 : N", "PersonalRecord", "한 회원은 여러 개인 최고 기록을 가진다"),
        ("14", "Exercise", "1 : N", "PersonalRecord", "한 운동종목에 대해 여러 기록이 쌓인다"),
        ("15", "Routine", "1 : N", "RoutineExercise", "한 루틴에는 여러 운동이 포함된다"),
        ("16", "Exercise", "1 : N", "RoutineExercise", "한 운동은 여러 루틴에 포함될 수 있다"),
        ("17", "User", "1 : N", "FavoriteRoutine", "한 회원은 여러 루틴을 찜할 수 있다"),
        ("18", "Routine", "1 : N", "FavoriteRoutine", "한 루틴은 여러 회원에게 찜될 수 있다"),
        ("19", "User", "1 : N", "WorkoutReport", "한 회원은 여러 운동 리포트를 가진다"),
        ("20", "WorkoutSession", "1 : 1", "WorkoutReport", "한 세션은 하나의 리포트를 생성한다"),
        ("21", "User", "1 : N", "Notification", "한 회원은 여러 알림을 수신한다"),
        ("22", "User", "1 : N", "Inquiry", "한 회원은 여러 문의를 작성할 수 있다"),
        ("23", "Inquiry", "1 : N", "InquiryReply", "한 문의에 여러 답변이 달릴 수 있다"),
        ("24", "User", "1 : N", "Routine", "한 회원은 여러 커스텀 루틴을 생성할 수 있다"),
    ]

    pdf.set_font("malgun", "", 7)
    pdf.set_text_color(30, 30, 30)
    fill = False
    for no, parent, rel, child, desc in relations:
        if pdf.get_y() > 185:
            pdf.add_page()
            pdf.set_font("malgun", "B", 8)
            pdf.set_fill_color(50, 50, 50)
            pdf.set_text_color(255, 255, 255)
            pdf.cell(10, 7, "No", border=1, fill=True, align="C")
            pdf.cell(50, 7, "부모 엔티티", border=1, fill=True, align="C")
            pdf.cell(20, 7, "관계", border=1, fill=True, align="C")
            pdf.cell(50, 7, "자식 엔티티", border=1, fill=True, align="C")
            pdf.cell(120, 7, "설명", border=1, fill=True, align="C", new_x="LMARGIN", new_y="NEXT")
            pdf.set_font("malgun", "", 7)
            pdf.set_text_color(30, 30, 30)
            fill = False

        if fill:
            pdf.set_fill_color(245, 247, 250)
        else:
            pdf.set_fill_color(255, 255, 255)

        pdf.cell(10, 5.5, no, border=1, fill=True, align="C")
        pdf.set_font("malgun", "B", 7)
        pdf.cell(50, 5.5, parent, border=1, fill=True, align="C")
        pdf.set_font("malgun", "", 7)
        pdf.set_text_color(180, 60, 60)
        pdf.cell(20, 5.5, rel, border=1, fill=True, align="C")
        pdf.set_text_color(30, 30, 30)
        pdf.set_font("malgun", "B", 7)
        pdf.cell(50, 5.5, child, border=1, fill=True, align="C")
        pdf.set_font("malgun", "", 7)
        pdf.cell(120, 5.5, desc, border=1, fill=True, new_x="LMARGIN", new_y="NEXT")
        fill = not fill

    output_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "SmithLife_ERD.pdf")
    pdf.output(output_path)
    print(f"ERD PDF 생성 완료: {output_path}")

if __name__ == "__main__":
    main()
