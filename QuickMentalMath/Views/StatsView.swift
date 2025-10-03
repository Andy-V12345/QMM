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
    
    @EnvironmentObject var authInfo: AuthInfoModel
    
    @State var additionPercent: Double = 0
    @State var subtractionPercent: Double = 0
    @State var multiplicationPercent: Double = 0
    @State var divisionPercent: Double = 0
    
    var body: some View {
        GeometryReader { screen in
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 25) {
                    HStack {
                        Text("your stats")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color("darkPurple"))
                            .font(.largeTitle)
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
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text("overview")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color("lightPurple"))
                            
                            StatPanel(imageName: "bolt.fill", imageColor: Color("lightYellow"), value: String(authInfo.user?.stats?.highScore ?? 0), label: "high score", borderColor: Color.gray, progress: nil)
                            
                            StatPanel(imageName: "timer", imageColor: Color("correctGreen"), value: String(authInfo.user?.stats?.ttHighScore ?? 0), label: "time trial best", borderColor: Color.gray, progress: nil)
                        }
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text("by section")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color("lightPurple"))
                            
                            StatPanel(imageName: "plus.circle.fill", imageColor: Color("pastelPurple"), value: "\(Int(additionPercent * 100))%", label: "addition", borderColor: Color("pastelPurple"), progress: additionPercent)
                            
                            StatPanel(imageName: "minus.circle.fill", imageColor: Color("pastelBlue"), value: "\(Int(subtractionPercent * 100))%", label: "subtraction", borderColor: Color("pastelBlue"), progress: subtractionPercent)
                            
                            StatPanel(imageName: "multiply.circle.fill", imageColor: Color("pastelRed"), value: "\(Int(multiplicationPercent * 100))%", label: "multiplication", borderColor: Color("pastelRed"), progress: multiplicationPercent)
                            
                            StatPanel(imageName: "divide.circle.fill", imageColor: Color("pastelGreen"), value: "\(Int(divisionPercent * 100))%", label: "division", borderColor: Color("pastelGreen"), progress: divisionPercent)
                        }
                    }
                    else {
                        Spacer()
                        
                        LoadingSpinner(size: 25, color: Color("lightPurple"), width: 5)
                    }
                    
                    Spacer()
                } //: Parent VStack
                .padding(20)
            } //: ZStack
            .onAppear {
                additionPercent = authInfo.user?.stats?.additionTot == 0 ? 0 : Double((authInfo.user?.stats!.additionScore)!) / Double((authInfo.user?.stats!.additionTot)!)
                
                subtractionPercent = authInfo.user?.stats?.subtractionTot == 0 ? 0 : Double((authInfo.user?.stats!.subtractionScore)!) / Double((authInfo.user?.stats!.subtractionTot)!)
                
                multiplicationPercent = authInfo.user?.stats?.multiplicationTot == 0 ? 0 : Double((authInfo.user?.stats!.multiplicationScore)!) / Double((authInfo.user?.stats!.multiplicationTot)!)
                
                divisionPercent = authInfo.user?.stats?.divisionTot == 0 ? 0 : Double((authInfo.user?.stats!.divisionScore)!) / Double((authInfo.user?.stats!.divisionTot)!)
            }
        }
    }
}

#Preview {
    let userStats = UserStats(id: 0, additionScore: 20, additionTot: 40, subtractionScore: 10, subtractionTot: 30, multiplicationScore: 0, multiplicationTot: 0, divisionScore: 10, divisionTot: 50, highScore: 45, ttHighScore: 100)
    
    let user = User(id: 0, username: "Andyv123", jwtToken: "dfafdsaf", stats: userStats)
    
    return StatsView().environmentObject(AuthInfoModel(user: user))
}
