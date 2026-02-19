package com.smithlife.backend.common;

import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
public enum ErrorCode {

    // 인증
    UNAUTHORIZED(HttpStatus.UNAUTHORIZED, "AUTH_001", "인증이 필요합니다."),
    INVALID_TOKEN(HttpStatus.UNAUTHORIZED, "AUTH_002", "유효하지 않은 토큰입니다."),
    EXPIRED_TOKEN(HttpStatus.UNAUTHORIZED, "AUTH_003", "만료된 토큰입니다."),
    REFRESH_TOKEN_EXPIRED(HttpStatus.UNAUTHORIZED, "AUTH_004", "Refresh 토큰이 만료되었습니다."),
    INVALID_PASSWORD(HttpStatus.UNAUTHORIZED, "AUTH_005", "비밀번호가 올바르지 않습니다."),
    RESET_CODE_INVALID(HttpStatus.BAD_REQUEST, "AUTH_006", "재설정 코드가 유효하지 않습니다."),

    // 회원
    USER_NOT_FOUND(HttpStatus.NOT_FOUND, "USER_001", "존재하지 않는 회원입니다."),
    EMAIL_ALREADY_EXISTS(HttpStatus.CONFLICT, "USER_002", "이미 사용 중인 이메일입니다."),
    PHONE_ALREADY_EXISTS(HttpStatus.CONFLICT, "USER_003", "이미 사용 중인 전화번호입니다."),
    ACCOUNT_DEACTIVATED(HttpStatus.FORBIDDEN, "USER_004", "탈퇴된 계정입니다."),

    // 예약
    RESERVATION_NOT_FOUND(HttpStatus.NOT_FOUND, "RESV_001", "예약을 찾을 수 없습니다."),
    SLOT_FULL(HttpStatus.CONFLICT, "RESV_002", "해당 시간대가 만석입니다."),
    DUPLICATE_RESERVATION(HttpStatus.CONFLICT, "RESV_003", "이미 예약한 시간대입니다."),
    ALREADY_CANCELLED(HttpStatus.BAD_REQUEST, "RESV_004", "이미 취소된 예약입니다."),
    SLOT_NOT_FOUND(HttpStatus.NOT_FOUND, "RESV_005", "해당 시간 슬롯을 찾을 수 없습니다."),
    PAST_DATE_RESERVATION(HttpStatus.BAD_REQUEST, "RESV_006", "지난 날짜에는 예약할 수 없습니다."),
    FACILITY_NOT_FOUND(HttpStatus.NOT_FOUND, "RESV_007", "시설을 찾을 수 없습니다."),

    // 운동 세션
    SESSION_NOT_FOUND(HttpStatus.NOT_FOUND, "SESS_001", "세션을 찾을 수 없습니다."),
    SESSION_ALREADY_ENDED(HttpStatus.BAD_REQUEST, "SESS_002", "이미 종료된 세션입니다."),
    NO_ACTIVE_SESSION(HttpStatus.NOT_FOUND, "SESS_003", "진행 중인 세션이 없습니다."),
    SESSION_ALREADY_ACTIVE(HttpStatus.CONFLICT, "SESS_004", "이미 진행 중인 세션이 있습니다."),
    EXERCISE_NOT_FOUND(HttpStatus.NOT_FOUND, "SESS_005", "운동을 찾을 수 없습니다."),

    // 루틴
    ROUTINE_NOT_FOUND(HttpStatus.NOT_FOUND, "RTN_001", "루틴을 찾을 수 없습니다."),
    ALREADY_FAVORITED(HttpStatus.CONFLICT, "RTN_002", "이미 즐겨찾기에 추가된 루틴입니다."),

    // 파일
    FILE_TOO_LARGE(HttpStatus.BAD_REQUEST, "FILE_001", "파일 크기가 너무 큽니다."),
    INVALID_FILE_TYPE(HttpStatus.BAD_REQUEST, "FILE_002", "지원하지 않는 파일 형식입니다."),

    // 공통
    INVALID_INPUT(HttpStatus.BAD_REQUEST, "COMMON_001", "입력값이 올바르지 않습니다."),
    RESOURCE_NOT_FOUND(HttpStatus.NOT_FOUND, "COMMON_002", "리소스를 찾을 수 없습니다."),
    INTERNAL_SERVER_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "COMMON_003", "서버 오류가 발생했습니다."),
    FORBIDDEN(HttpStatus.FORBIDDEN, "COMMON_004", "접근 권한이 없습니다.");

    private final HttpStatus httpStatus;
    private final String code;
    private final String message;

    ErrorCode(HttpStatus httpStatus, String code, String message) {
        this.httpStatus = httpStatus;
        this.code = code;
        this.message = message;
    }
}
