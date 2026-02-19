package com.smithlife.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "user")
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id")
    private Long userId;

    @Column(name = "email", nullable = false, unique = true, length = 100)
    private String email;

    @Column(name = "password_hash", nullable = false, length = 255)
    private String passwordHash;

    @Column(name = "name", nullable = false, length = 50)
    private String name;

    @Column(name = "phone", nullable = false, unique = true, length = 20)
    private String phone;

    @Column(name = "profile_image_url", length = 500)
    private String profileImageUrl;

    @Enumerated(EnumType.STRING)
    @Column(name = "role", nullable = false)
    private Role role;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @OneToMany(mappedBy = "user", fetch = FetchType.LAZY)
    private List<Membership> memberships;

    @OneToMany(mappedBy = "user", fetch = FetchType.LAZY)
    private List<Attendance> attendances;

    @OneToMany(mappedBy = "user", fetch = FetchType.LAZY)
    private List<Reservation> reservations;

    @OneToMany(mappedBy = "user", fetch = FetchType.LAZY)
    private List<UsageHistory> usageHistories;

    @OneToMany(mappedBy = "creator", fetch = FetchType.LAZY)
    private List<Routine> routines;

    @OneToMany(mappedBy = "user", fetch = FetchType.LAZY)
    private List<FavoriteRoutine> favoriteRoutines;

    @OneToMany(mappedBy = "user", fetch = FetchType.LAZY)
    private List<WorkoutSession> workoutSessions;

    @OneToMany(mappedBy = "user", fetch = FetchType.LAZY)
    private List<PersonalRecord> personalRecords;

    @OneToMany(mappedBy = "user", fetch = FetchType.LAZY)
    private List<Notification> notifications;

    @OneToMany(mappedBy = "user", fetch = FetchType.LAZY)
    private List<Inquiry> inquiries;

    public enum Role {
        USER, ADMIN
    }
}
