package com.smithlife.backend.service;

import com.smithlife.backend.dto.response.ExerciseResponse;
import com.smithlife.backend.repository.ExerciseRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ExerciseService {

    private final ExerciseRepository exerciseRepository;

    /** 전체 운동 목록 (bodyPart 필터 선택) */
    public List<ExerciseResponse> getExercises(String bodyPart) {
        if (bodyPart != null && !bodyPart.isBlank()) {
            return exerciseRepository.findAllByBodyPartOrderByNameAsc(bodyPart)
                    .stream()
                    .map(ExerciseResponse::from)
                    .collect(Collectors.toList());
        }
        return exerciseRepository.findAllByOrderByBodyPartAscNameAsc()
                .stream()
                .map(ExerciseResponse::from)
                .collect(Collectors.toList());
    }
}
