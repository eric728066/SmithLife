package com.smithlife.backend.repository;

import com.smithlife.backend.entity.Membership;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface MembershipRepository extends JpaRepository<Membership, Long> {
    Optional<Membership> findTopByUserUserIdAndStatusOrderByEndDateDesc(Long userId, Membership.Status status);
    List<Membership> findAllByUserUserIdOrderByCreatedAtDesc(Long userId);
}
