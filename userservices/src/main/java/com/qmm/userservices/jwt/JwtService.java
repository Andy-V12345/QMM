package com.qmm.userservices.jwt;

import com.qmm.userservices.domain.AppUser;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import java.security.Key;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

@Service
public class JwtService {

    private static final String SECRET_KEY = "BfioRrG6OWWC9uESodU8tloXDsPRKVhwR7qnQpgios+nVT7+Ce/6PsOQW3Hq7ncn";

    private <T> T extractClaim(String jwtToken, Function<Claims, T> claimsTFunction) {
        Claims claims = extractAllClaims(jwtToken);
        return claimsTFunction.apply(claims);
    }

    public String extractUsername(String jwtToken) {
        return extractClaim(jwtToken, Claims::getSubject);
    }

    public Date extractExpiry(String jwtToken) {
        return extractClaim(jwtToken, Claims::getExpiration);
    }

    private Claims extractAllClaims(String jwtToken) {
        return Jwts
                .parserBuilder()
                .setSigningKey(this.getSigningKey())
                .build()
                .parseClaimsJws(jwtToken)
                .getBody();
    }

    private Key getSigningKey() {
        byte[] keyBytes = Decoders.BASE64.decode(SECRET_KEY);
        return Keys.hmacShaKeyFor(keyBytes);
    }

    private boolean isTokenExpired(String jwtToken) {
        return extractExpiry(jwtToken).before(new Date());
    }
    public boolean isTokenValid(String jwtToken, UserDetails userDetails) {
        String extractedUsername = extractUsername(jwtToken);

        return (extractedUsername.equals(userDetails.getUsername()) && !isTokenExpired(jwtToken));
    }

    public String generateToken(UserDetails userDetails) {
        return generateToken(new HashMap<>(), userDetails);
    }

    public String generateToken(Map<String, Object> claims, UserDetails userDetails) {
        return Jwts
                .builder()
                .setClaims(claims)
                .setSubject(userDetails.getUsername())
                .setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + 1000L * 60 * 60 * 8760 * 200))
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
                .compact();

    }
}
