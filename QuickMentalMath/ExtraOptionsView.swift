//
//  TimeSelectView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 5/14/23.
//

import SwiftUI


struct ExtraOptionsView: View {
    
    @State var progress = 10.0
    @State var pulsingAmount = 0.95
    @State var showGame = false
    
    @State var timeIndex: Int = 0
    @Binding var modeIndex: Int
    @Binding var difficultyIndex: Int
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader { metrics in
            
            ZStack {
                
                VStack(spacing: 0) {
                    Color.white
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                }
                
                VStack(spacing: 20) {
                    ZStack {
                        Color("textColor")
                            .roundedCorner(30, corners: [.bottomLeft, .bottomRight])
                            .ignoresSafeArea()
                        
                        VStack {
                            
                            HStack {
                                Button {
                                    presentationMode.wrappedValue.dismiss()
                                } label: {
                                    Image(systemName: "xmark")
                                        .foregroundColor(.white)
                                        .font(.title3)
                                        .bold()
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            .frame(maxWidth: .infinity)
                            
                            VStack(spacing: 20) {
                                
                                QuestionSlider(value: $progress, in: 10...100)
                                    .frame(maxWidth: metrics.size.height * 0.2, maxHeight: metrics.size.height * 0.2)
                                Text("Number of Questions")
                                    .font(.title3)
                                    .foregroundColor(Color.white)
                                    .bold()
                                
                                
                                VStack(spacing: 15) {
                                    OptionSlider(items: ["1 min", "2 min", "3 min", "∞ min"], color: Color.white.opacity(0.65), borderRadius: 30, selectedIndex: $timeIndex)
                                    
                                    Text("Time Limit")
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(.white)
                                }
                                .padding()
                                
                                
                            }
                            
                            
                        } // VStack
                        
                        
                    } // ZStack
                    .frame(maxHeight: metrics.size.height * 0.65)
                    Spacer()
                    ZStack {
                        
                        Button {
                            showGame = true
                        } label: {
                            ZStack {
                                Capsule(style: .continuous)
                                    .fill(Color("goColor"))
                                    .frame(width: metrics.size.width * 0.8)
                                    .frame(maxHeight: metrics.size.width * 0.3)
                                    .shadow(radius: 15)
                                
                                Text("Begin")
                                    .font(.system(size: 35, weight: .bold))
                                    .foregroundColor(.white)
                                
                            } // ZStack
                        }
                        .fullScreenCover(isPresented: $showGame, content: {
                            GameView()
                        })
                        
                    }
                    
                    Spacer()
                    
                    
                } // VStack
            } // ZStack
            
        }
        .onAppear() {
            print(difficultyIndex)
        }
    }
}


//struct TimeButton: View {
//
//    @State var text: String
//    @Binding var selectedTimes: [String: Bool]
//
//    var body: some View {
//        Button {
//            self.selectedTimes[text] = true
//
//            for key in selectedTimes.keys {
//                if key != text {
//                    self.selectedTimes[key] = false
//                }
//            }
//
//        } label: {
//            ZStack {
//                Color("bgColor")
//                    .clipShape(RoundedRectangle(cornerRadius: 30))
//                    .opacity(selectedTimes[text]! ? 0.5 : 1.0)
//                Text(text)
//                    .font(.title2)
//                    .bold()
//                    .foregroundColor(.white)
//            }
//        }
//    }
//}
