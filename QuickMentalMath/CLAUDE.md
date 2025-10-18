# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

QuickMentalMath (QMM) is an iOS application built with SwiftUI for practicing mental math. Users can practice addition, subtraction, multiplication, and division across different difficulty levels (Easy, Medium, Hard, Decimals) with timed or untimed modes. The app includes user authentication, stats tracking, leaderboard functionality, and is adding multiplayer capabilities.

## Technology Stack

- **Framework**: SwiftUI (iOS)
- **Platform**: iOS (iPhone and iPad support)
- **Backend API**: REST API at `https://qmm.andy-vu.com/api/v1`
- **Authentication**: JWT-based authentication with Spring Boot backend
- **Future**: Firebase Firestore for real-time multiplayer game sessions (see API_SPEC.md)

## Build & Run Commands

### Xcode
Build and run the app using Xcode:
1. Open `QuickMentalMath.xcodeproj` in Xcode
2. Select target device/simulator
3. Press Cmd+R to build and run

The app has no external dependencies or package managers (no CocoaPods, SPM, or Carthage).

## Architecture

### Navigation System

The app uses SwiftUI's `NavigationStack` with a centralized navigation model. Navigation is type-safe and managed through `AppModel.path: NavigationPath`.

**Flow** (ContentView.swift:25-70):
1. Root screen shows ChatGPT quote
2. Navigation destinations registered for: `AuthState`, `GameModel`, `EndGameModel`, `GameConfigsModel`
3. Navigation happens via `appModel.path.append(destination)`

**Key Navigation Paths**:
- Initial load → AuthView (if unauthorized) → HomeView (if authorized)
- Home → GameConfigsModel → TimeTrialView or ExtraOptionsView (difficulty selection)
- ExtraOptionsView → GameModel → GameView (active game)
- GameView → EndGameModel → EndGameView (results)

### Environment Objects Pattern

The app uses three main `@EnvironmentObject` models injected at the root:

1. **AuthInfoModel** (Classes/AuthInfoModel.swift): Manages authentication state and user data
   - `user: User?` - Current user (id, username, jwtToken, stats)
   - `authState: AuthState` - UNAUTHORIZED, NO_ACCOUNT, or AUTHORIZED
   - Provides methods for: signUp, login, loadUserStats, updateUserStats, getLeaderboard, resetPassword, deleteAccount
   - All methods are `@MainActor` async functions

2. **AppModel** (Classes/AppModel.swift): Manages navigation
   - `path: NavigationPath` - Single source of truth for navigation stack
   - Simple wrapper around NavigationPath for centralized navigation management

3. **DeviceModel** (Classes/DeviceModel.swift): Device-responsive UI system
   - Categorizes devices: SMALL_PHONE (≤375pt), NORMAL_PHONE, IPAD (>500pt)
   - `valueByDevice<T>(small:normal:ipad:)` - Returns appropriate value based on device type
   - Used throughout UI for responsive sizing: fonts, spacing, dimensions

### Game Flow

**1. Game Configuration** (Structs/GameConfigsModel.swift):
- `GameMode`: ADDITION, SUBTRACTION, MULTIPLICATION, DIVISION, TIME (mixed operations)
- `GameDifficulty`: EASY, MEDIUM, HARD, DECIMALS
- `TimeLimit`: ONE_MIN (60s), TWO_MIN (120s), THREE_MIN (180s), NO_LIMIT (1000s)
- `numQuestions`: Number of questions in the game

**2. Active Game** (Views/GameView.swift):
- Timer-based countdown (if time limit set)
- Custom keypad for number input (Components/KeyPadButton.swift)
- Tracks: numCorrect, numIncorrect, missedQuestions
- On completion or timeout: navigates to EndGameModel → EndGameView

**3. Game Models**:
- `GameModel` (Structs/GameModel.swift): In-game state (score, question count, missed questions)
- `EndGameModel` (Structs/EndGameModel.swift): Wraps GameModel for end-game screen

