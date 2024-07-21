package com.qmm.userservices.controller;

import com.qmm.userservices.domain.AppUser;
import com.qmm.userservices.service.ForgotPasswordService;
import jakarta.mail.MessagingException;
import net.bytebuddy.utility.RandomString;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.repository.query.Param;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
public class ForgotPasswordController {
    @Autowired
    private ForgotPasswordService forgotPasswordService;

    @PostMapping("/forgot_password")
    public ResponseEntity<?> processForgotPasswordRequest(@RequestBody ForgotPasswordRequest request) {
        String token = RandomString.make(10);

        HttpStatus result = forgotPasswordService.updateResetPasswordToken(token, request.getEmail());

        if (result == HttpStatus.OK) {
            try {
                forgotPasswordService.sendEmail(request.getEmail(), token);
            } catch (MessagingException e) {
                return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
            }

        }

        return new ResponseEntity<>(result);

    }

    @GetMapping("/reset_password")
    public ResponseEntity<?> resetPasswordForm(@Param(value = "token") String token) {
        AppUser user = forgotPasswordService.getByResetPasswordToken(token);

        if (user == null) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }

        return new ResponseEntity<>(HttpStatus.OK);
    }

    @PostMapping("/reset_password")
    public ResponseEntity<?> resetPassword(@RequestBody ResetPasswordRequest request) {
        AppUser user = forgotPasswordService.getByResetPasswordToken(request.getToken());

        if (user == null) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }

        if (request.getPassword().length() < 6) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("INVALID_PASSWORD_LENGTH");
        }

        forgotPasswordService.updatePassword(user, request.getPassword());
        return ResponseEntity.status(HttpStatus.OK).body("PASSWORD_UPDATED");
    }



}
