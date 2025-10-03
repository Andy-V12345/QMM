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
        GeometryReader { metrics in
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 35) {
                    HStack {
                        VStack {
                            Text("welcome to")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.title2)
                                .bold()
                                .foregroundStyle(Color("darkPurple"))
                            
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
                                .font(.body)
                        })
                        .frame(width: 37, height: 35)
                        .raisedButton(cornerRadius: 40, shadowOffset: 2, action: {
                            if authInfo.authState == .AUTHORIZED {
                                displayLeaderboard = true
                            }
                            else {
                                showNoAccountAlert = true
                            }
                        })
                        
                    }
                    
                    
                    
                    HStack(spacing: 20) {
                        VStack(spacing: 15) {
                            Button(action: {
                            }, label: {
                                Text("easy")
                                    .foregroundStyle(difficultyIndex == 0 ? .white : Color("lightGreen"))
                            })
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .raisedButton(cornerRadius: buttonRadius, backgroundColor: difficultyIndex == 0 ? Color("lightGreen") : Color("offWhite"), shadowColor: difficultyIndex == 0 ? Color("darkGreen") : Color.gray.opacity(0.2), shadowOffset: shadowOffset, action: {})
                            .allowsHitTesting(false)
                            .opacity(0.7)
                            
                            Divider()
                            
                            Button(action: {
                            }, label: {
                                Text("medium")
                                    .foregroundStyle(difficultyIndex == 1 ? .white : Color("lightYellow"))
                            })
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .raisedButton(cornerRadius: buttonRadius, backgroundColor: difficultyIndex == 1 ? Color("lightYellow") : Color("offWhite"), shadowColor: difficultyIndex == 1 ? Color("darkYellow") : Color.gray.opacity(0.2), shadowOffset: shadowOffset, action: {})
                            
                            Divider()
                            
                            Button(action: {
                            }, label: {
                                Text("hard")
                                    .foregroundStyle(difficultyIndex == 2 ? .white : Color("lightOrange"))
                            })
                            .padding(.vertical, 10)
                            .padding(.horizontal, 15)
                            .frame(maxWidth: .infinity)
                            .raisedButton(cornerRadius: buttonRadius, backgroundColor: difficultyIndex == 2 ? Color("lightOrange") : Color("offWhite"), shadowColor: difficultyIndex == 2 ? Color("darkOrange") : Color.gray.opacity(0.2), shadowOffset: shadowOffset, action: {})
                            .allowsHitTesting(false)
                            .opacity(0.7)
                            
                            Divider()
                            
                            Button(action: {
                            }, label: {
                                Text("decimals")
                                    .foregroundStyle(difficultyIndex == 3 ? .white : Color("lightRed"))
                            })
                            .padding(.vertical, 10)
                            .padding(.horizontal, 15)
                            .frame(maxWidth: .infinity)
                            .raisedButton(cornerRadius: buttonRadius, backgroundColor: difficultyIndex == 3 ? Color("lightRed") : Color("offWhite"), shadowColor: difficultyIndex == 3 ? Color("darkRed") : Color.gray.opacity(0.2), shadowOffset: shadowOffset, action: {})
                            .allowsHitTesting(false)
                            .opacity(0.7)
                            
                            Divider()
                            
                            Text("difficulty")
                                .fontWeight(.heavy)
                                .foregroundColor(Color("lightPurple"))
                            
                        }
                        .bold()
                        .font(.headline)
                        .padding(15)
                        .background(.white)
                        .roundedCorner(20, corners: .allCorners)
                        .clipped()
                        .shadow(radius: 2)
                        
                        VStack(spacing: 15) {
                            Button(action: {}, label: {
                                Text("1 min")
                                    .foregroundStyle(timeIndex == 0 ? .white : Color("darkPurple"))
                            })
                            .padding(.vertical, 10)
                            .padding(.horizontal, 15)
                            .frame(maxWidth: .infinity)
                            .raisedButton(cornerRadius: buttonRadius, backgroundColor: timeIndex == 0 ? Color("darkPurple") : Color("offWhite"), shadowColor: timeIndex == 0 ? Color("darkerPurple") :  Color.gray.opacity(0.2), shadowOffset: shadowOffset, action: {
                                timeIndex = 0
                            })
                            
                            Divider()
                            
                            Button(action: {}, label: {
                                Text("2 min")
                                    .foregroundStyle(timeIndex == 1 ? .white : Color("darkPurple"))
                            })
                            .padding(.vertical, 10)
                            .padding(.horizontal, 15)
                            .frame(maxWidth: .infinity)
                            .raisedButton(cornerRadius: buttonRadius, backgroundColor: timeIndex == 1 ? Color("darkPurple") : Color("offWhite"), shadowColor: timeIndex == 1 ? Color("darkerPurple") :  Color.gray.opacity(0.2), shadowOffset: shadowOffset, action: {})
                            .allowsHitTesting(false)
                            .opacity(0.7)
                            
                            Divider()
                            
                            Button(action: {}, label: {
                                Text("3 min")
                                    .foregroundStyle(timeIndex == 2 ? .white : Color("darkPurple"))
                            })
                            .padding(.vertical, 10)
                            .padding(.horizontal, 15)
                            .frame(maxWidth: .infinity)
                            .raisedButton(cornerRadius: buttonRadius, backgroundColor: timeIndex == 2 ? Color("darkPurple") : Color("offWhite"), shadowColor: timeIndex == 2 ? Color("darkerPurple") :  Color.gray.opacity(0.2), shadowOffset: shadowOffset, action: {})
                            .allowsHitTesting(false)
                            .opacity(0.7)
                            
                            Divider()
                            
                            Button(action: {}, label: {
                                Text("no limit")
                                    .foregroundStyle(timeIndex == 3 ? .white : Color("darkPurple"))
                            })
                            .padding(.vertical, 10)
                            .padding(.horizontal, 15)
                            .frame(maxWidth: .infinity)
                            .raisedButton(cornerRadius: buttonRadius, backgroundColor: timeIndex == 3 ? Color("darkPurple") : Color("offWhite"), shadowColor: timeIndex == 3 ? Color("darkerPurple") :  Color.gray.opacity(0.2), shadowOffset: shadowOffset, action: {})
                            .allowsHitTesting(false)
                            .opacity(0.7)
                            
                            Divider()
                            
                            Text("time limit")
                                .fontWeight(.heavy)
                                .foregroundColor(Color("lightPurple"))
                        }
                        .font(.headline)
                        .bold()
                        .padding(15)
                        .background(.white)
                        .roundedCorner(20, corners: .allCorners)
                        .clipped()
                        .shadow(radius: 2)
                        
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 35) {
                        Button(action: {}, label: {
                            HStack {
                                Text("start")
                                
                                Image(systemName: "arrow.right")
                            }
                            .foregroundStyle(Color("darkPurple"))
                            .font(.title2)
                            .fontWeight(.heavy)
                        })
                        .padding(15)
                        .frame(maxWidth: .infinity)
                        .raisedButton(cornerRadius: 20, backgroundColor: Color("lighterPurple"), shadowColor: Color("lightPurple"), shadowOffset: 11,
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
                        .font(.body)
                        .fontWeight(.heavy)
                    }
                    
                } //: VStack
                .padding(20)
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

#Preview {
    TimeTrialView()
        .environmentObject(AppModel(path: NavigationPath()))
}
