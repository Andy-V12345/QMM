//
//  MultiplayerGameView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/20/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct MultiplayerGameView: View {

    let numSize: CGFloat = 0.1
    let keyColumns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 0, alignment: .center), count: 3)
    let keyNums = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 0, 11]
    let topSize = 0.65

    @State var input: String = "f"
    @State var isGameOver = false
    @State var showAreYouSure = false
    @State var questionIndex = 0
    
    @State var infoText = "race to the finish"

    @State var opponentProgress: Int = 0
    @State var opponentStatus: String = "PLAYING"
    @State var opponentConnection: PlayerConnectionStatus = .CONNECTED
    @State var opponentProgressListener: ListenerRegistration?
    @State var botSubmissionTask: Task<Void, Never>?

    // Server reconciliation state
    @State var confirmedQuestionIndex: Int = 0
    @State var pendingSubmissions: Set<Int> = []
    @State var confirmedQuestions: Set<Int> = []
    @State var showConnectionWarning: Bool = true
    @State var isSubmittingAnswer: Bool = false

    // Countdown state
    @State var countdownValue: Int = 3
    @State var showCountdown: Bool = false

    // Leave game state
    @State var showLeaveGameOverlay: Bool = false
    @State var showLeaveGameError: Bool = false
    @State var leaveGameErrorMessage: String = ""

    @EnvironmentObject var device: DeviceModel
    @EnvironmentObject var authInfo: AuthInfoModel
    @EnvironmentObject var appModel: AppModel

    let numQuestions: Int
    let gameSession: GameSession
    
    init(gameSession: GameSession) {
        self.gameSession = gameSession
        self.numQuestions = gameSession.targetCount
    }

    var opponent: GamePlayer {
        gameSession.players.first(where: { $0.uid != String(authInfo.user?.id ?? 0) }) ?? gameSession.players[0]
    }

    var isOpponentBot: Bool {
        opponent.uid.starts(with: "bot")
    }

    var curQuestion: QuestionItem {
        self.gameSession.questionSet.questions[min(questionIndex, numQuestions - 1)]
    }
    
    private func checkAnswer() -> Bool {
        return curQuestion.correct == Int(input)
    }
    
    private func handleLeaveGame() {
        guard let user = authInfo.user else { return }

        // Show loading overlay
        showLeaveGameOverlay = true

        Task {
            let result = await MultiplayerService.forfeit(
                gameId: gameSession.id,
                userId: user.id,
                jwtToken: user.jwtToken
            )

            await MainActor.run {
                switch result {
                case .success:
                    // Navigate back
                    showLeaveGameOverlay = false
                    appModel.path.removeLast()

                case .failure(let error):
                    // Hide overlay and show error alert
                    showLeaveGameOverlay = false
                    leaveGameErrorMessage = error.localizedDescription
                    showLeaveGameError = true
                }
            }
        }
    }
    
    private func handleGameOver() {
        appModel.path.append(MultiplayerEndGameModel(gameId: gameSession.id, players: gameSession.players))
    }
    
    private func updateProgress() {
        input = "f"
        questionIndex += 1
    }

    private func submitUserAnswer(qIndex: Int, answer: Int) async {
        guard let user = authInfo.user else { return }

        let result = await MultiplayerService.submitAnswer(
            gameId: gameSession.id,
            userId: String(user.id),
            qIndex: qIndex,
            answer: answer,
            jwtToken: user.jwtToken
        )

        await MainActor.run {
            switch result {
            case .success:
                // Remove from pending and add to confirmed
                pendingSubmissions.remove(qIndex)
                confirmedQuestions.insert(qIndex)

                // Update confirmed index if this was the next sequential confirmation
                if qIndex == confirmedQuestionIndex {
                    confirmedQuestionIndex += 1

                    // Check if subsequent questions are also confirmed (out-of-order confirmations)
                    while confirmedQuestions.contains(confirmedQuestionIndex) {
                        confirmedQuestionIndex += 1
                    }

                    // Check if game is complete
                    if confirmedQuestionIndex >= numQuestions {
                        handleGameOver()
                    }
                }

                // Hide warning if no more pending submissions
                if pendingSubmissions.isEmpty {
                    showConnectionWarning = false
                }

                isSubmittingAnswer = false

            case .failure(let error):
                print("User answer submission failed: \(error.localizedDescription)")

                // Show connection warning
                showConnectionWarning = true

                // Rollback to confirmed state
                questionIndex = confirmedQuestionIndex
                input = "f"

                // Clear pending and confirmed submissions ahead of confirmed index
                pendingSubmissions = pendingSubmissions.filter { $0 < confirmedQuestionIndex }
                confirmedQuestions = confirmedQuestions.filter { $0 < confirmedQuestionIndex }

                isSubmittingAnswer = false
            }
        }
    }

    private func startOpponentProgressListener() {
        let db = Firestore.firestore()
        let docRef = db.collection("games").document(gameSession.id).collection("progress").document(opponent.uid)

        opponentProgressListener = docRef.addSnapshotListener { snapshot, error in
            // Check if document doesn't exist
            guard let snapshot = snapshot, snapshot.exists else {
                print("Opponent progress document doesn't exist")
                opponentConnection = .DISCONNECTED
                return
            }

            guard let data = snapshot.data(), error == nil else {
                print("Error listening to opponent progress: \(error?.localizedDescription ?? "unknown")")
                return
            }

            // Update opponent progress
            if let completed = data["completed"] as? Int {
                opponentProgress = completed
            }

            // Update opponent status
            if let status = data["status"] as? String {
                opponentStatus = status

                if status == "FORFEIT" {
                    opponentConnection = .DISCONNECTED
                }
            }
        }
    }

    private func startCountdown() {
        Task {
            for i in (1...3).reversed() {
                countdownValue = i
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            }

            // Show "GO!" briefly
            countdownValue = 0
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

            // Hide countdown
            await MainActor.run {
                showCountdown = false
                
                // Start listening to opponent's progress
                startOpponentProgressListener()

                // If playing against bot, start bot simulation
                if isOpponentBot {
                    startBotSimulation()
                }
            }
        }
    }

    private func startBotSimulation() {
        guard let user = authInfo.user else { return }

        botSubmissionTask = Task {
            var botQuestionIndex = 0

            while botQuestionIndex < numQuestions {
                // Check if task was cancelled
                if Task.isCancelled { return }

                // Random delay
                let randomDelay = Double.random(in: 1.5...2.5)
                try? await Task.sleep(nanoseconds: UInt64(randomDelay * 1_000_000_000))

                // Get the correct answer for this question
                let question = gameSession.questionSet.questions[botQuestionIndex]
                let correctAnswer = question.correct

                // Submit bot's answer
                let result = await MultiplayerService.submitAnswer(
                    gameId: gameSession.id,
                    userId: opponent.uid,
                    qIndex: botQuestionIndex,
                    answer: correctAnswer,
                    jwtToken: user.jwtToken
                )

                switch result {
                case .success:
                    botQuestionIndex += 1
                case .failure(let error):
                    print("Bot submission failed: \(error.localizedDescription)")
                    // Continue anyway
                    botQuestionIndex += 1
                }
            }
        }
    }

    // MARK: - Game Logic
    func handleKeypadClick(id: String) {
        // Block input during countdown
        guard !showCountdown else { return }

        if Int(id) == 10 {
            input.remove(at: input.index(before: input.endIndex))
            if input.count == 0 {
                input = "f"
            }
        }
        else {
            if input == "f" {
                input = id
            }
            else {
                if input.count < 4 {
                    input.append(id)
                }
            }

            if checkAnswer() {
                HapticManager.shared.trigger(.medium)
                
                // Prevent double submission
                guard !isSubmittingAnswer else { return }

                // Capture question index and answer before updating UI
                let capturedQIndex = questionIndex
                let capturedAnswer = curQuestion.correct

                // Set submitting flag
                isSubmittingAnswer = true

                // Add to pending submissions
                pendingSubmissions.insert(capturedQIndex)

                // Optimistically update UI
                updateProgress()

                // Submit to server in background
                Task {
                    await submitUserAnswer(qIndex: capturedQIndex, answer: capturedAnswer)
                }
            }
        }
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                VStack {
                    VStack(spacing: 20) {
                        // MARK: MENU BAR
                        HStack {
                            Button(action: {
                                showAreYouSure = true
                            }, label: {
                                Image(systemName: "chevron.left")
                                    .font(.headline)
                                    .bold()
                                    .foregroundColor(Color("darkPurple"))
                                    .dynamicTypeSize(.large)
                            })
                            
                            Spacer()
                            
                            if showConnectionWarning {
                                HStack(spacing: 8) {
                                    Image(systemName: "wifi.slash")
                                        .foregroundStyle(.white)
                                    
                                    Text("connection issues")
                                        .foregroundStyle(.white)
                                        .fontWeight(.semibold)
                                        .lineLimit(1)
                                }
                                .font(device.valueByDevice(small: .subheadline, normal: .subheadline, ipad: .title3))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .raisedButton(backgroundColor: Color("errorRed"), shadowColor: Color("darkErrorRed"), shadowOffset: 2, action: {})
                                .allowsHitTesting(false)
                                .transition(.move(edge: .top).combined(with: .opacity))
                                .animation(.easeInOut(duration: 0.3), value: showConnectionWarning)
                            }
                            else {
                                Text(infoText)
                                    .font(device.valueByDevice(small: .subheadline, normal: .subheadline, ipad: .title3))
                                    .foregroundStyle(Color("darkPurple"))
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .raisedButton(shadowOffset: 2, action: {})
                                    .allowsHitTesting(false)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                                    .animation(.easeInOut(duration: 0.3), value: showConnectionWarning)
                            }
                            
                            Spacer()
                            
                            
                            // Used to center the hstack
                            Button(action: {
                            }, label: {
                                Image(systemName: "chevron.left")
                                    .font(.headline)
                                    .bold()
                                    .foregroundColor(Color("darkPurple"))
                                    .dynamicTypeSize(.large)
                            })
                            .hidden()
                        } //: HStack
                        .padding(.horizontal, 20)
                        
                        
                        // MARK: PROGRESS BARS
                        VStack(spacing: device.valueByDevice(small: 8, normal: 12, ipad: 15)) {
                            RacingProgressBar(
                                playerName: opponent.displayName,
                                playerConnection: opponentConnection,
                                backgroundColor: Color("errorRed"),
                                shadowColor: Color("darkErrorRed"),
                                currentProgress: opponentProgress,
                                totalNodes: numQuestions,
                                nodeSize: device.valueByDevice(small: 32, normal: 38, ipad: 40)
                            )
                            .animation(.easeInOut(duration: 0.15), value: opponentProgress)
                            
                            RacingProgressBar(playerName: "you", playerConnection: .CONNECTED, backgroundColor: Color("pastelBlue"), shadowColor: Color("darkPastelBlue"), currentProgress: questionIndex, totalNodes: numQuestions, nodeSize: device.valueByDevice(small: 32, normal: 38, ipad: 40))
                                .animation(.easeInOut(duration: 0.15), value: questionIndex)
                        }
                        .padding(.horizontal, 20)
                    }
                        
                    Spacer()

                    // MARK: NUMBERS DISPLAY
                    VStack(spacing: 10) {
                        Text(String(Int(max(curQuestion.a, curQuestion.b))))
                            .font(.system(size: device.screen!.size.width * numSize, weight: .bold, design: .rounded))
                            .foregroundColor(Color("darkPurple"))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .tracking(device.valueByDevice(small: 5, normal: 8, ipad: 15))

                        HStack {
                            Text(curQuestion.op)
                                .font(.system(size: device.screen!.size.width * numSize, weight: .bold, design: .rounded))
                                .bold()
                                .foregroundColor(Color("darkPurple"))

                            Spacer()

                            Text(String(Int(min(curQuestion.a, curQuestion.b))))
                                .font(.system(size: device.screen!.size.width * numSize, weight: .bold, design: .rounded))
                                .bold()
                                .foregroundColor(Color("darkPurple"))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .tracking(device.valueByDevice(small: 5, normal: 8, ipad: 15))
                        }

                        Rectangle()
                            .fill(Color("darkPurple"))
                            .frame(maxWidth: .infinity, maxHeight: device.valueByDevice(small: 5, normal: 5, ipad: 7))
                            .cornerRadius(5)

                        Text(input)
                            .font(.system(size: device.screen!.size.width * numSize, weight: .bold, design: .rounded))
                            .bold()
                            .foregroundColor(Color("darkPurple"))
                            .opacity(input == "f" ? 0 : 1)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .tracking(device.valueByDevice(small: 5, normal: 8, ipad: 15))
                    }
                    .frame(maxWidth: device.screen!.size.width * 0.5)

                    Spacer()

                }
                .padding(.top, 10)
                .frame(maxHeight: device.screen!.size.height * topSize)

                // MARK: KEYPAD
                VStack(spacing: device.valueByDevice(small: 13, normal: 13, ipad: 20)) {
                    HStack {
                        ForEach(1...3, id: \.self) { index in
                            KeyPadButton(id: String(keyNums[index-1]), onClick: handleKeypadClick)
                        }
                    }
                    HStack {
                        ForEach(4...6, id: \.self) { index in
                            KeyPadButton(id: String(keyNums[index-1]), onClick: handleKeypadClick)
                        }
                    }
                    HStack {
                        ForEach(7...9, id: \.self) { index in
                            KeyPadButton(id: String(keyNums[index-1]), onClick: handleKeypadClick)
                        }
                    }
                    HStack {
                        KeyPadButton(id: "10", foregroundColor: .white, backgroundColor: Color("errorRed"), shadowColor: Color("darkErrorRed"), imageName: "delete.left", isDisabled: input == "f", onClick: handleKeypadClick)
                        
                        KeyPadButton(id: "0", onClick: handleKeypadClick)
                        
                        KeyPadButton(id: "11", foregroundColor: .white, backgroundColor: Color("correctGreen"), shadowColor: Color("darkGreen"), imageName: "checkmark", isDisabled: true, onClick: handleKeypadClick)
                    }
                }
                .frame(height: device.screen!.size.height * (1 - topSize))
                .padding(.horizontal, device.valueByDevice(small: 10, normal: 10, ipad: 20))

                Spacer()

            }
            .frame(maxHeight: .infinity)

            // Countdown Overlay
            if showCountdown {
                ZStack {
                    Color.white.ignoresSafeArea()

                    Text(countdownValue == 0 ? "GO" : "\(countdownValue)")
                        .font(.system(size: device.valueByDevice(small: 75, normal: 100, ipad: 150), weight: .black))
                        .foregroundStyle(Color("darkPurple"))
                        .scaleEffect(countdownValue == 0 ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: countdownValue)
                }
                .transition(.opacity)
            }

            // Leave Game Loading Overlay
            if showLeaveGameOverlay {
                ZStack {
                    Color.white.opacity(0.7)
                        .ignoresSafeArea()
                        .allowsHitTesting(true)

                    VStack(spacing: 20) {
                        LoadingSpinner(size: 25, color: Color("lightPurple"), width: 6)

                        Text("leaving game...")
                            .font(device.valueByDevice(small: .title3, normal: .title2, ipad: .title))
                            .fontWeight(.semibold)
                            .foregroundStyle(Color("darkPurple"))
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
        .animation(.easeOut(duration: 0.3), value: showCountdown)
        .onAppear {
            // Start countdown
            startCountdown()
        }
        .onDisappear {
            // Clean up listeners and tasks
            opponentProgressListener?.remove()
            botSubmissionTask?.cancel()
        }
        .alert("are you sure?", isPresented: $showAreYouSure, actions: {
            Button(role: .none, action: {
                handleLeaveGame()
            }, label: {
                Text("yes")
            })
            
            Button(role: .cancel, action: {}, label: {
                Text("cancel")
            })
        }, message: {
            Text("you won't be able to rejoin and you'll forfeit the game!")
        })
        .alert("failed to leave game", isPresented: $showLeaveGameError, actions: {
            Button("retry", action: {
                handleLeaveGame()
            })

            Button("cancel", role: .cancel, action: {
                showLeaveGameOverlay = false
            })
        }, message: {
            Text(leaveGameErrorMessage)
        })
    }
}

#Preview {
    let questions = [
        QuestionItem(a: 47, b: 23, op: "+", correct: 70),
        QuestionItem(a: 28, b: 15, op: "-", correct: 13),
        QuestionItem(a: 9, b: 7, op: "×", correct: 63),
        QuestionItem(a: 72, b: 8, op: "÷", correct: 9),
        QuestionItem(a: 35, b: 48, op: "+", correct: 83),
        QuestionItem(a: 11, b: 6, op: "×", correct: 66),
        QuestionItem(a: 25, b: 19, op: "-", correct: 6),
        QuestionItem(a: 42, b: 37, op: "+", correct: 79),
        QuestionItem(a: 84, b: 12, op: "÷", correct: 7),
        QuestionItem(a: 8, b: 9, op: "×", correct: 72),
        QuestionItem(a: 30, b: 14, op: "-", correct: 16),
        QuestionItem(a: 19, b: 26, op: "+", correct: 45),
        QuestionItem(a: 12, b: 11, op: "×", correct: 132),
        QuestionItem(a: 27, b: 12, op: "-", correct: 15),
        QuestionItem(a: 56, b: 7, op: "÷", correct: 8),
        QuestionItem(a: 44, b: 31, op: "+", correct: 75),
        QuestionItem(a: 7, b: 8, op: "×", correct: 56),
        QuestionItem(a: 22, b: 17, op: "-", correct: 5),
        QuestionItem(a: 96, b: 12, op: "÷", correct: 8),
        QuestionItem(a: 38, b: 29, op: "+", correct: 67),
        QuestionItem(a: 10, b: 9, op: "×", correct: 90),
        QuestionItem(a: 108, b: 9, op: "÷", correct: 12),
        QuestionItem(a: 50, b: 45, op: "+", correct: 95),
        QuestionItem(a: 29, b: 22, op: "-", correct: 7),
        QuestionItem(a: 6, b: 12, op: "×", correct: 72)
    ]

    let gameSession = GameSession(
        id: "123",
        players: [
            GamePlayer(uid: "123", displayName: "andy.v123"),
            GamePlayer(uid: "234", displayName: "bob.123")
        ],
        questionSet: QuestionSet(questions: questions),
        startAt: Timestamp(),
        postgame: GamePostgame(acceptingSubmissions: true)
    )

    return (
        GeometryReader { screen in
            MultiplayerGameView(gameSession: gameSession)
                .environmentObject(DeviceModel(screen: screen))
                .environmentObject(AuthInfoModel())
                .environmentObject(AppModel(path: NavigationPath()))
        }
    )
}
