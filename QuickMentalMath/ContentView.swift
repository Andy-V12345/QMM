//
//  ContentView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 5/8/23.
//

import SwiftUI

struct ContentView: View {
        
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text("Welcome!")
                .font(.largeTitle)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color("textColor"))
                .padding(.horizontal, 10)
            
            Spacer()
                        
            OptionsGroup(title: "Mode", items: ["Addition", "Subtraction", "Multiplication", "Division"])
            
            OptionsGroup(title: "Difficulty", items: ["Easy", "Medium", "Hard"])
            
            
            
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
            
            
            
            Spacer()
            
            
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
