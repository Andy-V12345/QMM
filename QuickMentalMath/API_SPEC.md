# QuickMentalMath Backend API Specification

OpenAPI 3.0 specification for the QuickMentalMath multiplayer backend.

**Base URL:** `https://qmm.andy-vu.com`

---

## OpenAPI Schema

```yaml
openapi: 3.0.0
info:
  title: QuickMentalMath API
  description: Backend API for QuickMentalMath multiplayer math game
  version: 1.0.0
servers:
  - url: https://qmm.andy-vu.com
    
paths:
  /api/v1/match/join:
    post:
      summary: Join matchmaking queue
      description: |
        Joins the matchmaking queue. Either enqueues the player (returns WAITING) or
        matches with a waiting player (returns MATCHED).

        Client should listen to `/users/{uid}/matchStatus/current` Firestore document
        for match notifications.
      tags:
        - Matchmaking
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - userId
                - username
              properties:
                userId:
                  type: integer
                  format: int64
                  example: 123
                username:
                  type: string
                  example: "PlayerOne"
      responses:
        '200':
          description: Successfully joined queue or matched
          content:
            application/json:
              schema:
                oneOf:
                  - $ref: '#/components/schemas/JoinMatchResponseWaiting'
                  - $ref: '#/components/schemas/JoinMatchResponseMatched'
        '500':
          description: Internal server error
          content:
            application/json:
              schema:
                type: string

  /api/v1/match/leave:
    post:
      summary: Leave matchmaking queue
      description: Removes player from matchmaking queue and clears their match status
      tags:
        - Matchmaking
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - userId
              properties:
                userId:
                  type: integer
                  format: int64
                  example: 123
      responses:
        '200':
          description: Successfully left queue
          content:
            application/json:
              schema:
                type: object
                properties:
                  success:
                    type: boolean
                    example: true
        '500':
          description: Internal server error

  /api/v1/match/playBot:
    post:
      summary: Create game with bot opponent
      description: |
        Creates a game with a bot opponent. Used when matchmaking times out after 20 seconds.
        Client should simulate bot behavior by submitting answers at random intervals.
      tags:
        - Matchmaking
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - userId
                - username
              properties:
                userId:
                  type: integer
                  format: int64
                  example: 123
                username:
                  type: string
                  example: "PlayerOne"
      responses:
        '200':
          description: Bot game created successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/JoinMatchResponseMatched'
        '500':
          description: Internal server error

  /api/v1/lobbies/create:
    post:
      summary: Create private lobby
      description: |
        Creates a private lobby with a unique 6-character invite code.
        Returns lobby details including the code to share with friends.
      tags:
        - Private Lobbies
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - userId
                - username
              properties:
                userId:
                  type: integer
                  format: int64
                  example: 123
                username:
                  type: string
                  example: "PlayerOne"
      responses:
        '200':
          description: Lobby created successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/LobbyResponse'
        '500':
          description: Internal server error

  /api/v1/lobbies/{code}/join:
    post:
      summary: Join private lobby by code
      description: |
        Join a private lobby using the 6-character invite code.
        Client should then listen to `/lobbies/{lobbyId}` for real-time updates.
      tags:
        - Private Lobbies
      parameters:
        - name: code
          in: path
          required: true
          schema:
            type: string
          example: "A3X7K9"
          description: 6-character invite code (case-insensitive)
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - userId
                - username
              properties:
                userId:
                  type: integer
                  format: int64
                  example: 456
                username:
                  type: string
                  example: "PlayerTwo"
      responses:
        '200':
          description: Successfully joined lobby
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/LobbyResponse'
        '404':
          description: Lobby not found or already started
        '409':
          description: Lobby is full
        '400':
          description: Already in this lobby
        '500':
          description: Internal server error

  /api/v1/lobbies/{lobbyId}/start:
    post:
      summary: Start the game (host only)
      description: |
        Host starts the game once minimum players have joined.
        Creates a GameSession and transitions lobby to STARTED state.
      tags:
        - Private Lobbies
      parameters:
        - name: lobbyId
          in: path
          required: true
          schema:
            type: string
          example: "lobby123"
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - hostUid
              properties:
                hostUid:
                  type: string
                  example: "123"
                  description: Must match the lobby host's UID
      responses:
        '200':
          description: Game started successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/StartGameResponse'
        '404':
          description: Lobby not found
        '403':
          description: Only the host can start the game
        '400':
          description: Lobby is not ready to start (not enough players)
        '500':
          description: Internal server error

  /api/v1/lobbies/{lobbyId}/leave:
    delete:
      summary: Leave lobby
      description: |
        Leave the lobby. Player is removed from the lobby.
        - If the leaving player is the host, the lobby is cancelled (state = CANCELLED)
        - If all players leave, the lobby is cancelled
        - If players count falls below minimum after leaving, state changes back to WAITING
        - Can only be called before the game starts (lobby state must be WAITING or READY)
      tags:
        - Private Lobbies
      parameters:
        - name: lobbyId
          in: path
          required: true
          schema:
            type: string
          example: "lobby123"
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - userId
              properties:
                userId:
                  type: integer
                  format: int64
                  example: 123
      responses:
        '200':
          description: Successfully left lobby
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/LobbyResponse'
        '400':
          description: Cannot leave lobby after game has started
        '404':
          description: Lobby not found or user not in lobby
        '500':
          description: Internal server error

  /api/v1/lobbies/{lobbyId}:
    delete:
      summary: Cancel lobby
      description: |
        Cancel the lobby. Any player in the lobby can cancel it.
        Sets lobby state to CANCELLED.
      tags:
        - Private Lobbies
      parameters:
        - name: lobbyId
          in: path
          required: true
          schema:
            type: string
          example: "lobby123"
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - userId
              properties:
                userId:
                  type: integer
                  format: int64
                  example: 123
      responses:
        '200':
          description: Lobby cancelled successfully
        '404':
          description: Lobby not found
        '403':
          description: Not authorized to cancel this lobby
        '500':
          description: Internal server error

  /api/v1/games/{gameId}/submit:
    post:
      summary: Submit an answer
      description: |
        Submit an answer with server-authoritative validation.
        - qIndex must equal the player's current progress.completed value
        - Answer is validated against the question set
        - Returns updated completion count
        - Automatically determines winner when player finishes
      tags:
        - Game
      parameters:
        - name: gameId
          in: path
          required: true
          schema:
            type: string
          example: "abc123xyz"
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - userId
                - qIndex
                - answer
              properties:
                userId:
                  type: string
                  example: "123"
                  description: User ID as string
                qIndex:
                  type: integer
                  example: 5
                  description: Question index (0-24), must equal current progress.completed
                answer:
                  type: integer
                  example: 42
                  description: Player's answer
                clientSentAt:
                  type: integer
                  format: int64
                  example: 1234567890000
                  description: Optional client timestamp in milliseconds
      responses:
        '200':
          description: Answer processed successfully
          content:
            application/json:
              schema:
                type: object
                properties:
                  completed:
                    type: integer
                    example: 6
                    description: Updated completion count (0-25)
                  state:
                    type: string
                    enum: [WAITING, READY, ACTIVE, FINISHED, CANCELLED]
                    example: "ACTIVE"
                    description: Only included if game state changed
                  result:
                    $ref: '#/components/schemas/GameResult'
                    description: Only included when game finishes
        '404':
          description: Game not found
        '403':
          description: Not a player in this game
        '409':
          description: Out of order submission or incorrect answer
        '500':
          description: Internal server error

  /api/v1/games/{gameId}/presence:
    post:
      summary: Update player presence
      description: Updates player online/offline status
      tags:
        - Game
      parameters:
        - name: gameId
          in: path
          required: true
          schema:
            type: string
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - userId
                - connection
              properties:
                userId:
                  type: integer
                  format: int64
                  example: 123
                connection:
                  type: string
                  enum: [ONLINE, OFFLINE]
                  example: "ONLINE"
      responses:
        '200':
          description: Presence updated
          content:
            application/json:
              schema:
                type: object
                properties:
                  success:
                    type: boolean
                    example: true
        '500':
          description: Internal server error

  /api/v1/games/{gameId}/forfeit:
    post:
      summary: Forfeit the game
      description: |
        Mark player as forfeited. Opponent can continue playing normally and will
        be declared winner when they finish all 25 questions.
      tags:
        - Game
      parameters:
        - name: gameId
          in: path
          required: true
          schema:
            type: string
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - userId
              properties:
                userId:
                  type: integer
                  format: int64
                  example: 123
      responses:
        '200':
          description: Successfully forfeited
          content:
            application/json:
              schema:
                type: object
                properties:
                  success:
                    type: boolean
                    example: true
        '404':
          description: Game not found
        '403':
          description: Not a player in this game
        '500':
          description: Internal server error

  /api/v1/games/{gameId}/playAgainReady:
    post:
      summary: Set play again ready status
      description: |-
        Set player's ready status for playing again (custom lobby games only).
        When all players mark ready, a new game is automatically created with:
        - New game ID (returned in response)
        - New question set
        - Reset player progress (all back to 0 completed)
        - Lobby's gameId updated to new game

        The original game remains in Firestore for history/analytics.
        Uses Firestore transaction to prevent race conditions when multiple players click simultaneously.
      tags:
        - Game
      parameters:
        - name: gameId
          in: path
          required: true
          schema:
            type: string
          example: "abc123xyz"
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - userId
                - ready
              properties:
                userId:
                  type: integer
                  format: int64
                  example: 123
                ready:
                  type: boolean
                  example: true
                  description: true = wants to play again, false = doesn't want to
      responses:
        '200':
          description: Ready status updated successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/SetPlayAgainReadyResponse'
        '404':
          description: Game not found
        '403':
          description: Not a player in this game
        '400':
          description: Play again is only available for custom lobby games
        '500':
          description: Internal server error

components:
  schemas:
    JoinMatchResponseWaiting:
      type: object
      properties:
        status:
          type: string
          enum: [WAITING]
          example: "WAITING"
        variant:
          type: string
          example: "DEFAULT"
        queuePosition:
          type: integer
          example: 1

    JoinMatchResponseMatched:
      type: object
      properties:
        status:
          type: string
          enum: [MATCHED]
          example: "MATCHED"
        gameId:
          type: string
          example: "abc123xyz"
        startAt:
          type: object
          properties:
            seconds:
              type: integer
              format: int64
              example: 1234567890
            nanos:
              type: integer
              example: 0

    GameResult:
      type: object
      properties:
        winnerUid:
          type: string
          example: "123"
        p1TimeMs:
          type: integer
          format: int64
          example: 45000
          description: Player 1 elapsed time in milliseconds
        p2TimeMs:
          type: integer
          format: int64
          example: 50000
          description: Player 2 elapsed time in milliseconds
        finishedAt:
          type: object
          properties:
            seconds:
              type: integer
              format: int64
            nanos:
              type: integer
        decidedBy:
          type: string
          enum: [FIRST_TO_FINISH, BOTH_FINISHED, GRACE_TIMEOUT, FORFEIT]
          example: "FIRST_TO_FINISH"

    LobbyResponse:
      type: object
      properties:
        lobbyId:
          type: string
          example: "lobby123"
        code:
          type: string
          example: "A3X7K9"
          description: 6-character invite code
        players:
          type: array
          items:
            type: object
            properties:
              uid:
                type: string
                example: "123"
              username:
                type: string
                example: "PlayerOne"
              joinedAt:
                type: object
                properties:
                  seconds:
                    type: integer
                    format: int64
                  nanos:
                    type: integer
        hostUid:
          type: string
          example: "123"
          description: UID of the player who created the lobby
        minPlayers:
          type: integer
          example: 2
          description: Minimum players required to start
        maxPlayers:
          type: integer
          example: 2
          description: Maximum players allowed
        state:
          type: string
          enum: [WAITING, READY, STARTED, CANCELLED]
          example: "WAITING"
          description: WAITING = < minPlayers, READY = >= minPlayers, STARTED = game created, CANCELLED = lobby closed
        gameId:
          type: string
          nullable: true
          example: null
          description: Set when game is started
        createdAt:
          type: object
          properties:
            seconds:
              type: integer
              format: int64
            nanos:
              type: integer

    StartGameResponse:
      type: object
      properties:
        gameId:
          type: string
          example: "abc123xyz"
        startAt:
          type: object
          properties:
            seconds:
              type: integer
              format: int64
              example: 1234567890
            nanos:
              type: integer
              example: 0

    SetPlayAgainReadyResponse:
      type: object
      properties:
        gameId:
          type: string
          example: "abc123xyz"
          description: The original game ID
        playAgainReady:
          type: object
          nullable: true
          additionalProperties:
            type: boolean
          example: {"123": true, "456": false}
          description: Map of player uid -> ready status. Null if new game was created (all players ready).
        gameReset:
          type: boolean
          example: false
          description: true if all players were ready and new game was automatically created, false otherwise
        newGameId:
          type: string
          nullable: true
          example: "xyz789abc"
          description: The new game ID when all players are ready. Null if not all players ready yet.
```

