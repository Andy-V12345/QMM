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
        VStack(alignment: .center, spacing: 30) {
            HStack {
                Text("Welcome!")
                    .font(.largeTitle)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color("textColor"))
                    .padding(.horizontal, 10)
                Spacer()
                Image(systemName: "person.circle.fill")
                    .foregroundColor(Color("textColor"))
                    .padding(.horizontal, 10)
                    .font(.title)
                }
            
//            Spacer()
                        
            OptionsGroup(title: "Mode", items: ["Addition", "Subtraction", "Multiplication", "Division"])
            
            OptionsGroup(title: "Difficulty", items: ["Easy", "Medium", "Hard"])
            
            
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color("textColor"))
                    .frame(width: 200)
                    .scaleEffect(pulsingAmount)
                    .opacity(2 - pulsingAmount)
                    .animation(
                        .easeInOut(duration: 0.95)
                            .repeatForever(autoreverses: true),
                        value: pulsingAmount
                    )
                    .onAppear{self.pulsingAmount = 1.2}
                Circle()
                    .fill(Color("bgColor"))
                    .frame(width: 200)
                    .shadow(radius: 15)
                    
                Text("Go!")
                    .font(.system(size: 45, weight: .bold))
                    .foregroundColor(.white)
            }
                
            Spacer()
            
//            VStack {
//                Text("Difficulty")
//                    .font(.headline)
//                    .bold()
//                    .foregroundColor(Color("textColor"))
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
//                    .fill(Color("bgColor"))
//            }
//
//            VStack {
//                Text("Time Limit")
//                    .font(.headline)
//                    .bold()
//                    .foregroundColor(Color("textColor"))
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
//                    .fill(Color("bgColor"))
//            }
//
            
            
            
//            Spacer()
            
            
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
