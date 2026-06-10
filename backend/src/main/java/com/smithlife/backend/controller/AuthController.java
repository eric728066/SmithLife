package com.smithlife.backend.controller;

import com.smithlife.backend.common.ApiResponse;
import com.smithlife.backend.dto.request.*;
import com.smithlife.backend.dto.response.EmailCheckResponse;
import com.smithlife.backend.dto.response.TokenResponse;
import com.smithlife.backend.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    // 회원가입
    @PostMapping("/signup")
    public ResponseEntity<ApiResponse<Void>> signup(@Valid @RequestBody SignupRequest request) {
        authService.signup(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok("회원가입이 완료되었습니다."));
    }

    // 로그인
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<TokenResponse>> login(@Valid @RequestBody LoginRequest request) {
        TokenResponse tokenResponse = authService.login(request);
        return ResponseEntity.ok(ApiResponse.ok("로그인 성공", tokenResponse));
    }

    // 토큰 갱신
    @PostMapping("/refresh")
    public ResponseEntity<ApiResponse<TokenResponse>> refresh(@Valid @RequestBody TokenRefreshRequest request) {
        TokenResponse tokenResponse = authService.refreshToken(request);
        return ResponseEntity.ok(ApiResponse.ok("토큰 갱신 성공", tokenResponse));
    }

    // 로그아웃
    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Void>> logout() {
        // 클라이언트에서 토큰 삭제 처리 (서버는 stateless)
        return ResponseEntity.ok(ApiResponse.ok("로그아웃 되었습니다."));
    }

    // 이메일 중복 확인
    @GetMapping("/check-email")
    public ResponseEntity<ApiResponse<EmailCheckResponse>> checkEmail(@RequestParam String email) {
        EmailCheckResponse result = authService.checkEmail(email);
        return ResponseEntity.ok(ApiResponse.ok(result));
    }

    // 이메일 찾기
    @PostMapping("/find-email")
    public ResponseEntity<ApiResponse<String>> findEmail(@Valid @RequestBody FindEmailRequest request) {
        String maskedEmail = authService.findEmail(request);
        return ResponseEntity.ok(ApiResponse.ok("이메일 조회 성공", maskedEmail));
    }

    // 비밀번호 재설정 요청
    @PostMapping("/request-password-reset")
    public ResponseEntity<ApiResponse<Void>> requestPasswordReset(@Valid @RequestBody PasswordResetRequest request) {
        authService.requestPasswordReset(request);
        return ResponseEntity.ok(ApiResponse.ok("비밀번호 재설정 이메일이 발송되었습니다."));
    }

    // 전화번호 + 이름으로 비밀번호 재설정
    @PostMapping("/reset-password")
    public ResponseEntity<ApiResponse<Void>> resetPasswordByPhone(@Valid @RequestBody ResetPasswordByPhoneRequest request) {
        authService.resetPasswordByPhone(request);
        return ResponseEntity.ok(ApiResponse.ok("비밀번호가 변경되었습니다."));
    }
}
