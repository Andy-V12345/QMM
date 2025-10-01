//
//  StatsView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 7/14/24.
//

import SwiftUI

struct StatsView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State var accuracy: Double = 0
        
    @EnvironmentObject var authInfo: AuthInfo
    
    var body: some View {
        GeometryReader { screen in
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    HStack {
                        VStack {
                            Text("\(authInfo.user?.username ?? "")")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(Color("darkPurple"))
                                .font(.title2)
                            
                            Text("Your stats")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(Color("lightPurple"))
                                .font(.largeTitle)
                        } //: Title VStack
                        .bold()
                        
                        Spacer()
                        
                        Button(action: {
                            dismiss()
                        }, label: {
                            Image(systemName: "chevron.down")
                                .font(.title3)
                                .bold()
                                .foregroundStyle(Color("darkPurple"))
                        })
                    }
                    
                    if authInfo.user != nil && authInfo.user?.stats != nil {
                        HStack(spacing: 10) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Your high score: \(authInfo.user?.stats?.highScore ?? 0)")
                                    .frame(maxWidth: .infinity)
                                    .padding(21)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(.white)
                                        
                                    )
                                    .clipped()
                                    .shadow(color: Color("lighterPurple"), radius: 3)
                                
                                
                                Text("Time trial best: \(authInfo.user?.stats?.ttHighScore ?? 0)")
                                    .frame(maxWidth: .infinity)
                                    .padding(21)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(.white)
                                    )
                                    .clipped()
                                    .shadow(color: Color("lighterPurple"), radius: 3)
                            }
                            .foregroundStyle(Color("darkPurple"))
                            .bold()
                            .font(.headline)
                            
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.2),
                                            style: StrokeStyle(lineWidth: 7))
                                    .overlay() {
                                        VStack(spacing: 3) {
                                            Text("\(Int(accuracy * 100))%")
                                                .foregroundStyle(Color("darkPurple"))
                                                .font(.title3)
                                                .bold()
                                            
                                            Text("ACCURACY")
                                                .font(.caption2)
                                                .foregroundStyle(Color("lighterPurple"))
                                                .bold()
                                        }
                                    }
                                Circle()
                                    .trim(from: 0, to: accuracy)
                                    .stroke(Color("lightPurple"),
                                            style: StrokeStyle(lineWidth: 7, lineCap: .round)
                                    )
                                    .rotationEffect(Angle(degrees: -90))
                            }
                            .frame(width: 100, height: 100)
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(.white)
                                
                            )
                            .clipped()
                            .shadow(color: Color("lighterPurple"), radius: 3)
                        } //: HStack
                        
                        VStack(spacing: screen.size.height < 750 ? 30 : 40) {
                            StatsBar(percentage: authInfo.user?.stats?.additionTot == 0 ? 0 : (Double((authInfo.user?.stats!.additionScore)!) / Double((authInfo.user?.stats!.additionTot)!)) * 100, imgName: "plus", color: Color("pastelPurple"), mode: "Addition")
                            
                            StatsBar(percentage: authInfo.user?.stats?.subtractionTot == 0 ? 0 : (Double((authInfo.user?.stats!.subtractionScore)!) / Double((authInfo.user?.stats!.subtractionTot)!)) * 100, imgName: "minus", color: Color("pastelBlue"), mode: "Subtraction")
                            
                            StatsBar(percentage: authInfo.user?.stats?.multiplicationTot == 0 ? 0 : (Double((authInfo.user?.stats!.multiplicationScore)!) / Double((authInfo.user?.stats!.multiplicationTot)!)) * 100, imgName: "multiply", color: Color("pastelRed"), mode: "Multiplication")
                            
                            StatsBar(percentage: authInfo.user?.stats?.divisionTot == 0 ? 0 : (Double((authInfo.user?.stats!.divisionScore)!) / Double((authInfo.user?.stats!.divisionTot)!)) * 100, imgName: "divide", color: Color("pastelGreen"), mode: "Division")
                        }
                    }
                    else {
                        Spacer()
                        
                        LoadingSpinner(size: 25, color: Color("lightPurple"), width: 5)
                    }
                    
                    Spacer()
                } //: Parent VStack
                .padding(.horizontal, 20)
                .padding(.vertical, 25)
            } //: ZStack
            .onAppear {
                let totQuestions = (authInfo.user?.stats!.additionTot)! + (authInfo.user?.stats!.subtractionTot)! + (authInfo.user?.stats!.multiplicationTot)! + (authInfo.user?.stats!.divisionTot)!
                
                let totCorrect = (authInfo.user?.stats!.additionScore)! + (authInfo.user?.stats!.subtractionScore)! + (authInfo.user?.stats!.multiplicationScore)! + (authInfo.user?.stats!.divisionScore)!
                
                accuracy = totQuestions > 0 ? Double(totCorrect) / Double(totQuestions) : 0
            }
        }
    }
}
