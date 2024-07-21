package com.qmm.userservices.service;

import com.qmm.userservices.auth.AuthLoginRequest;
import com.qmm.userservices.auth.AuthRegisterRequest;
import com.qmm.userservices.auth.AuthResponse;
import com.qmm.userservices.domain.AppUser;
import com.qmm.userservices.domain.Role;
import com.qmm.userservices.jwt.JwtService;
import com.qmm.userservices.repository.AppUserRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.HashMap;

@Service
@RequiredArgsConstructor
@Transactional
public class AuthService {

    private final AppUserRepository appUserRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;

    private boolean isUsernameTaken(String username) {
        return appUserRepository.existsByAcctNameIgnoreCase(username);
    }
    private boolean isEmailTaken(String email) {
        return appUserRepository.existsByEmailIgnoreCase(email);
    }

    private boolean isPasswordValid(String password) {
        return password.length() >= 6;
    }

    public AuthResponse register(AuthRegisterRequest request) {

        if (isUsernameTaken(request.getUsername())) {
            return AuthResponse.builder()
                    .status("USERNAME_TAKEN")
                    .build();
        }

        if (isEmailTaken(request.getEmail())) {
            System.out.println(request.getEmail());
            return AuthResponse.builder()
                    .status("EMAIL_TAKEN")
                    .build();
        }

        if (!isPasswordValid(request.getPassword())) {
            return AuthResponse.builder()
                    .status("INVALID_PASSWORD")
                    .build();
        }

        AppUser newAppUser = AppUser.builder()
                .email(request.getEmail())
                .acctName(request.getUsername())
                .password(passwordEncoder.encode(request.getPassword()))
                .role(Role.USER)
                .build();

        AppUser savedUser = appUserRepository.save(newAppUser);

        return new AuthResponse("USER_CREATED", savedUser.getId(), savedUser.getAcctName(), jwtService.generateToken(newAppUser));
    }

    public AuthResponse login(AuthLoginRequest request) {
        var auth = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail(),
                        request.getPassword()
                )
        );

        var user = ((AppUser) auth.getPrincipal());

        return new AuthResponse("LOGGED_IN", user.getId(), user.getAcctName(), jwtService.generateToken(user));
    }

    public void deleteAccount(Long userId) {
        appUserRepository.deleteById(userId);
    }
}
