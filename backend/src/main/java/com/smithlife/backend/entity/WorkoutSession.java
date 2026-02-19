package com.smithlife.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "workout_session")
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WorkoutSession {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "session_id")
    private Long sessionId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "routine_id")
    private Routine routine;

    @Column(name = "session_name", nullable = false, length = 100)
    private String sessionName;

    @Column(name = "start_time", nullable = false)
    private LocalDateTime startTime;

    @Column(name = "end_time")
    private LocalDateTime endTime;

    @Column(name = "total_duration_sec", nullable = false)
    private Integer totalDurationSec;

    @Column(name = "total_volume_kg", nullable = false, precision = 10, scale = 2)
    private BigDecimal totalVolumeKg;

    @Column(name = "total_calories", nullable = false, precision = 8, scale = 2)
    private BigDecimal totalCalories;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private Status status;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @OneToMany(mappedBy = "session", fetch = FetchType.LAZY)
    private List<SessionExercise> sessionExercises;

    @OneToOne(mappedBy = "session", fetch = FetchType.LAZY)
    private WorkoutReport workoutReport;

    public enum Status {
        ACTIVE, COMPLETED, PAUSED
    }
}