---

## Firestore Real-time Data Models

The client should listen to these Firestore documents for real-time updates:

### 1. User Match Status
**Path:** `/users/{uid}/matchStatus/current`

**Purpose:** Notifies player when a match is found

**Schema:**
```typescript
interface UserMatchStatus {
  matched: boolean;        // false = waiting, true = matched
  gameId: string | null;   // null when waiting, game ID when matched
  timestamp: Timestamp;
}
```

**Client Flow:**
1. Call `POST /api/v1/match/join`
2. Start listening to `/users/{uid}/matchStatus/current`
3. When `matched: false` → Show "Searching for opponent..."
4. When `matched: true` → Navigate to game with `gameId`

---

### 2. Game Session
**Path:** `/games/{gameId}`

**Purpose:** Contains game configuration, questions, and overall state

**Schema:**
```typescript
interface GameSession {
  id: string;
  mode: "MIXED";
  difficulty: "MEDIUM";
  targetCount: number;              // Always 25
  players: GamePlayer[];            // Array of 2 players
  questionSet: QuestionSet;
  startAt: Timestamp;               // When game starts (countdown + 3s)
  createdAt: Timestamp;
  schemaVersion: number;
  lobbyId?: string;                 // Lobby ID if created from custom lobby (null for matchmaking)
  state: "WAITING" | "READY" | "ACTIVE" | "FINISHED" | "CANCELLED";
  result?: GameResult;              // Only present when state = FINISHED
  playAgainReady?: { [uid: string]: boolean };  // Player ready status for play again (custom lobbies only)
  postgame: GamePostgame;
}

interface GamePlayer {
  uid: string;
  displayName: string;
}

interface QuestionSet {
  mode: "MIXED";
  difficulty: "MEDIUM";
  targetCount: number;              // 25
  questions: QuestionItem[];
  hash: string | null;
  schemaVersion: number;
}

interface QuestionItem {
  a: number;
  b: number;
  op: "+" | "-" | "×" | "÷";
  correct: number;
}

interface GameResult {
  winnerUid: string;
  p1TimeMs?: number;
  p2TimeMs?: number;
  finishedAt: Timestamp;
  decidedBy: "FIRST_TO_FINISH" | "BOTH_FINISHED" | "GRACE_TIMEOUT" | "FORFEIT";
}

interface GamePostgame {
  acceptingSubmissions: boolean;    // true = loser can continue
  lockedAt: Timestamp | null;       // null = no time limit
}
```

