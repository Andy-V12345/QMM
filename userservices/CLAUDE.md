# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the backend service for QuickMentalMath (QMM), a Spring Boot application that provides user management, authentication, and multiplayer game functionality for a mental math practice application. The service uses PostgreSQL for user data persistence and Firebase Firestore for real-time multiplayer game sessions.

## Technology Stack

- **Framework**: Spring Boot 3.3.1 with Java 17
- **Build Tool**: Maven
- **Database**: PostgreSQL (Neon hosted at ep-calm-king-a5u9r3lk.us-east-2.aws.neon.tech)
- **Real-time Storage**: Firebase Firestore for multiplayer game sessions
- **Authentication**: JWT-based authentication with Spring Security
- **Email**: Spring Mail (Gmail SMTP)

## Build & Run Commands

### Development
```bash
# Run the application locally
./mvnw spring-boot:run

# Build the application
./mvnw clean install

# Run tests
./mvnw test

# Package as JAR
./mvnw clean package
```

### Docker
```bash
# Build Docker image
docker build -t qmm-backend .

# Run container
docker run -p 8080:8080 qmm-backend
```

The application runs on port 8080 by default.

## Environment Setup

The application requires a `.env` file in the root directory with:
```
GOOGLE_APPLICATION_CREDENTIALS=/path/to/firebase-adminsdk.json
```

This is loaded at startup via `UserservicesApplication.main()` using the dotenv-java library.

## Architecture

### Package Structure

- **auth**: Authentication DTOs and UserDetailsService implementation
- **configuration**: Spring configuration classes (Security, Application, Firebase)
- **controller**: REST API endpoints
- **domain**: JPA entities (AppUser, UserStats, Role)
- **firestore**: Firestore data models (GameSession, Player, Question, etc.)
- **jwt**: JWT token generation and validation filter
- **repository**: Spring Data JPA repositories
- **service**: Business logic layer

### Core Systems

#### 1. Authentication & Security
- JWT-based authentication using `JwtService` and `JwtAuthenticationFilter`
- Security configuration in `SecurityConfiguration.java:26-38` defines that `/api/v1/auth/**` endpoints are public, all others require authentication
- Uses Spring Security with stateless session management
- User credentials stored in PostgreSQL with BCrypt password hashing
- Password reset functionality via email tokens

#### 2. Database Layer (PostgreSQL)
- **AppUser**: User account information (id, acctName, email, password, role, resetPasswordToken)
- **UserStats**: Performance statistics linked 1-to-1 with AppUser (scores per operation type, high scores)
- JPA repositories: `AppUserRepository`, `UserStatsRepository`
- Hibernate auto-generates schema updates (`ddl-auto: update`)

#### 3. Multiplayer Game System (Firestore)
The multiplayer system uses Firestore for real-time game coordination:

**Collections**:
- `games`: Stores GameSession documents
- `matchmaking/2_players`: Single document with field `open_game_session` for matchmaking queue

**GameSession Model** (firestore/GameSession.java):
- Contains 20 randomly generated questions
- Tracks players (HashMap keyed by user_id)
- Status flow: WAITING → IN_PROGRESS → DONE
- Rankings list filled as players complete

**Matchmaking Flow** (`FirestoreService.findGame()` at service/FirestoreService.java:27-89):
1. Transaction reads `matchmaking/2_players` document
2. If `open_game_session` is null: creates new game, updates waitlist with new game ID
3. If `open_game_session` exists: adds player to that game, clears waitlist (game is full)
4. Returns game session ID to client

**Game Lifecycle**:
- `findGame()`: Player enters matchmaking, gets assigned to a game session
- `joinGame()`: Player confirms they've joined, increments `players_connected`, sets status to IN_PROGRESS when both players join
- `updatePlayer()`: Updates player status (WAITING → JOINED → DONE or EXITED), manages rankings and game completion

All Firestore operations use transactions to ensure consistency.

#### 4. API Endpoints

**Public** (no auth required):
- `POST /api/v1/auth/register`: Create account
- `POST /api/v1/auth/login`: Get JWT token
- `POST /api/v1/auth/forgot-password`: Request password reset
- `POST /api/v1/auth/reset-password`: Reset password with token

**Protected** (JWT required):
- `GET /api/v1/stats/leaderboard`: Global leaderboard
- `PUT /api/v1/stats`: Update user statistics
- `POST /api/v1/games`: Find/create multiplayer game (matchmaking)
- `PUT /api/v1/games`: Join existing game session
- `PUT /api/v1/games/players`: Update player status during game

## Key Implementation Details

### Firebase Initialization
Firebase is initialized as a Spring bean in `FirebaseConfiguration.java:17-29`. The credentials path is read from the system property `GOOGLE_APPLICATION_CREDENTIALS` (loaded from .env).

### JWT Authentication Flow
1. `JwtAuthenticationFilter` intercepts requests
2. Extracts JWT from Authorization header
3. Validates token via `JwtService`
4. Loads user details and sets authentication in SecurityContext
5. Proceeds to controller if valid

### Transaction Safety
All Firestore game operations (`findGame`, `joinGame`, `updatePlayer`) use `db.runTransaction()` to ensure atomic reads and writes, preventing race conditions in matchmaking and game state updates.

### Question Generation
Questions are generated when a GameSession is created (GameSession.java:57-93). Random operations (ADD, SUBTRACT, MULTIPLY, DIVIDE) with difficulty-appropriate number ranges. Division ensures clean integer division by multiplying two factors first.

## Important Notes

- The `application.yml` contains sensitive credentials and is gitignored in production
- The JWT secret key should be configured via environment variables in production
- Firestore transactions have retry logic built into the Firebase SDK
- Player user_ids are stored as Long in Java but as String keys in Firestore HashMaps
- The application uses Lombok annotations extensively (@Getter, @Setter, @Builder, etc.)
