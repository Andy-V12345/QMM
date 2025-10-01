//
//  TimeTrialView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 7/10/24.
//

import SwiftUI

struct TimeTrialView: View {
    
    @EnvironmentObject var deviceModel: DeviceModel
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var gameModel: GameModel
    @EnvironmentObject var authInfo: AuthInfo
    
    @State var difficultyIndex = 1
    @State var timeIndex = 0
    @State var displayLeaderboard = false
    @State var showNoAccountAlert = false
    
    @AppStorage("authState") var authState: AuthState = .UNAUTHORIZED
    @AppStorage("jwtToken") var jwtToken = ""
    @AppStorage("username") var username = ""
    @AppStorage("id") var id = 0
    
    var body: some View {
        GeometryReader { metrics in
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    HStack {
                        Button(action: {
                            appModel.path.removeLast()
                        }, label: {
                            Image(systemName: "chevron.left")
                                .foregroundStyle(Color("darkPurple"))
                        })
                        .font(.title3)
                        .bold()
                        
                        Spacer()
                        
                        Button(action: {
                            if authInfo.authState == .AUTHORIZED {
                                displayLeaderboard = true
                            }
                            else {
                                showNoAccountAlert = true
                            }
                        }, label: {
                            Image(systemName: "medal")
                                .foregroundStyle(Color("darkPurple"))
                        })
                        .font(.title3)
                        .bold()
                    }
                    
                    VStack(spacing: 40) {
                        VStack(spacing: 20) {
                            VStack {
                                Text("Welcome to")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.title2)
                                    .bold()
                                    .foregroundStyle(Color("darkPurple"))
                                
                                HStack(spacing: 15) {
                                    Text("Time Trial")
                                        .font(.largeTitle)
                                        .fontWeight(.heavy)
                                    
                                    
                                    Image(systemName: "timer")
                                        .font(.title)
                                        .bold()
                                    
                                    Spacer()
                                }
                                .foregroundStyle(Color("lightPurple"))
                            } //: Text Title VStack
                            
                            Text("In this mode, you'll get 60 seconds to answer as many problems as possible. Play with an account for a chance to be featured on the leaderboard!")
                                .multilineTextAlignment(.leading)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        HStack(spacing: 20) {
                            
                            VStack(spacing: metrics.size.height < 736 && metrics.size.width < 390 ? 8 : 15) {
                                VStack(spacing: deviceModel.type == .SMALL ? 8 : 15) {
                                    Button(action: {
                                    }, label: {
                                        Text("Easy")
                                            .foregroundStyle(difficultyIndex == 0 ? .white : Color("lightGreen"))
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 15)
                                            .frame(maxWidth: .infinity)
                                            .background(difficultyIndex == 0 ? Color("lightGreen") : .white)
                                            .roundedCorner(10, corners: .allCorners)
                                            .animation(.easeInOut(duration: 0.25), value: difficultyIndex)
                                    })
                                    .opacity(0.4)
                                    .disabled(true)
                                    
                                    Divider()
                                    
                                    Button(action: {
                                    }, label: {
                                        Text("Medium")
                                            .foregroundStyle(difficultyIndex == 1 ? .white : Color("lightYellow"))
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 15)
                                            .frame(maxWidth: .infinity)
                                            .background(difficultyIndex == 1 ? Color("lightYellow") : .white)
                                            .roundedCorner(10, corners: .allCorners)
                                            .animation(.easeInOut(duration: 0.25), value: difficultyIndex)
                                    })
                                    
                                    Divider()
                                    
                                    Button(action: {
                                    }, label: {
                                        Text("Hard")
                                            .foregroundStyle(difficultyIndex == 2 ? .white : Color("lightOrange"))
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 15)
                                            .frame(maxWidth: .infinity)
                                            .background(difficultyIndex == 2 ? Color("lightOrange") : .white)
                                            .roundedCorner(10, corners: .allCorners)
                                            .animation(.easeInOut(duration: 0.25), value: difficultyIndex)
                                    })
                                    .opacity(0.4)
                                    .disabled(true)
                                    
                                    Divider()
                                    
                                    Button(action: {
                                    }, label: {
                                        Text("Decimals")
                                            .foregroundStyle(difficultyIndex == 3 ? .white : Color("lightRed"))
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 15)
                                            .frame(maxWidth: .infinity)
                                            .background(difficultyIndex == 3 ? Color("lightRed") : .white)
                                            .roundedCorner(10, corners: .allCorners)
                                            .animation(.easeInOut(duration: 0.25), value: difficultyIndex)
                                    })
                                    .opacity(0.4)
                                    .disabled(true)
                                    
                                }
                                .font(deviceModel.type == .SMALL ? .subheadline : .headline)
                                .bold()
                                
                                Divider()
                                
                                Text("Difficulty")
                                    .font(metrics.size.height < 736 && metrics.size.width < 390 ? .subheadline : .headline)
                                    .fontWeight(.heavy)
                                    .foregroundColor(Color("lightPurple"))
                            }
                            .padding(metrics.size.height < 736 && metrics.size.width < 390 ? 8 : 15)
                            .background(.white)
                            .roundedCorner(10, corners: .allCorners)
                            .clipped()
                            .shadow(radius: 2)
                            
