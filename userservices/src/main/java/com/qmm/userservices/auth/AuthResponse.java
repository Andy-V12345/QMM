package com.qmm.userservices.auth;

import lombok.*;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class AuthResponse {
    private String status;
    private Long id;
    private String username;
    private String jwtToken;
}
