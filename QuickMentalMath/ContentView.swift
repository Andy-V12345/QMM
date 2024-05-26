//
//  ContentView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 5/8/23.
//

import SwiftUI

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func roundedCorner(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners) )
    }
}

class GameModel: ObservableObject {
    @Published var mode = ""
    @Published var difficulty = ""
    @Published var time: CGFloat = 0
    @Published var totQuestions = 0
    
    var modes: [String] = ["+", "-", "x", "÷"]
    var difficulties: [String] = ["easy", "medium", "hard", "decimals"]
    var times: [CGFloat] = [60, 120, 180, 1000]
    
    func setMode(modeIndex: Int) {
        mode = modes[modeIndex]
    }
    
    func setDifficulty(difficultyIndex: Int) {
        difficulty = difficulties[difficultyIndex]
    }
    
    func setTime(timeIndex: Int) {
        time = times[timeIndex]
    }

}

class DeviceModel: ObservableObject {
    @Published var isSmall = false
}

struct ContentView: View {
    
    @State var showOptions = false
        
    @State var width1: CGFloat = 0
    @State var width2: CGFloat = 0
    @State var width3: CGFloat = 0
    @State var width4: CGFloat = 0
    
        
    @State var modeIndex = -1
    
    @State var isProfileView = false
    
    @State var totalQuestionsAnswered: [String: Int] = [
        "Addition": 0,
        "Subtraction": 0,
        "Multiplication": 0,
        "Division": 0
    ]
    
    @State var totalQuestionsCorrect: [String: Int] = [
        "Addition": 0,
        "Subtraction": 0,
        "Multiplication": 0,
        "Division": 0
    ]
    
    @StateObject private var game = GameModel()
    
    @StateObject private var device = DeviceModel()
    