                            VStack(spacing: metrics.size.height < 736 && metrics.size.width < 390 ? 8 : 15) {
                                
                                VStack(spacing: deviceModel.type == .SMALL ? 8 : 15) {
                                    Button(action: {
                                    }, label: {
                                        Text("1 Min")
                                            .foregroundStyle(timeIndex == 0 ? .white : Color("darkPurple"))
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 15)
                                            .frame(maxWidth: .infinity)
                                            .background(timeIndex == 0 ? Color("darkPurple") : .white)
                                            .roundedCorner(10, corners: .allCorners)
                                            .animation(.easeInOut(duration: 0.25), value: timeIndex)
                                    })
                                    
                                    Divider()
                                    
                                    Button(action: {
                                    }, label: {
                                        Text("2 Min")
                                            .foregroundStyle(timeIndex == 1 ? .white : Color("darkPurple"))
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 15)
                                            .frame(maxWidth: .infinity)
                                            .background(timeIndex == 1 ? Color("darkPurple") : .white)
                                            .roundedCorner(10, corners: .allCorners)
                                            .animation(.easeInOut(duration: 0.25), value: timeIndex)
                                    })
                                    .opacity(0.4)
                                    .disabled(true)
                                    
                                    Divider()
                                    
                                    Button(action: {
                                    }, label: {
                                        Text("3 Min")
                                            .foregroundStyle(timeIndex == 2 ? .white : Color("darkPurple"))
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 15)
                                            .frame(maxWidth: .infinity)
                                            .background(timeIndex == 2 ? Color("darkPurple") : .white)
                                            .roundedCorner(10, corners: .allCorners)
                                            .animation(.easeInOut(duration: 0.25), value: timeIndex)
                                    })
                                    .opacity(0.4)
                                    .disabled(true)
                                    
                                    Divider()
                                    
                                    Button(action: {
                                    }, label: {
                                        Text("No Limit")
                                            .foregroundStyle(timeIndex == 3 ? .white : Color("darkPurple"))
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 15)
                                            .frame(maxWidth: .infinity)
                                            .background(timeIndex == 3 ? Color("darkPurple") : .white)
                                            .roundedCorner(10, corners: .allCorners)
                                            .animation(.easeInOut(duration: 0.25), value: timeIndex)
                                    })
                                    .opacity(0.4)
                                    .disabled(true)
                                    
                                }
                                .font(deviceModel.type == .SMALL ? .subheadline : .headline)
                                .bold()
                                
                                Divider()
                                
                                Text("Time Limit")
                                    .font(metrics.size.height < 736 && metrics.size.width < 390 ? .subheadline : .headline)
                                    .fontWeight(.heavy)
                                    .foregroundColor(Color("lightPurple"))
                            }
                            .padding(metrics.size.height < 736 && metrics.size.width < 390 ? 8 : 15)
                            .background(.white)
                            .roundedCorner(10, corners: .allCorners)
                            .clipped()
                            .shadow(radius: 2)
                            
                        }
                        
                        HStack {
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 10) {
                                Text("Are you ready?")
                                    .foregroundStyle(Color("lightPurple"))
                                    .fontWeight(.bold)
                                    .font(.title3)
                                
                                Button {
                                    gameModel.setTime(timeIndex: 0)
                                    gameModel.setMode(modeIndex: 4)
                                    gameModel.setDifficulty(difficultyIndex: 1)
                                    
                                    appModel.path.append(AppState.GAME)
                                } label: {
                                    HStack {
                                        Text("Start")
                                        
                                        Image(systemName: "arrow.right")
                                    }
                                    .foregroundStyle(Color("darkPurple"))
                                    .font(.title2)
                                    .fontWeight(.heavy)
                                } //: Start Button
                            }
                        } //: HStack
                        
                        
                        
                    } //: VStack
                    
                    Spacer()
                } //: Parent VStack
                .padding([.horizontal, .top], 20)
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
        } //: GeometryReader
    }
}

//#Preview {
//    TimeTrialView()
//        .environmentObject(DeviceModel())
//        .environmentObject(AppModel(path: NavigationPath()))
//}