---

### 3. Player Progress
**Path:** `/games/{gameId}/progress/{uid}`

**Purpose:** Tracks individual player progress in the game

**Schema:**
```typescript
interface PlayerProgress {
  completed: number;                // 0-25 questions completed
  status: "PLAYING" | "FINISHED" | "FORFEIT" | "POSTGAME";
  lastAnswerAt: Timestamp | null;
  finishedAt: Timestamp | null;     // When player finished all 25
  elapsedMs: number | null;         // Total time in milliseconds
}
```

**Client Listeners:**
- Listen to own progress: `/games/{gameId}/progress/{myUid}`
- Listen to opponent progress: `/games/{gameId}/progress/{opponentUid}`

---

### 4. Lobby (Private Matches)
**Path:** `/lobbies/{lobbyId}`

**Purpose:** Manages private lobby state for invite-based matches

**Schema:**
```typescript
interface Lobby {
  id: string;
  code: string;                     // 6-character invite code (e.g., "A3X7K9")
  players: LobbyPlayer[];           // List of players in lobby
  hostUid: string;                  // Host's UID (can start game)
  minPlayers: number;               // Minimum to start (default: 2)
  maxPlayers: number;               // Maximum allowed (default: 2)
  state: "WAITING" | "READY" | "STARTED" | "CANCELLED";
  gameId: string | null;            // Set when game starts
  createdAt: Timestamp;
}

interface LobbyPlayer {
  uid: string;
  username: string;
  joinedAt: Timestamp;
}
```

