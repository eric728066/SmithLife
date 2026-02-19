package com.smithlife.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "routine")
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Routine {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "routine_id")
    private Long routineId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "creator_id")
    private User creator;

    @Column(name = "name", nullable = false, length = 100)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(name = "goal", nullable = false)
    private Goal goal;

    @Enumerated(EnumType.STRING)
    @Column(name = "difficulty", nullable = false)
    private Difficulty difficulty;

    @Column(name = "estimated_min", nullable = false)
    private Integer estimatedMin;

    @Column(name = "frequency", length = 50)
    private String frequency;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "image_url", length = 500)
    private String imageUrl;

    @Column(name = "is_public", nullable = false)
    private Boolean isPublic;

    @Column(name = "is_recommended", nullable = false)
    private Boolean isRecommended;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @OneToMany(mappedBy = "routine", fetch = FetchType.LAZY)
    private List<RoutineExercise> routineExercises;

    @OneToMany(mappedBy = "routine", fetch = FetchType.LAZY)
    private List<FavoriteRoutine> favoriteRoutines;

    @OneToMany(mappedBy = "routine", fetch = FetchType.LAZY)
    private List<WorkoutSession> workoutSessions;

    public enum Goal {
        MUSCLE_GAIN, DIET, STAMINA
    }

    public enum Difficulty {
        BEGINNER, INTERMEDIATE, ADVANCED
    }
}
