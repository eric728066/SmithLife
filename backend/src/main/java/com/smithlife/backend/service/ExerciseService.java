package com.smithlife.backend.service;

import com.smithlife.backend.dto.response.ExerciseResponse;
import com.smithlife.backend.dto.response.PersonalRecordResponse;
import com.smithlife.backend.repository.ExerciseRepository;
import com.smithlife.backend.repository.PersonalRecordRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ExerciseService {

    private final ExerciseRepository exerciseRepository;
    private final PersonalRecordRepository personalRecordRepository;

    /**
     * 운동 목록 조회 (검색어 또는 부위 필터)
     */
    @Transactional(readOnly = true)
    public List<ExerciseResponse> getExercises(String keyword) {
        if (keyword != null && !keyword.isBlank()) {
            return exerciseRepository
                    .findByNameContainingIgnoreCaseOrBodyPartContainingIgnoreCase(keyword, keyword)
                    .stream()
                    .map(ExerciseResponse::from)
                    .collect(Collectors.toList());
        }
        return exerciseRepository.findAll()
                .stream()
                .map(ExerciseResponse::from)
                .collect(Collectors.toList());
    }

    /**
     * 개인 최고 기록 조회
     */
    @Transactional(readOnly = true)
    public List<PersonalRecordResponse> getPersonalRecords(Long userId) {
        return personalRecordRepository.findByUserUserIdOrderByAchievedAtDesc(userId)
                .stream()
                .map(PersonalRecordResponse::from)
                .collect(Collectors.toList());
    }
}