**State Transitions:**
- WAITING: `players.length < minPlayers`
- READY: `players.length >= minPlayers` (host can start)
- STARTED: Game has been created
- CANCELLED: Lobby was cancelled

**Client Listeners:**
- Host and all players listen to `/lobbies/{lobbyId}` for real-time lobby updates
- When state → STARTED: navigate to game with `gameId`

---

## Typical Game Flow

### 1. Matchmaking
```
1. Client calls POST /api/v1/match/join
2. Client listens to /users/{uid}/matchStatus/current
3. If matched: false → Show "Searching..."
4. If matched: true → Navigate to /games/{gameId}
```

### 2. Game Start
```
1. Client navigates to game screen with gameId
2. Client listens to:
   - /games/{gameId} (game state)
   - /games/{gameId}/progress/{myUid} (my progress)
   - /games/{gameId}/progress/{opponentUid} (opponent progress)
3. Wait for game.startAt timestamp
4. Begin showing questions
```

### 3. Answering Questions
```
1. Player selects answer
2. Client calls POST /api/v1/games/{gameId}/submit
   - userId: player's UID
   - qIndex: current question index (must equal progress.completed)
   - answer: player's answer
3. Server validates and updates progress
4. Firestore listeners fire with updated progress
5. Client shows next question
```

