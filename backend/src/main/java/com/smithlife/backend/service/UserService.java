package com.smithlife.backend.service;

import com.smithlife.backend.common.ErrorCode;
import com.smithlife.backend.dto.request.ChangePasswordRequest;
import com.smithlife.backend.dto.request.UpdateProfileRequest;
import com.smithlife.backend.dto.response.UserProfileResponse;
import com.smithlife.backend.entity.User;
import com.smithlife.backend.exception.CustomException;
import com.smithlife.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    // 내 프로필 조회
    @Transactional(readOnly = true)
    public UserProfileResponse getMyProfile(Long userId) {
        User user = findActiveUser(userId);
        return UserProfileResponse.from(user);
    }

    // 프로필 수정
    @Transactional
    public UserProfileResponse updateProfile(Long userId, UpdateProfileRequest request) {
        User user = findActiveUser(userId);

        if (!user.getPhone().equals(request.getPhone())
                && userRepository.existsByPhone(request.getPhone())) {
            throw new CustomException(ErrorCode.PHONE_ALREADY_EXISTS);
        }

        User updated = User.builder()
                .userId(user.getUserId())
                .email(user.getEmail())
                .passwordHash(user.getPasswordHash())
                .name(request.getName())
                .phone(request.getPhone())
                .profileImageUrl(request.getProfileImageUrl() != null
                        ? request.getProfileImageUrl()
                        : user.getProfileImageUrl())
                .role(user.getRole())
                .isActive(user.getIsActive())
                .build();

        return UserProfileResponse.from(userRepository.save(updated));
    }

    // 비밀번호 변경
    @Transactional
    public void changePassword(Long userId, ChangePasswordRequest request) {
        User user = findActiveUser(userId);

        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPasswordHash())) {
            throw new CustomException(ErrorCode.INVALID_PASSWORD);
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
    }

    // 회원 탈퇴
    @Transactional
    public void deleteAccount(Long userId, String password) {
        User user = findActiveUser(userId);

        if (!passwordEncoder.matches(password, user.getPasswordHash())) {
            throw new CustomException(ErrorCode.INVALID_PASSWORD);
        }

        User deactivated = User.builder()
                .userId(user.getUserId())
                .email(user.getEmail())
                .passwordHash(user.getPasswordHash())
                .name(user.getName())
                .phone(user.getPhone())
                .profileImageUrl(user.getProfileImageUrl())
                .role(user.getRole())
                .isActive(false)
                .build();

        userRepository.save(deactivated);
    }

    private User findActiveUser(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
        if (!user.getIsActive()) {
            throw new CustomException(ErrorCode.ACCOUNT_DEACTIVATED);
        }
        return user;
    }
}