### Backend Integration

**AuthService** (Services/AuthService.swift) handles all API communication:

**Base URL**: `https://qmm.andy-vu.com/api/v1`

**Endpoints**:
- `POST /auth/register` - Create account (returns JWT)
- `POST /auth/login` - Login (returns JWT)
- `POST /auth/forgot_password` - Send password reset email
- `GET /auth/reset_password?token=` - Verify reset token
- `POST /auth/reset_password` - Reset password with token
- `GET /stats/{userId}` - Load user statistics
- `POST /stats/{userId}` - Create user statistics
- `PUT /stats/{userId}/{statId}` - Update user statistics
- `GET /leaderboard/{topN}` - Get leaderboard
- `DELETE /deleteAccount/{userId}` - Delete user account
- `DELETE /stats/{userId}/{statId}` - Delete user statistics

**Authentication Flow**:
1. User signs up/logs in via AuthView
2. AuthService returns User object with JWT token
3. Token stored in `@AppStorage("jwtToken")` for persistence
4. All protected endpoints include `Authorization: Bearer {token}` header
5. User data persisted across app launches via @AppStorage

**User Stats** (UserStats struct in Services/AuthService.swift):
- Per-operation scores and totals: additionScore, additionTot, etc.
- High scores: highScore (regular), ttHighScore (time trial)
- Stats linked 1-to-1 with user account in PostgreSQL backend

### Multiplayer System (In Development)

The multiplayer system is being added on the `multiplayer-backend` branch. See API_SPEC.md for the complete specification.

**Architecture**:
- Backend: Firestore for real-time game sessions
- Matchmaking: Queue-based system with 20s timeout → bot games
- Game Flow: 25 questions, server-authoritative answer validation, real-time progress updates

**Key Firestore Paths**:
- `/users/{uid}/matchStatus/current` - Match notifications
- `/games/{gameId}` - Game session document
- `/games/{gameId}/progress/{uid}` - Player progress tracking

**Integration Points** (future):
1. New "Multiplayer" button in HomeView
2. MatchmakingView - Calls `POST /api/v1/match/join`, listens to Firestore
3. MultiplayerGameView - Similar to GameView but submits answers to `/api/v1/games/{gameId}/submit`
4. Real-time opponent progress via Firestore listeners

## Key Implementation Details

### State Persistence
App uses `@AppStorage` for persistence across launches:
- `authState: AuthState` - Current auth state
- `jwtToken: String` - JWT for API authentication
- `username: String` - Display name
- `id: Int` - User ID

On app activation (ContentView.swift:72-96), state is restored and user stats are loaded.

### Timer Management
GameView uses `Timer.publish(every: 1, on: .main, in: .common).autoconnect()` for countdown. Timer is cancelled when:
- Time reaches zero
- User completes all questions
- User navigates away (cleanup required to prevent memory leaks)

### Question Generation
Currently handled client-side in KeyPadButton component. Questions are generated on-the-fly based on difficulty:
- EASY: Smaller number ranges
- MEDIUM: Moderate ranges
- HARD: Larger ranges
- DECIMALS: Floating point with 2 decimal places

Division ensures clean integer division (except DECIMALS mode).

### Navigation Cleanup
When using back navigation, use `appModel.path.removeLast()` to pop one level. For multi-level navigation (e.g., quit from GameView), use multiple `removeLast()` calls or reconstruct the path.

### Custom UI Components
- **KeyPadButton** (Components/KeyPadButton.swift): Handles number input, answer validation, and question progression
- **RaisedButton** (Extensions/ViewExtensions.swift): Custom button style with shadow and haptic feedback
- **RoundedCorner** (Extensions/ViewExtensions.swift): Selective corner rounding

## Backend Service

The backend is a separate Spring Boot application in the `../userservices` directory. See `../userservices/CLAUDE.md` for backend documentation including:
- PostgreSQL user/stats persistence
- JWT authentication implementation
- Firestore multiplayer game system
- Build and deployment instructions
