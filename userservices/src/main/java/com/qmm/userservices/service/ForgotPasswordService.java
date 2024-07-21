package com.qmm.userservices.service;

import com.qmm.userservices.domain.AppUser;
import com.qmm.userservices.repository.AppUserRepository;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@Transactional
public class ForgotPasswordService {

    @Autowired
    private AppUserRepository appUserRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JavaMailSender mailSender;

    public AppUser getByResetPasswordToken(String token) {
        return appUserRepository.findByResetPasswordToken(token);
    }

    public HttpStatus updateResetPasswordToken(String token, String email) {
        AppUser user = appUserRepository.findByEmailIgnoreCase(email);
        if (user != null) {
            user.setResetPasswordToken(token);
            appUserRepository.save(user);

            return HttpStatus.OK;
        }
        else {
            return HttpStatus.NOT_FOUND;
        }
    }

    public void updatePassword(AppUser user, String newPassword) {
        user.setPassword(passwordEncoder.encode(newPassword));
        user.setResetPasswordToken(null);
        appUserRepository.save(user);
    }

    public void sendEmail(String email, String token) throws MessagingException {
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message);

        helper.setFrom("quickmentalmath@gmail.com");
        helper.setTo(email);

        String subject = "Here's the code to reset your password!";

        String content = "<p>Hello,</p>"
                + "<p>You have requested to reset your password for your Quick Mental Math account.</p>"
                + "<p>Enter your code in the app to reset your password:</p>"
                + "<p>" + token + "</p>"
                + "<br>"
                + "<p>Ignore this email if you remember your password, "
                + "or if you have not made the request.</p>";

        helper.setSubject(subject);
        helper.setText(content, true);
        mailSender.send(message);
    }
}