### 4. Game End
```
1. When a player finishes question 25:
   - Server updates game.state to FINISHED
   - Server sets game.result with winnerUid
2. Firestore listeners fire
3. Client shows postgame screen
4. Loser can optionally continue (postgame submissions)
```

### 5. Bot Games
```
1. After 20s matchmaking timeout, client calls POST /api/v1/match/playBot
2. Server creates game with bot player (uid: "bot_{UUID}")
3. Client submits answers for bot at random intervals (e.g., every 2-5 seconds)
4. Server validates all submissions normally
```

### 6. Private Lobby (Invite-Based Matches)
```
HOST FLOW:
1. Client calls POST /api/v1/lobbies/create
2. Server returns lobby with 6-digit code (e.g., "A3X7K9")
3. Client shows code to share with friend
4. Client listens to /lobbies/{lobbyId}
5. When player joins → lobby.state changes to READY
6. Host clicks "Start Game" → POST /api/v1/lobbies/{lobbyId}/start
7. Server creates game, returns gameId
8. Firestore listener fires with state: STARTED, gameId
9. Navigate to game screen

GUEST FLOW:
1. Friend enters 6-digit code in app
2. Client calls POST /api/v1/lobbies/{code}/join
3. Server adds player to lobby, returns lobby details
4. Client listens to /lobbies/{lobbyId}
5. When host starts → lobby.state changes to STARTED
6. Firestore listener fires with gameId
7. Navigate to game screen

GAME PLAY:
- Once game starts, follows same flow as matchmaking (see section 2-4)
- Both players answer questions via POST /api/v1/games/{gameId}/submit
- Progress tracked in /games/{gameId}/progress/{uid}
```

