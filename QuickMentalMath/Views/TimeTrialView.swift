//
//  TimeTrialView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 7/10/24.
//

import SwiftUI

struct TimeTrialView: View {
    
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var authInfo: AuthInfoModel
    @EnvironmentObject var device: DeviceModel
    
    @State var difficulty: GameDifficulty
    @State var timeLimit: TimeLimit
    @State var mode: GameMode

    @State var showNoAccountAlert = false
    
    @AppStorage("authState") var authState: AuthState = .UNAUTHORIZED
    @AppStorage("jwtToken") var jwtToken = ""
    @AppStorage("username") var username = ""
    @AppStorage("id") var id = 0
    
    let buttonRadius: CGFloat = 10
    let shadowOffset: CGFloat = 3
    
    init(gameConfigsModel: GameConfigsModel) {
        self.difficulty = gameConfigsModel.difficulty
        self.mode = gameConfigsModel.mode
        self.timeLimit = gameConfigsModel.timeLimit
    }
    
    func handleStart() {
        let config = GameConfigsModel(mode: self.mode, difficulty: self.difficulty, timeLimit: self.timeLimit, numQuestions: 1000)
        
        appModel.path.append(GameModel(gameConfigs: config))
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
                                .font(device.valueByDevice(small: .title, normal: .largeTitle, ipad: .largeTitle))
                                .fontWeight(.heavy)
                            
                            Image(systemName: "timer")
                                .font(device.valueByDevice(small: .title, normal: .largeTitle, ipad: .largeTitle))
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
                            .dynamicTypeSize(.large)
                    })
                    .frame(width: device.valueByDevice(small: 32, normal: 37, ipad: 40), height: device.valueByDevice(small: 30, normal: 35, ipad: 38))
                    .raisedButton(cornerRadius: 40, shadowOffset: 2, action: {
                        if authInfo.authState == .AUTHORIZED {
                            appModel.showLeaderboard = true
                        }
                        else {
                            showNoAccountAlert = true
                        }
                    })
                    
                }
                
                HStack(spacing: device.valueByDevice(small: 15, normal: 20, ipad: 30)) {
                    DifficultySelector(difficulty: $difficulty, isTimeTrial: true)
                    
                    TimeSelector(timeLimit: $timeLimit, isTimeTrial: true)
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
                    .raisedButton(impactStrength: .heavy, cornerRadius: device.valueByDevice(small: 18, normal: 20, ipad: 20), backgroundColor: Color("lighterPurple"), shadowColor: Color("lightPurple"), shadowOffset: device.valueByDevice(small: 8, normal: 8, ipad: 12),
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
        .fullScreenCover(isPresented: $appModel.showLeaderboard, content: {
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
        TimeTrialView(gameConfigsModel: GameConfigsModel(mode: .MULTIPLICATION, difficulty: .MEDIUM, timeLimit: .ONE_MIN, numQuestions: 10))
            .environmentObject(AppModel(path: NavigationPath()))
            .environmentObject(DeviceModel(screen: screen))
            .environmentObject(AuthInfoModel())
    }
}
