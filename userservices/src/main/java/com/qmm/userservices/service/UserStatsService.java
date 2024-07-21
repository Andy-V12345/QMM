package com.qmm.userservices.service;

import com.qmm.userservices.controller.LeaderboardEntry;
import com.qmm.userservices.controller.UserStatsRequest;
import com.qmm.userservices.domain.AppUser;
import com.qmm.userservices.domain.UserStats;
import com.qmm.userservices.repository.AppUserRepository;
import com.qmm.userservices.repository.UserStatsRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class UserStatsService {

    private final UserStatsRepository userStatsRepository;
    private final AppUserRepository appUserRepository;

    public UserStats findByUserId(Long user_id) {
        return userStatsRepository.findByUser_Id(user_id);
    }


    public boolean isCorrectUser(Long user_id, AppUser user) {
        return user.getId().equals(user_id);
    }

    public HttpStatus addStatsToUser(UserStatsRequest request, Long user_id) {

        Optional<AppUser> optionalAppUser = appUserRepository.findById(user_id);
        UserStats stats = findByUserId(user_id);


        if (stats == null && optionalAppUser.isPresent()) {
            AppUser appUser = optionalAppUser.get();

            UserStats userStats = UserStats.builder()
                    .additionScore(request.getAdditionScore())
                    .additionTot(request.getAdditionTot())
                    .subtractionScore(request.getSubtractionScore())
                    .subtractionTot(request.getSubtractionTot())
                    .divisionScore(request.getDivisionScore())
                    .divisionTot(request.getDivisionTot())
                    .multiplicationScore(request.getMultiplicationScore())
                    .multiplicationTot(request.getMultiplicationTot())
                    .highScore(request.getHighScore())
                    .ttHighScore(request.getTtHighScore())
                    .user(appUser)
                    .build();

            userStatsRepository.save(userStats);

            return HttpStatus.CREATED;
        }

        if (stats != null) {
            return HttpStatus.CONFLICT;
        }

        return HttpStatus.NOT_FOUND;

    }

    public boolean updateUserStats(UserStatsRequest request, Long stat_id) {
        Optional<UserStats> optStats = userStatsRepository.findById(stat_id);

        if (optStats.isPresent()) {
            UserStats stats = optStats.get();

            stats.setAdditionScore(request.getAdditionScore());
            stats.setAdditionTot(request.getAdditionTot());
            stats.setSubtractionScore(request.getSubtractionScore());
            stats.setSubtractionTot(request.getSubtractionTot());
            stats.setMultiplicationScore(request.getMultiplicationScore());
            stats.setMultiplicationTot(request.getMultiplicationTot());
            stats.setDivisionScore(request.getDivisionScore());
            stats.setDivisionTot(request.getDivisionTot());
            stats.setHighScore(request.getHighScore());
            stats.setTtHighScore(request.getTtHighScore());

            userStatsRepository.save(stats);

            return true;
        }

        return false;
    }

    public boolean deleteUserStats(Long stat_id) {
        Optional<UserStats> optStats = userStatsRepository.findById(stat_id);

        if (optStats.isPresent()) {
            userStatsRepository.deleteById(stat_id);

            return true;
        }

        return false;
    }

    public List<LeaderboardEntry> getLeaderboard(Integer topN) {
        List<UserStats> userStatsList = userStatsRepository.getLeaderboard(topN);

        return userStatsList.stream().map(userStats -> new LeaderboardEntry(userStats.getTtHighScore(), userStats.getUser().getAcctName())).collect(Collectors.toList());
    }
}
