package com.smithlife.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "workout_report")
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WorkoutReport {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "report_id")
    private Long reportId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "session_id", nullable = false, unique = true)
    private WorkoutSession session;

    @Column(name = "report_date", nullable = false)
    private LocalDate reportDate;

    @Column(name = "total_time_sec", nullable = false)
    private Integer totalTimeSec;

    @Column(name = "total_volume_kg", nullable = false, precision = 10, scale = 2)
    private BigDecimal totalVolumeKg;

    @Column(name = "total_calories", nullable = false, precision = 8, scale = 2)
    private BigDecimal totalCalories;

    @Column(name = "weekly_change_pct", precision = 5, scale = 2)
    private BigDecimal weeklyChangePct;

    @Column(name = "motivation_msg", length = 200)
    private String motivationMsg;

    @Column(name = "shared_at")
    private LocalDateTime sharedAt;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
}
