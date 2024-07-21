package com.qmm.userservices.repository;

import com.qmm.userservices.domain.UserStats;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.lang.NonNull;

import java.util.List;

public interface UserStatsRepository extends JpaRepository<UserStats, Long> {

    UserStats findByUser_Id(@NonNull Long id);

    @Query(value = "SELECT * FROM user_stats u ORDER BY u.tt_high_score DESC LIMIT :limit", nativeQuery = true)
    List<UserStats> getLeaderboard(@Param("limit") Integer topN);

}
