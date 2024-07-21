package com.qmm.userservices.repository;

import com.qmm.userservices.domain.AppUser;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.lang.NonNull;

public interface AppUserRepository extends JpaRepository<AppUser, Long> {


    boolean existsByEmailIgnoreCase(@NonNull String email);

    AppUser findByResetPasswordToken(String resetPasswordToken);

    AppUser findByEmailIgnoreCase(String email);

    boolean existsByAcctNameIgnoreCase(String acctName);


    @Override
    void deleteById(Long aLong);
}
