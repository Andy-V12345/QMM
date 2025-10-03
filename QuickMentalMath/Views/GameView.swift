//
//  GameView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 5/15/23.
//

import SwiftUI

struct GameView: View {
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var topSize = 0.65
    
    @State var input: String = "f"
    
    @State var num1: Double = 0
    @State var num2: Double = 0
    
    @State var answer: Double = 0
    
    @State var isGameOver = false
    @State var showAreYouSure = false
    @State var isTimerPaused = false
        
    let numSize: CGFloat = 0.11
    
    var keyColumns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 0, alignment: .center), count: 3)
    
    var keyNums = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 0, 11, 12]
    
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var gameModel: GameModel
    
    var body: some View {
        GeometryReader { screen in
            ZStack {
                Color.white.ignoresSafeArea()
                                
                VStack(spacing: 0) {
                    VStack {
                        InGameStats(startTime: gameModel.startTime,  showAreYouSure: $showAreYouSure, isTimerPaused: $isTimerPaused, isGameOver: $isGameOver, timeLeft: $gameModel.timeLeft, numCorrect: $gameModel.score)
                            .padding(.horizontal, 20)
                        
                        Spacer()
                        
                        // numbers display
                        
                        VStack(spacing: 10) {
                            if gameModel.difficulty != "decimals" {
                                Text(num1 > num2 ? String(Int(num1)) : String(Int(num2)))
                                    .font(.system(size: screen.size.width * numSize, weight: .bold, design: .rounded))
                                    .foregroundColor(Color("darkPurple"))
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .tracking(screen.size.height < 736 && screen.size.width < 390 ? 5 : 8)
                            }
                            else {
                                Text(num1 > num2 ? String(format: "%.2f", num1) : String(format: "%.2f", num2))
                                    .font(.system(size: screen.size.width * numSize, weight: .bold, design: .rounded))
                                    .foregroundColor(Color("darkPurple"))
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .tracking(screen.size.height < 736 && screen.size.width < 390 ? 5 : 8)
                            }
                            
                            HStack {
                                Text("\(gameModel.mode == "time" ? gameModel.tmpMode : gameModel.mode)")
                                    .font(.system(size: screen.size.width * numSize, weight: .bold, design: .rounded))
                                    .bold()
                                    .foregroundColor(Color("darkPurple"))
                                
                                Spacer()
                                
                                if gameModel.difficulty != "decimals" {
                                    Text(num1 < num2 ? String(Int(num1)) : String(Int(num2)))
                                        .font(.system(size: screen.size.width * numSize, weight: .bold, design: .rounded))
                                        .bold()
                                        .foregroundColor(Color("darkPurple"))
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .tracking(screen.size.height < 736 && screen.size.width < 390 ? 5 : 8)
                                }
                                else {
                                    Text(num1 < num2 ? String(format: "%.2f", num1) : String(format: "%.2f", num2))
                                        .font(.system(size: screen.size.width * numSize, weight: .bold, design: .rounded))
                                        .bold()
                                        .foregroundColor(Color("darkPurple"))
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .tracking(screen.size.height < 736 && screen.size.width < 390 ? 5 : 8)
                                }
                            }
                            
                            Rectangle()
                                .fill(Color("darkPurple"))
                                .frame(maxWidth: .infinity, maxHeight: 5)
                                .cornerRadius(5)
                            
                            
                            Text(input)
                                .font(.system(size: screen.size.width * numSize, weight: .bold, design: .rounded))
                                .bold()
                                .foregroundColor(Color("darkPurple"))
                                .opacity(input == "f" ? 0 : 1)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .tracking(screen.size.height < 736 && screen.size.width < 390 ? 5 : 8)
                            
                            
                            
                        } // VStack
                        .frame(maxWidth: screen.size.width * (gameModel.difficulty == "decimals" ? 0.6 : 0.55))
                        
                        Spacer()
                        
                    } // VStack
                    .padding(.top, 20)
                    .frame(maxHeight: screen.size.height * topSize)
                    
                    // keypad
                    
                    VStack(spacing: 5) {
                        HStack {
                            ForEach(1...3, id: \.self) { index in
                                KeyPadButton(id: String(keyNums[index-1]), input: $input, num1: $num1, num2: $num2, answer: $answer, isGameOver: $isGameOver, isIpad: screen.size.width > 500)
                            }
                        }
                        HStack {
                            ForEach(4...6, id: \.self) { index in
                                KeyPadButton(id: String(keyNums[index-1]), input: $input, num1: $num1, num2: $num2, answer: $answer, isGameOver: $isGameOver, isIpad: screen.size.width > 500)
                            }
                        }
                        HStack {
                            ForEach(7...9, id: \.self) { index in
                                KeyPadButton(id: String(keyNums[index-1]), input: $input, num1: $num1, num2: $num2, answer: $answer, isGameOver: $isGameOver, isIpad: screen.size.width > 500)
                            }
                        }
                        HStack {
                            ForEach(10...12, id: \.self) { index in
                                KeyPadButton(id: String(keyNums[index-1]), input: $input, num1: $num1, num2: $num2, answer: $answer, isGameOver: $isGameOver, isIpad: screen.size.width > 500)
                            }
                        }
                        
                        if gameModel.difficulty == "decimals" {
                            KeyPadButton(id: String(keyNums[12]), input: $input, num1: $num1, num2: $num2, answer: $answer, isGameOver: $isGameOver, isIpad: screen.size.width > 500)
                        }
                    }
                    .frame(height: screen.size.height * (1 - topSize))
                    .padding(.horizontal, 10)
                    
                    Spacer()
                    
                } // VStack
                .frame(maxHeight: .infinity)
                
            } // ZStack
            .frame(maxHeight: .infinity)
            .onAppear() {
                isGameOver = false
                topSize = gameModel.difficulty == "decimals" ? 0.6 : 0.65
                
                if gameModel.startTime > 180 { // No time limit
                    timer.upstream.connect().cancel()
                }
            }
            .onChange(of: isGameOver, perform: { new in
                if new {
                    timer.upstream.connect().cancel()
                    gameModel.timeLeft = gameModel.startTime
                    appModel.path.append(AppState.END)
                }
            })
            .alert("Are You Sure?", isPresented: $showAreYouSure, actions: {
                Button(role: .none, action: {
                    timer.upstream.connect().cancel()
                    gameModel.reset()
                    appModel.path.removeLast()
                    appModel.path.removeLast()
                }, label: {
                    Text("Yes")
                })
                
                Button(role: .cancel, action: {
                    isTimerPaused.toggle()
                }, label: {
                    Text("Cancel")
                })
            }, message: {
                Text("You'll lose your current progress!")
            })
        } // GeometryReader
        .onReceive(timer) { time in
            if !isTimerPaused {
                if gameModel.timeLeft > 0 {
                    gameModel.timeLeft -= 1
                }
                else {
                    isGameOver = true
                    timer.upstream.connect().cancel()
                }
            }
        }
    } // body
    
    func convertTime(seconds: CGFloat) -> String {
        let min = Int(floor(seconds / 60))
        let sec = Int(seconds) % 60
        
        
        if sec < 10 {
            return "\(min):0\(sec)"
        }
        else {
            return "\(min):\(sec)"
        }
    }
}

#Preview {
    GameView()
        .environmentObject(GameModel())
        .environmentObject(AppModel(path: NavigationPath()))
}



