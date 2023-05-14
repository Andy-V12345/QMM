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
    
    @State var selectedTimes: [String: Bool] = ["1 min":false, "2 min":false, "3 min":false, "∞ min":false]
    
    var body: some View {
        NavigationStack {
            GeometryReader { metrics in
                
                ZStack {
                    
                    VStack(spacing: 0) {
                        Color.white
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                    }
                    
                    VStack(spacing: 0) {
                        ZStack {
                            Color("textColor")
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                .ignoresSafeArea()
                            
                            VStack {
                                
                                HStack {
                                    NavigationLink() {
                                        ContentView()
                                    } label: {
                                        Image(systemName: "arrow.left")
                                            .foregroundColor(.white)
                                            .font(.title3)
                                            .bold()
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity)
                                
                                VStack(spacing: 20) {
                                    
                                    QuestionSlider(value: $progress, in: 10...100)
                                        .frame(maxWidth: 200, maxHeight: 200)
                                    Text("Number of Questions")
                                        .font(.title3)
                                        .foregroundColor(Color.white)
                                        .bold()
                                }
                            }
                            
                            
                        }
                        .frame(maxHeight: metrics.size.height * 0.36)
                        
                        ZStack {
                            Color.white
                                .ignoresSafeArea()
                            
                            VStack(spacing: 30) {
                                VStack(spacing: 20) {
                                    HStack(spacing: 10) {
                                        VStack(spacing: 10) {
                                            TimeButton(text: "1 min", selectedTimes: $selectedTimes)
                                            TimeButton(text: "3 min", selectedTimes: $selectedTimes)
                                        }
                                        
                                        VStack(spacing: 10) {
                                            TimeButton(text: "2 min", selectedTimes: $selectedTimes)
                                            TimeButton(text: "∞ min", selectedTimes: $selectedTimes)
                                        }
                                    }
                                    
                                    Text("Time Limit")
                                        .foregroundColor(Color("textColor"))
                                        .font(.title3)
                                        .bold()
                                    
                                }
                                .padding()
                                
                                ZStack {
                                    
                                    Circle()
                                        .fill(Color("startContainerColor"))
                                        .frame(height: metrics.size.height * 0.2)
                                        .scaleEffect(pulsingAmount)
                                        .animation(
                                            .easeInOut(duration: 0.95)
                                            .repeatForever(autoreverses: true),
                                            value: pulsingAmount
                                        )
                                        .onAppear{self.pulsingAmount = 1.1}
                                    
                                    NavigationLink {
                                        EmptyView()
                                    } label: {
                                        ZStack {
                                            Circle()
                                                .fill(Color("goColor"))
                                                .frame(height: metrics.size.height * 0.2)
                                                .shadow(radius: 15)
                                            
                                            Text("Go!")
                                                .font(.system(size: 40, weight: .bold))
                                                .foregroundColor(.white)
                                        } // ZStack
                                        
                                    }
                                } // ZStack
                                
                            } // VStack
                            
                        } // ZStack
                    }
                }
                
            }
        }
        .navigationBarBackButtonHidden(true)
        
    }
}


struct ExtraOptionsView_Preview: PreviewProvider {
    static var previews: some View {
        ExtraOptionsView()
    }
}

struct TimeButton: View {
    
    @State var text: String
    @Binding var selectedTimes: [String: Bool]
    
    var body: some View {
        Button {
            self.selectedTimes[text] = true
            
            for key in selectedTimes.keys {
                if key != text {
                    self.selectedTimes[key] = false
                }
            }
            
        } label: {
            ZStack {
                Color("orange")
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .opacity(selectedTimes[text]! ? 0.5 : 1.0)
                Text(text)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
            }
        }
    }
}
