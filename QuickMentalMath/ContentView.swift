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

struct ContentView: View {
    
    
    @State var pulsingAmount = 0.95
    @State var showOptions = false
    
    @State var extendedHeight: CGFloat = 0
    
    let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    @State var maxExtend = false
    
    @State var modeIndex = 0
    @State var difficultyIndex = 0
    
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
    
    
    var body: some View {
        GeometryReader { screen in
            ZStack {

                VStack(spacing: 0) {
                    Color.white.ignoresSafeArea()
                    Color("textColor").ignoresSafeArea()
                        .frame(height: screen.size.height * 0.3)
                }

                VStack(alignment: .center, spacing: 20) {
                    HStack {
                        Text("Welcome!")
                            .font(.largeTitle)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(Color("textColor"))
                        Spacer()
                        
                        Button {
                            isProfileView = true
                        } label: {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(Color("textColor"))
                                .font(.title)
                        }
                        .sheet(isPresented: $isProfileView, content: {
                            ProfileView(totalQuestionsAnswered: $totalQuestionsAnswered, totalQuestionsCorrect: $totalQuestionsCorrect, isProfileView: $isProfileView, isIpad: screen.size.width > 500)
                        })
                        
                        
                        Spacer()
                        
                    } // HStack
                    .padding(.horizontal, screen.size.width > 500 ? 60 : 20)
                    .padding(.top, 10)
                    
                    
                    OptionsGroup(title: "Mode", items: ["Addition", "Subtraction", "Multiplication", "Division"], selectedID: $modeIndex)
                        .padding(.horizontal, screen.size.width > 500 ? 50 : 20)
                        .frame(maxHeight: screen.size.height * 0.23)
                    
                    if modeIndex < 3 {
                        OptionsGroup(title: "Difficulty", items: ["Easy", "Medium", "Hard", "Decimals"], selectedID: $difficultyIndex)
                            .padding(.horizontal, screen.size.width > 500 ? 50 : 20)
                            .frame(maxHeight: screen.size.height * 0.23)
                        
                    }
                    else {
                        OptionsGroup(title: "Difficulty", items: ["Easy", "Medium", "Hard"], selectedID: $difficultyIndex)
                            .padding(.horizontal, screen.size.width > 500 ? 50 : 20)
                            .frame(maxHeight: screen.size.height * 0.23)
                    }

                    Spacer()



                } // VStack

                VStack {
                    Spacer()
                    ZStack {
                        Color("orange")
                            .roundedCorner(25, corners: [.topLeft, .topRight])
                            .ignoresSafeArea()
                            .frame(maxWidth: screen.size.width > 500 ? screen.size.width*0.8 : screen.size.width*0.9, maxHeight: screen.size.height * 0.35 + extendedHeight)
                            .shadow(radius: 7)
                            .animation(.easeOut(duration: 0.25),
                                       value: extendedHeight
                            )

                        VStack(spacing: screen.size.height < 736 && screen.size.width < 390 ? 20 : 30) {

                            Text("Next")
                                .font(screen.size.height < 736 && screen.size.width < 390 ? .title : .largeTitle)
                                .bold()
                                .foregroundColor(.white)


                            ZStack {

                                Button {
                                    extendedHeight = screen.size.height * 0.65 - screen.size.height * 0.35
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {

                                        hapticFeedback.impactOccurred()
                                        showOptions = true
                                    }

                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        extendedHeight = 0
                                    }


                                } label: {
                                    ZStack {
                                        Circle()
                                            .stroke(Color("textColor"), lineWidth: 5)
                                            .background(Circle().fill(Color("goColor")))
                                            .frame(maxWidth: screen.size.height * 0.2)
                                            .shadow(radius: 15)

                                        Image(systemName: "arrow.up")
                                            .font(.system(size: screen.size.height < 736 && screen.size.width < 390 ? 45 : 55, weight: .bold))
                                            .foregroundColor(.white)
                                    } // ZStack

                                }
                                .sheet(isPresented: $showOptions, content: {
                                    ExtraOptionsView(modeIndex: $modeIndex, difficultyIndex: $difficultyIndex)
                                })
                            }

                            Spacer()

                        }
                        .padding(.top, 30)
                        .frame(maxHeight: screen.size.height * 0.35 + extendedHeight)
                        .animation(.easeOut(duration: 0.25),
                                   value: extendedHeight
                        )




                    } // ZStack
                    .gesture(
                        DragGesture(minimumDistance: 30)
                            .onEnded{_ in
                                extendedHeight = 0
                                if maxExtend {
                                    hapticFeedback.impactOccurred()
                                    maxExtend = false
                                    self.showOptions = true
                                }

                                maxExtend = false


                            }
                            .onChanged{ value in
                                let offset = (value.location.y - value.startLocation.y) * -1

                                var tmp = extendedHeight

                                tmp = max(0, tmp + offset)


                                if screen.size.height*0.35 + tmp <= screen.size.height*0.65 {
                                    extendedHeight = tmp
                                    maxExtend = false
                                }
                                else {
                                    maxExtend = true
                                }


                            }

                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)


            } // ZStack
            .onAppear {
                if UserDefaults.standard.dictionary(forKey: "totalAnswered") == nil {
                    UserDefaults.standard.set(self.totalQuestionsAnswered, forKey: "totalAnswered")
                }
                else {
                    self.totalQuestionsAnswered = UserDefaults.standard.dictionary(forKey: "totalAnswered") as! [String: Int]
                }
                
                if UserDefaults.standard.dictionary(forKey: "totalCorrect") == nil {
                    UserDefaults.standard.set(self.totalQuestionsCorrect, forKey: "totalCorrect")
                }
                else {
                    self.totalQuestionsCorrect = UserDefaults.standard.dictionary(forKey: "totalCorrect") as! [String: Int]
                }
                
                
            }
        }
    } // body
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
