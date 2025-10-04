//
//  TimeTrialView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 7/10/24.
//

import SwiftUI

struct TimeTrialView: View {
    
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var gameModel: GameModel
    @EnvironmentObject var authInfo: AuthInfoModel
    @EnvironmentObject var device: DeviceModel
    
    @State var difficultyIndex = 1
    @State var timeIndex = 0
    @State var displayLeaderboard = false
    @State var showNoAccountAlert = false
    
    @AppStorage("authState") var authState: AuthState = .UNAUTHORIZED
    @AppStorage("jwtToken") var jwtToken = ""
    @AppStorage("username") var username = ""
    @AppStorage("id") var id = 0
    
    let buttonRadius: CGFloat = 10
    let shadowOffset: CGFloat = 3
    
    func handleStart() {
        gameModel.setTime(timeIndex: 0)
        gameModel.setMode(modeIndex: 4)
        gameModel.setDifficulty(difficultyIndex: 1)
        
        appModel.path.append(AppState.GAME)
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 35) {
                HStack {
                    VStack {
                        Text("welcome to")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color("darkPurple"))
                            .font(device.valueByDevice(small: .headline, normal: .title2, ipad: .title))
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 15) {
                            Text("time trial")
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                            
                            Image(systemName: "timer")
                                .font(.title)
                                .bold()
                            
                            Spacer()
                        }
                        .foregroundStyle(Color("lightPurple"))
                    } //: Text Title VStack
                    
                    Spacer()
                    
                    Button(action: {}, label: {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(.white)
                            .font(device.valueByDevice(small: .subheadline, normal: .headline, ipad: .headline))
                    })
                    .frame(width: device.valueByDevice(small: 32, normal: 37, ipad: 40), height: device.valueByDevice(small: 30, normal: 35, ipad: 38))
                    .raisedButton(cornerRadius: 40, shadowOffset: 2, action: {
                        if authInfo.authState == .AUTHORIZED {
                            displayLeaderboard = true
                        }
                        else {
                            showNoAccountAlert = true
                        }
                    })
                    
                }
                
                HStack(spacing: device.valueByDevice(small: 15, normal: 20, ipad: 30)) {
                    DifficultySelector(difficultyIndex: $difficultyIndex, isTimeTrial: true)
                    
                    TimeSelector(timeIndex: $timeIndex, isTimeTrial: true)
                }
                
                Spacer()
                
                VStack(spacing: device.valueByDevice(small: 35, normal: 35, ipad: 40)) {
                    Button(action: {}, label: {
                        HStack {
                            Text("start")
                            
                            Image(systemName: "arrow.right")
                        }
                        .foregroundStyle(Color("darkPurple"))
                        .font(device.valueByDevice(small: .title2, normal: .title2, ipad: .title))
                        .fontWeight(.heavy)
                    })
                    .padding(device.valueByDevice(small: 12, normal: 15, ipad: 15))
                    .frame(maxWidth: .infinity)
                    .raisedButton(impactStrength: .heavy, cornerRadius: 20, backgroundColor: Color("lighterPurple"), shadowColor: Color("lightPurple"), shadowOffset: device.valueByDevice(small: 11, normal: 11, ipad: 13),
                                  action: {
                        handleStart()
                    })
                    //: Start Button
                    
                    Button(action: {
                        appModel.path.removeLast()
                    }, label: {
                        Text("back to home")
                            .foregroundStyle(Color("darkPurple"))
                    })
                    .font(device.valueByDevice(small: .headline, normal: .headline, ipad: .title3))
                    .fontWeight(.heavy)
                }
            } //: VStack
            .padding(device.valueByDevice(small: 15, normal: 20, ipad: 30))
        } //: ZStack
        .fullScreenCover(isPresented: $displayLeaderboard, content: {
            LeaderboardView()
        })
        .alert("No Account", isPresented: $showNoAccountAlert, actions: {
            Button(role: .none, action: {
                authInfo.user = nil
                authInfo.authState = .UNAUTHORIZED
                jwtToken = ""
                username = ""
                id = 0
                authState = authInfo.authState
                appModel.path.removeLast()
                appModel.path.removeLast()
            }, label: {
                Text("Sign in")
            })
            
            Button(role: .cancel, action: {
                
            }, label: {
                Text("Cancel")
            })
        }, message: {
            Text("Sign in to your QMM account to view the leaderboard!")
        })
    }
}

#Preview {
    GeometryReader { screen in
        TimeTrialView()
            .environmentObject(AppModel(path: NavigationPath()))
            .environmentObject(DeviceModel(screen: screen))
    }
}
