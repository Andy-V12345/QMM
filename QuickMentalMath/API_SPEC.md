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
  state: "WAITING" | "READY" | "ACTIVE" | "FINISHED" | "CANCELLED";
  result?: GameResult;              // Only present when state = FINISHED
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
