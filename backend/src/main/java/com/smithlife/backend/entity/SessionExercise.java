package com.smithlife.backend.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.List;

@Entity
@Table(name = "session_exercise")
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SessionExercise {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "session_exercise_id")
    private Long sessionExerciseId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "session_id", nullable = false)
    private WorkoutSession session;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "exercise_id", nullable = false)
    private Exercise exercise;

    @Column(name = "order_index", nullable = false)
    private Integer orderIndex;

    @Column(name = "target_sets", nullable = false)
    private Integer targetSets;

    @Column(name = "target_reps", nullable = false)
    private Integer targetReps;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private Status status;

    @OneToMany(mappedBy = "sessionExercise", fetch = FetchType.LAZY)
    private List<ExerciseSet> exerciseSets;

    public enum Status {
        PENDING, IN_PROGRESS, COMPLETED
    }
}
