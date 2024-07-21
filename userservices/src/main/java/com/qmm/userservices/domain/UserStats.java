package com.qmm.userservices.domain;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserStats {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    private Long additionScore;

    private Long additionTot;

    private Long subtractionScore;

    private Long subtractionTot;

    private Long multiplicationScore;

    private Long multiplicationTot;

    private Long divisionScore;

    private Long divisionTot;

    private Long highScore;

    private Long ttHighScore;

    @OneToOne
    @JoinColumn(name="user_id")
    @JsonIgnore
    private AppUser user;

}
