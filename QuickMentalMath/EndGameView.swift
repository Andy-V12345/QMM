//
//  EndGameView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 6/4/23.
//

import SwiftUI
import AVKit

struct AnimatableNumberModifier: AnimatableModifier {
    var number: Double
    
    var animatableData: Double {
        get { number }
        set { number = newValue }
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Text("\(Int(number))%")
                
            )
    }
}

extension View {
    func animatingOverlay(for number: Double) -> some View {
        modifier(AnimatableNumberModifier(number: number))
    }
}

struct EndGameView: View {
    
    @State var score: Int
    @State var totalQuestions: Int
    @State var percentage: Float = 0
    
    @State var timeIndex: Int
    @State var mode: String
    @State var difficulty: String
    
    @State var isGoHome = false
    @State var isRedo = false
    @State var isReviewing = false
    
    @State var bestScore = UserDefaults.standard.integer(forKey: "best")
    
    @State var missedQuestions: [MissedQuestion]
    
    @State var totalQuestionsAnswered: [String: Int] = [:]
    @State var totalQuestionsCorrect: [String: Int] = [:]
    
    @State var audioPlayer: AVAudioPlayer!
    
    let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        GeometryReader { screen in
            ZStack {
                Color.white
                    .ignoresSafeArea()
                VStack {
                    ZStack {
                        Color("goColor")
                            .ignoresSafeArea()
                        
                    } // ZStack
                    .frame(maxHeight: screen.size.height * 0.5)
                    
                    Spacer()
                    
                } // VStack
                
                VStack(spacing: 20) {
                    Text("GAME OVER")
                        .font(.system(size: screen.size.height*0.06, weight: .bold))
                        .foregroundColor(.white)
                    
                    
                    
                    ZStack {
                       
                        Color("goColor")
                            .cornerRadius(20)
                            .shadow(radius: 20)
                        
                        
                        
                        VStack {
                            
                            Text("Results")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.white)
                                .frame(maxWidth: screen.size.width * 0.5, maxHeight: screen.size.height * 0.08)
                                .background(
                                    Color("bgColor")
                                        .roundedCorner(20, corners: [.bottomLeft, .bottomRight])

                                )
                                
                            Spacer()
                            
                            VStack(spacing: screen.size.width > 500 ? 40 : 20) {
                                Spacer()
                                ZStack {
                                    Circle()
                                        .stroke(Color.white.opacity(0.9),
                                                style: StrokeStyle(lineWidth: screen.size.width * 0.04))
                                        .animatingOverlay(for: Double(percentage))
                                        .font(.system(size: screen.size.width * 0.12, weight: .bold))
                                        .foregroundColor(.white)
                                        
                                    
                                    Circle()
                                        .trim(from: 0, to: CGFloat(percentage) / 100)
                                        .stroke(Color("bgColor"),
                                                style: StrokeStyle(lineWidth: screen.size.width * 0.04, lineCap: .round)
                                        )
                                        .rotationEffect(Angle(degrees: -90))
                                    
                                } // ZStack
                                .frame(maxWidth: screen.size.width * 0.55)
                                .frame(maxHeight: screen.size.width > 500 ? screen.size.height * 0.3 : screen.size.width * 0.55)
                                
                                
                                HStack {
                                    VStack(spacing: 0) {
                                        Text("Score")
                                            .font(screen.size.height < 800 ? .title : .largeTitle)
                                            .bold()
                                            .foregroundColor(.white)
                                        Text("\(score)")
                                            .font(screen.size.height < 800 ? .title2 : .title)
                                            .bold()
                                            .foregroundColor(.white)
                                    }
                                    .frame(maxWidth: .infinity)
                                    
                                    Spacer()
                                    
                                    VStack(spacing: 0) {
                                        Text("Best")
                                            .font(screen.size.height < 800 ? .title : .largeTitle)
                                            .bold()
                                            .foregroundColor(.white)
                                        Text("\(bestScore)")
                                            .font(screen.size.height < 800 ? .title2 : .title)
                                            .bold()
                                            .foregroundColor(.white)
                                    }
                                    .frame(maxWidth: .infinity)
                                } // HStack
                                .padding(.horizontal)
                                
                                Spacer()
                            }
                            
                            
                            
                            Spacer()
                            
                        } // VStack
                        .frame(maxHeight: .infinity)
                        
                    } // ZStack
                    .frame(maxWidth: screen.size.width * 0.85)
                    .frame(height: screen.size.height * 0.6)
                    
                    
                    ZStack {
                        Color("bgColor")
                        HStack(spacing: 15) {
                            Text("Review")
                                .font(.largeTitle)
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.title)
                        }
                        .bold()
                        .foregroundColor(.white)
                    }
                    .cornerRadius(15)
                    .padding(.horizontal)
                    .onTapGesture {
                        withAnimation {
                            isReviewing = true
                        }
                    }
                    
                    HStack(spacing: 20) {
                        ZStack {
                            Color("bgColor")
                            Image(systemName: "arrow.counterclockwise")
                                .font(.title)
                                .bold()
                                .foregroundColor(.white)
                                
                        }
                        .onTapGesture {
                            isRedo = true
                        }
                        .fullScreenCover(isPresented: $isRedo, content: {
                            GameView(timeIndex: $timeIndex, totalQuestions: totalQuestions, mode: mode, difficulty: difficulty)
                        })
                        .cornerRadius(15)
                        
                        ZStack {
                            Color("bgColor")
                            Image(systemName: "house.fill")
                                .font(.title)
                                .bold()
                                .foregroundColor(.white)
                                
                        }
                        .cornerRadius(15)
                        .onTapGesture {
                            isGoHome = true
                        }
                        .fullScreenCover(isPresented: $isGoHome, content: {
                            ContentView()
                            
                        })

                        
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, maxHeight: screen.size.height * 0.1)
                    
                } // VStack
                .padding(.vertical)
                .onAppear {
                    withAnimation(.linear(duration: 1)) {
                        percentage = (Float(score) / Float(totalQuestions)) * 100
                    }
                    
                    let sound = Bundle.main.path(forResource: "uiButton", ofType: "mp3")
                    
                    self.audioPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound!))
                    
                    if score > 0 {
                                                
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                            hapticFeedback.impactOccurred()
                            audioPlayer.volume = 1.0
                            if !UserDefaults.standard.bool(forKey: "isMuted") {
                                self.audioPlayer.play()
                            }
                        }
                    }
                    
                    if score > bestScore {
                        bestScore = score
                        UserDefaults.standard.set(score, forKey: "best")
                    }
                    
                }
                .opacity(isReviewing ? 0.6 : 1)
                
                if isReviewing {
                    MissedQuestionsView(misssedQuestions: missedQuestions, isReviewing: $isReviewing)
                        .frame(maxWidth: screen.size.width * 0.95, maxHeight: screen.size.height * 0.4)
                        .cornerRadius(20)
                        .shadow(radius: 20)
                }
                                
            } // ZStack
        }
    
        
    } // body
    
}

struct EndGameView_Previews: PreviewProvider {
    static var previews: some View {
        EndGameView(score: 20, totalQuestions: 40, timeIndex: 0, mode: "+", difficulty: "easy", missedQuestions: [])
    }
}
