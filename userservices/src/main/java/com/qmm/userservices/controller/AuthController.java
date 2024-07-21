package com.qmm.userservices.controller;

import com.qmm.userservices.auth.AuthLoginRequest;
import com.qmm.userservices.auth.AuthRegisterRequest;
import com.qmm.userservices.auth.AuthResponse;
import com.qmm.userservices.domain.AppUser;
import com.qmm.userservices.repository.AppUserRepository;
import com.qmm.userservices.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final AppUserRepository appUserRepository;

    @PostMapping("/auth/register")
    public ResponseEntity<?> register(@RequestBody AuthRegisterRequest request) {
        AuthResponse response = authService.register(request);

        return switch (response.getStatus()) {
            case "USERNAME_TAKEN", "EMAIL_TAKEN" -> ResponseEntity.status(HttpStatus.CONFLICT).body(response);
            case "INVALID_PASSWORD" -> ResponseEntity.status(HttpStatus.UNPROCESSABLE_ENTITY).body(response);
            default -> ResponseEntity.ok(response);
        };

    }

    @PostMapping("/auth/login")
    public ResponseEntity<AuthResponse> login(@RequestBody AuthLoginRequest request) {
        AuthResponse response = authService.login(request);

        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/deleteAccount/{user_id}")
    public ResponseEntity<?> deleteAccount(@PathVariable("user_id") Long user_id, @AuthenticationPrincipal AppUser user) {
        if (!user.getId().equals(user_id)) {
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }

        authService.deleteAccount(user_id);
        return new ResponseEntity<>(HttpStatus.OK);
    }
}
