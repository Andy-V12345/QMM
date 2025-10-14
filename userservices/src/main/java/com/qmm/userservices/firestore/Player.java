package com.qmm.userservices.firestore;

import com.google.cloud.Timestamp;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

@Getter
@Setter
@AllArgsConstructor
public class Player {
    private Long id;
    private String username;
    private PlayerStatus status;        // WAITING, PLAYING, DONE, EXITED
    private Integer num_completed;      // number of questions completed
    private Timestamp time_joined;
    private Timestamp time_last_updated;

    public Player() {} // required

    public Player(Long id, String username, PlayerStatus status) {
        this.id = id;
        this.username = username;
        this.status = status;
        this.num_completed = 0;
        this.time_joined = Timestamp.now();
        this.time_last_updated = Timestamp.now();
    }

    @Override public String toString(){ return "Player{id=" + id + ", user=" + username + ", status=" + status + "}"; }
    @Override public boolean equals(Object o){ return o instanceof Player p && Objects.equals(id, p.id); }
    @Override public int hashCode(){ return Objects.hash(id); }
}
