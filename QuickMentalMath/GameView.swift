//
//  GameView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 5/15/23.
//

import SwiftUI

struct GameView: View {
    
    @State var timeLeft: CGFloat = 60
    
    @State var startTime: CGFloat = 60
    
    @Binding var timeIndex: Int
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @Environment(\.dismiss) var dismiss
    
    @State var totalQuestions: Int
    @State var mode: String
    @State var difficulty: String
    
    @State var times: [CGFloat] = [60, 120, 180, 1000]
        
    var body: some View {
        GeometryReader { screen in
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ZStack {
                        Color("textColor")
                            .roundedCorner(25, corners: [.bottomLeft, .bottomRight])
                            .ignoresSafeArea()
                            .frame(maxHeight: screen.size.height * 0.5)
                        
                        Image(systemName: "figure.walk.departure")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, maxHeight: screen.size.height*0.5, alignment: .topLeading)
                            .onTapGesture {
                                dismiss()
                            }
                        
                        
                        VStack {
                            
                            
                            HStack {
                                
                                Spacer()
                                                                
                                VStack(spacing: 5) {
                                    Text("1 / \(totalQuestions)")
                                        .font(.title)
                                        .foregroundColor(.white)
                                        .bold()
                                    Text("Question")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                
                                Spacer()
                                
                                // timer
                                
                                ZStack {
                                    Circle()
                                        .stroke(Color.white.opacity(0.8),
                                                style: StrokeStyle(lineWidth: 10))
                                        .overlay() {
                                            Text(startTime <= 180 ? convertTime(seconds: timeLeft) : "∞")
                                                .font(.system(size: screen.size.width * 0.08, weight: .bold, design:.rounded))
                                                .foregroundColor(Color.white)
                                        }
                                    if self.startTime <= 180 {
                                        Circle()
                                            .trim(from: 0, to: ((startTime - timeLeft) / startTime))
                                            .stroke(Color("goColor"),
                                                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                                            )
                                            .rotationEffect(Angle(degrees: -90))
                                            .animation(.easeIn, value: timeLeft)
                                    }
                                }
                                .frame(maxWidth: screen.size.width * 0.3)
                                .onReceive(timer) { time in
                                    if timeLeft > 0 {
                                        timeLeft -= 1
                                    }
                                }
                                
                                Spacer()
                                
                                VStack(spacing: 5) {
                                    Text("0")
                                        .font(.title)
                                        .foregroundColor(.white)
                                        .bold()
                                    Text("Points")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                
                                Spacer()
                                
                            } // HStack
                            
                            Spacer()
                            
                            VStack(spacing: 10) {
                                
                                Text("100")
                                    .font(.system(size: screen.size.width * 0.12, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                HStack {
                                    Text("\(mode)")
                                        .font(.system(size: screen.size.width * 0.12, weight: .bold, design: .rounded))
                                        .bold()
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text("20")
                                        .font(.system(size: screen.size.width * 0.12, weight: .bold, design: .rounded))
                                        .bold()
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                                
                                
                            } // VStack
                            .frame(maxWidth: screen.size.width * 0.3)
                            
                            Spacer()
                            
                        } // VStack
                        .padding(.top, 20)
                        .frame(maxHeight: screen.size.height * 0.5)
                        
                    }
                    Spacer()
                                        
                } // VStack
                
            } // ZStack
            .onAppear() {
                startTime = times[timeIndex]
                timeLeft = times[timeIndex]
            }
        } // GeometryReader
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
    
} // struct

//struct GameView_Previews: PreviewProvider {
//    static var previews: some View {
//        GameView(timeIndex: 1, totalQuestions: 20, mode: "x", difficulty: "easy")
//    }
//}