    var body: some View {
        GeometryReader { screen in
            ZStack {
                VStack {
                    Color.white.ignoresSafeArea()
                }
                
                VStack(alignment: .leading) {
                    VStack {
                        Text("Welcome to QMM!")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color("darkPurple"))
                            .fontWeight(.semibold)
                            .font(screen.size.height < 700 ? .headline : .title2)
                        
                        Text("Choose a mode")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color("darkPurple"))
                            .font(screen.size.height < 700 ? .title : .largeTitle)
                            .bold()
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: screen.size.width > 500 ? 70 : 30) {
                        
                        HStack(spacing: 0) {
                            Text("Addition")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .font(screen.size.width > 500 ? .title : .title2)
                                .fontWeight(.bold)
                                .foregroundStyle(Color("pastelPurple"))
                            Image(systemName: "plus")
                                .padding(.horizontal, screen.size.width > 500 ? 30 : 20)
                                .font(screen.size.width > 500 ? .title : .title2)
                                .frame(maxHeight: .infinity)
                                .roundedCorner(10, corners: [.topRight, .bottomRight])
                                .background(Color("pastelPurple"))
                                .foregroundStyle(.white)
                                .fontWeight(.semibold)
                            
                        }
                        .frame(maxWidth: .infinity)
                        .frame(width: modeIndex != 0 ? screen.size.width * 0.75 : screen.size.width * 0.95, height: screen.size.height < 700 ? 80 : 100)
                        .background(.white)
                        .roundedCorner(10, corners: [.topRight, .bottomRight])
                        .shadow(color: modeIndex == 0 ? Color("lightPurple") : Color.black.opacity(0.2), radius: modeIndex == 0 ? 8 : 3)
                        .padding(0)
                        .onTapGesture {
                            modeIndex = 0
                        }
                        .animation(.spring(duration: 0.3, bounce: 0.6), value: modeIndex)
                        
                        HStack {
                            Spacer()
                            HStack(spacing: 0) {
                                Image(systemName: "minus")
                                    .padding(.horizontal, screen.size.width > 500 ? 30 : 20)
                                    .font(screen.size.width > 500 ? .title : .title2)
                                    .frame(maxHeight: .infinity)
                                    .roundedCorner(10, corners: [.topLeft, .bottomLeft])
                                    .background(Color("pastelBlue"))
                                    .foregroundStyle(.white)
                                    .fontWeight(.semibold)
                                
                                Text("Subtraction")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .font(screen.size.width > 500 ? .title : .title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color("pastelBlue"))
                                
                            }
                            .frame(maxWidth: .infinity)
                            .frame(width: modeIndex != 1 ? screen.size.width * 0.75 : screen.size.width * 0.95, height: screen.size.height < 700 ? 80 : 100)
                            .background(.white)
                            .roundedCorner(10, corners: [.topLeft, .bottomLeft])
                            .shadow(color: modeIndex == 1 ? Color("lightBlue") : Color.black.opacity(0.2), radius: modeIndex == 1 ? 8 : 3)
                            .onTapGesture {
                                
                                modeIndex = 1
                                
                            }
                            .animation(.spring(duration: 0.3, bounce: 0.6), value: modeIndex)
                        }
                        
                        HStack(spacing: 0) {
                            Text("Multiplication")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .font(screen.size.width > 500 ? .title : .title2)
                                .fontWeight(.bold)
                                .foregroundStyle(Color("pastelRed"))
                            Image(systemName: "multiply")
                                .padding(.horizontal, screen.size.width > 500 ? 30 : 20)
                                .font(screen.size.width > 500 ? .title : .title2)
                                .frame(maxHeight: .infinity)
                                .roundedCorner(10, corners: [.topRight, .bottomRight])
                                .background(Color("pastelRed"))
                                .foregroundStyle(.white)
                                .fontWeight(.semibold)
                            
                        }
                        .frame(maxWidth: .infinity)
                        .frame(width: modeIndex != 2 ? screen.size.width * 0.75 : screen.size.width * 0.95, height: screen.size.height < 700 ? 80 : 100)
                        .background(.white)
                        .roundedCorner(10, corners: [.topRight, .bottomRight])
                        .shadow(color: modeIndex == 2 ? Color("pastelRed") : Color.black.opacity(0.2), radius: modeIndex == 2 ? 8 : 3)
                        .onTapGesture {
                            modeIndex = 2
                        }
                        .animation(.spring(duration: 0.3, bounce: 0.6), value: modeIndex)
                        
                        HStack {
                            Spacer()
                            HStack(spacing: 0) {
                                Image(systemName: "divide")
                                    .padding(.horizontal, screen.size.width > 500 ? 30 : 20)
                                    .font(screen.size.width > 500 ? .title : .title2)
                                    .frame(maxHeight: .infinity)
                                    .roundedCorner(10, corners: [.topLeft, .bottomLeft])
                                    .background(Color("pastelGreen"))
                                    .foregroundStyle(.white)
                                    .fontWeight(.semibold)
                                
                                Text("Division")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .font(screen.size.width > 500 ? .title : .title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color("pastelGreen"))
                                
                            }
                            .frame(maxWidth: .infinity)
                            .frame(width: modeIndex != 3 ? screen.size.width * 0.75 : screen.size.width * 0.95, height: screen.size.height < 700 ? 80 : 100)
                            .background(.white)
                            .roundedCorner(10, corners: [.topLeft, .bottomLeft])
                            .shadow(color: modeIndex == 3 ? Color("lightGreen") : Color.black.opacity(0.2), radius: modeIndex == 3 ? 8 : 3)
                            .onTapGesture {
                                modeIndex = 3
                            }
                            .animation(.spring(duration: 0.3, bounce: 0.6), value: modeIndex)
                        }
                    }
                    
                    
                    Spacer()
                    
                    
                    Button(action: {
                        game.setMode(modeIndex: modeIndex)
                        device.isSmall = screen.size.height < 736 && screen.size.width < 390
                        showOptions = true
                    }, label: {
                        Text("Confirm")
                            .font(screen.size.width > 500 ? .title : .title2)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .padding(.vertical, screen.size.width > 500 ? 30 : 18)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(Color("darkPurple"))
                            .roundedCorner(10, corners: .allCorners)
                    })
                    .padding(.horizontal, 20)
                    .shadow(radius: 3)
                    .opacity(modeIndex == -1 ? 0.6 : 1)
                    .disabled(modeIndex == -1)

                                
        
                } //: VStack
                .padding(.vertical, 15)
                
            } //: ZStack
            .sheet(isPresented: $showOptions, content: {
                ExtraOptionsView()
                    .environmentObject(game)
                    .environmentObject(device)
            })
        }
    } // body
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
