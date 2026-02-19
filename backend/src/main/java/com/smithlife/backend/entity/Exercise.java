package com.smithlife.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "exercise")
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Exercise {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "exercise_id")
    private Long exerciseId;

    @Column(name = "name", nullable = false, length = 100)
    private String name;

    @Column(name = "body_part", nullable = false, length = 50)
    private String bodyPart;

    @Column(name = "equipment", length = 50)
    private String equipment;

    @Column(name = "image_url", length = 500)
    private String imageUrl;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @OneToMany(mappedBy = "exercise", fetch = FetchType.LAZY)
    private List<RoutineExercise> routineExercises;

    @OneToMany(mappedBy = "exercise", fetch = FetchType.LAZY)
    private List<SessionExercise> sessionExercises;

    @OneToMany(mappedBy = "exercise", fetch = FetchType.LAZY)
    private List<PersonalRecord> personalRecords;
}
