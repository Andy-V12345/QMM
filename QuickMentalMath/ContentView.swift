//
//  ContentView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 5/8/23.
//

import SwiftUI

struct ContentView: View {
    
    @State var pulsingAmount = 0.95
            
    var body: some View {
        NavigationStack {
            GeometryReader { screen in
                ZStack {
                    
                    VStack {
                        Color.white.ignoresSafeArea()
                        Color("orange").ignoresSafeArea()
                            .frame(height: screen.size.height * 0.3)
                    }
                    
                    VStack(alignment: .center, spacing: 30) {
                        HStack {
                            Text("Welcome!")
                                .font(.largeTitle)
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color("textColor"))
                            Spacer()
                            
                            Button {
                                
                            } label: {
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(Color("textColor"))
                                    .font(.title)
                            }
                    
                            
                            Spacer()
                            
                        } // HStack
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                                    
                        OptionsGroup(title: "Mode", items: ["Addition", "Subtraction", "Multiplication", "Division"])
                            .padding(.horizontal, 10)
                        
                        OptionsGroup(title: "Difficulty", items: ["Easy", "Medium", "Hard"])
                            .padding(.horizontal, 10)
                        
                        Spacer()
                        
                        GeometryReader { metrics in
                            ZStack {
                                
                                Color("startContainerColor")
                                    .frame(maxWidth: metrics.size.width * 0.85, maxHeight: .infinity)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .shadow(radius: 10)
                                
                                Circle()
                                    .fill(.white)
                                    .frame(width: metrics.size.height * 0.6)
                                    .scaleEffect(pulsingAmount)
                                    .animation(
                                        .easeInOut(duration: 0.95)
                                            .repeatForever(autoreverses: true),
                                        value: pulsingAmount
                                    )
                                    .onAppear{self.pulsingAmount = 1.1}
                                
                                NavigationLink {
                                    ExtraOptionsView()
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(Color("goColor"))
                                            .frame(width: metrics.size.height * 0.6)
                                            .shadow(radius: 15)
                                            
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 55, weight: .bold))
                                            .foregroundColor(.white)
                                    } // ZStack
                                    
                                }
                                
                                
                            } // ZStack
                            .frame(maxWidth: .infinity)
                            .ignoresSafeArea()
                        }
                        
                        
                    }
                    // VStack
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
