package com.smithlife.backend.service;

import com.smithlife.backend.common.ErrorCode;
import com.smithlife.backend.dto.request.*;
import com.smithlife.backend.dto.response.EmailCheckResponse;
import com.smithlife.backend.dto.response.TokenResponse;
import com.smithlife.backend.entity.User;
import com.smithlife.backend.exception.CustomException;
import com.smithlife.backend.repository.UserRepository;
import com.smithlife.backend.security.JwtUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    // 회원가입
    @Transactional
    public void signup(SignupRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new CustomException(ErrorCode.EMAIL_ALREADY_EXISTS);
        }
        if (userRepository.existsByPhone(request.getPhone())) {
            throw new CustomException(ErrorCode.PHONE_ALREADY_EXISTS);
        }

        User user = User.builder()
                .name(request.getName())
                .email(request.getEmail())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .phone(request.getPhone())
                .role(User.Role.USER)
                .isActive(true)
                .build();

        userRepository.save(user);
        log.info("New user registered: {}", request.getEmail());
    }

    // 로그인
    @Transactional(readOnly = true)
    public TokenResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        if (!user.getIsActive()) {
            throw new CustomException(ErrorCode.ACCOUNT_DEACTIVATED);
        }

        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new CustomException(ErrorCode.INVALID_PASSWORD);
        }

        String accessToken = jwtUtil.generateAccessToken(user.getUserId(), user.getEmail());
        String refreshToken = jwtUtil.generateRefreshToken(user.getUserId());

        return TokenResponse.of(accessToken, refreshToken, user.getUserId(), user.getName(), user.getEmail());
    }

    // 토큰 갱신
    public TokenResponse refreshToken(TokenRefreshRequest request) {
        String refreshToken = request.getRefreshToken();

        if (!jwtUtil.validateToken(refreshToken)) {
            throw new CustomException(ErrorCode.REFRESH_TOKEN_EXPIRED);
        }

        Long userId = jwtUtil.getUserId(refreshToken);
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        String newAccessToken = jwtUtil.generateAccessToken(user.getUserId(), user.getEmail());
        String newRefreshToken = jwtUtil.generateRefreshToken(user.getUserId());

        return TokenResponse.of(newAccessToken, newRefreshToken, user.getUserId(), user.getName(), user.getEmail());
    }

    // 이메일 중복 확인
    @Transactional(readOnly = true)
    public EmailCheckResponse checkEmail(String email) {
        return userRepository.existsByEmail(email)
                ? EmailCheckResponse.unavailable()
                : EmailCheckResponse.available();
    }

    // 이메일 찾기
    @Transactional(readOnly = true)
    public String findEmail(FindEmailRequest request) {
        User user = userRepository.findByPhone(request.getPhone())
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        String email = user.getEmail();
        int atIndex = email.indexOf("@");
        String masked = email.substring(0, 3) + "***" + email.substring(atIndex);
        return masked;
    }

    // 비밀번호 재설정 요청
    @Transactional(readOnly = true)
    public void requestPasswordReset(PasswordResetRequest request) {
        userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        // TODO: 이메일 발송 기능 추가 (SMTP or 외부 서비스)
        log.info("Password reset requested for: {}", request.getEmail());
    }

    // 전화번호 + 이름으로 비밀번호 재설정
    @Transactional
    public void resetPasswordByPhone(ResetPasswordByPhoneRequest request) {
        User user = userRepository.findByPhone(request.getPhone())
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        if (!user.getName().equals(request.getName())) {
            throw new CustomException(ErrorCode.USER_NOT_FOUND);
        }

        User updated = User.builder()
                .userId(user.getUserId())
                .email(user.getEmail())
                .passwordHash(passwordEncoder.encode(request.getNewPassword()))
                .name(user.getName())
                .phone(user.getPhone())
                .profileImageUrl(user.getProfileImageUrl())
                .role(user.getRole())
                .isActive(user.getIsActive())
                .build();

        userRepository.save(updated);
        log.info("Password reset by phone for user: {}", user.getEmail());
    }
}