### 7. Play Again (Custom Lobbies Only)
```
After a custom lobby game ends, players can play again with the same opponent:

END GAME SCREEN:
1. Client shows end game results with "Play Again" button
2. Client listens to:
   - /games/{gameId} for real-time playAgainReady updates
   - /lobbies/{lobbyId} for new game creation
3. UI displays real-time ready status for all players

PLAYER CLICKS "PLAY AGAIN":
1. Client calls POST /api/v1/games/{gameId}/playAgainReady with ready=true
2. Server updates playAgainReady map in Firestore (transaction-protected)
3. Server checks if all players are ready
4. If not all ready:
   - Returns updated playAgainReady map
   - Client shows "waiting for others..." state
   - Other players see checkmark next to ready player
5. If all players ready:
   - Server automatically creates new game:
     * Creates new game document with new ID
     * Copies players from old game
     * Generates new question set
     * Resets all player progress to 0
     * Updates lobby's gameId to new game ID
   - Returns gameReset=true and newGameId

CLIENT DETECTS NEW GAME:
1. Firestore listener on /lobbies/{lobbyId} fires: lobby.gameId changed
2. Client detects gameId change as new game signal
3. Both clients fetch new game session document
4. Navigate to game view with new gameId
5. Game starts with new questions, fresh progress

PLAYER LEAVES TO HOME:
1. Client calls POST /api/v1/games/{gameId}/playAgainReady with ready=false
2. Other players see player is no longer ready
3. New game not created until all players mark ready again

RACE CONDITION PREVENTION:
- Uses Firestore transaction for atomic read-modify-write
- If both players click simultaneously:
  * Transaction ensures both ready statuses are recorded
  * No lost updates, new game created exactly once
  * Automatic retry on conflicts with exponential backoff

GAME HISTORY PRESERVATION:
- Old game documents remain in Firestore
- Useful for analytics, replays, and debugging
- Each play-again creates a new game document
```

---

## Error Handling

### Common Error Responses

**404 Not Found**
```json
"Game not found"
```

**403 Forbidden**
```json
"Not a player in this game"
```

**409 Conflict - Out of Order**
```json
"Out of order submission. Expected qIndex=5"
```

**409 Conflict - Wrong Answer**
```json
"Incorrect answer"
```

**409 Conflict - Lobby Full**
```json
"Lobby is already full"
```

**400 Bad Request - Already in Lobby**
```json
"Already in this lobby"
```

**400 Bad Request - Not Ready**
```json
"Lobby is not ready to start"
```

**400 Bad Request - Not Custom Lobby**
```json
"Play again is only available for custom lobby games"
```

**500 Internal Server Error**
```json
"Failed to submit answer: <error details>"
```

---

## Notes

- All timestamps are Firestore `Timestamp` objects with `seconds` and `nanos` fields
- Bot UIDs follow pattern: `"bot_{UUID}"`
- Bot names are random combinations like "MathWhiz42", "SpeedNinja27"
- Question generation uses random operations with difficulty-appropriate ranges
- Server-authoritative validation prevents cheating
- Tie-breaking: first to finish wins; if both finish simultaneously, winner determined by elapsed time
- Lobby codes: 6-character alphanumeric (A-Z, 0-9), case-insensitive
- Lobby system supports 2+ players (currently configured for 1v1 with minPlayers=2, maxPlayers=2)
- Future extensibility: Can support 2v2, 3-player, 4-player by adjusting min/max player counts
- No lobby timeout: Lobbies persist until started or cancelled (no expiration)
