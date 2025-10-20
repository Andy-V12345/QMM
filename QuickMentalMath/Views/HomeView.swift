//
//  HomeView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 7/7/24.
//

import SwiftUI

struct HomeView: View {
    @State var showOptions = false

    @State var isProfileView = false
    @State var showNoAccountAlert = false
    @State var lastGame: GameModel? = UserDefaults.standard.loadLastGame()

    @EnvironmentObject var authInfo: AuthInfoModel
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var device: DeviceModel

    @AppStorage("authState") var authState: AuthState = .UNAUTHORIZED
    @AppStorage("jwtToken") var jwtToken = ""
    @AppStorage("username") var username = ""
    @AppStorage("id") var id = 0
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: device.valueByDevice(small: 30, normal: 40, ipad: 60)) {
                HStack {
                    VStack {
                        Text("welcome to qmm!")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color("darkPurple"))
                            .font(device.valueByDevice(small: .title3, normal: .title2, ipad: .title))
                            .fontWeight(.semibold)
                        
                        Text("choose a mode")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color("lightPurple"))
                            .font(device.valueByDevice(small: .title, normal: .title, ipad: .largeTitle))
                            .bold()
                    }
                    
                    Spacer()
                    
                    Button(action: {}, label: {
                        Image(systemName: "person.fill")
                            .font(device.valueByDevice(small: .headline, normal: .title3, ipad: .title2))
                            .foregroundStyle(.white)
                            .dynamicTypeSize(.large)
                    })
                    .frame(width: device.valueByDevice(small: 32, normal: 37, ipad: 40), height: device.valueByDevice(small: 30, normal: 35, ipad: 38))
                    .raisedButton(cornerRadius: 100, shadowOffset: 2, action: {
                        if authInfo.authState == .AUTHORIZED {
                            isProfileView = true
                        }
                        else {
                            showNoAccountAlert = true
                        }
                    })
                }
                
                ScrollView {
                    VStack(spacing: device.valueByDevice(small: 30, normal: 40, ipad: 60)) {
                        if let game = lastGame {
                            VStack(spacing: 10) {
                                SectionHeader(title: "last practice")

                                LastPracticeDisplay(gameModel: game)
                            }
                        }

                        VStack(spacing: device.valueByDevice(small: 10, normal: 10, ipad: 15)) {
                            SectionHeader(title: "compete")
                            
                            HStack(spacing: device.valueByDevice(small: 10, normal: 10, ipad: 15)) {
                                ModeCard(
                                    title: "one vs one",
                                    iconName: "figure.run",
                                    backgroundColor: Color("pastelOrange"),
                                    shadowColor: Color("darkPastelOrange"),
                                    action: {}
                                )

                                ModeCard(
                                    title: "time trial",
                                    iconName: "timer",
                                    backgroundColor: Color("pastelPink"),
                                    shadowColor: Color("darkPastelPink"),
                                    action: {
                                        appModel.path.append(GameConfigsModel(mode: .TIME, difficulty: .MEDIUM, timeLimit: .ONE_MIN, numQuestions: 10))
                                    }
                                )
                            }
                        }
                        
                        VStack(spacing: device.valueByDevice(small: 10, normal: 10, ipad: 15)) {
                            SectionHeader(title: "solo practice")
                            
                            VStack(spacing: device.valueByDevice(small: 22, normal: 22, ipad: 27)) {
                                HStack(spacing: device.valueByDevice(small: 10, normal: 10, ipad: 15)) {
                                    ModeCard(
                                        title: "addition",
                                        iconName: "plus",
                                        backgroundColor: Color("pastelPurple"),
                                        shadowColor: Color("darkPastelPurple"),
                                        action: {
                                            appModel.path.append(GameConfigsModel(mode: .ADDITION, difficulty: .EASY, timeLimit: .ONE_MIN, numQuestions: 10))
                                        }
                                    )

                                    ModeCard(
                                        title: "subtraction",
                                        iconName: "minus",
                                        backgroundColor: Color("pastelBlue"),
                                        shadowColor: Color("darkPastelBlue"),
                                        action: {
                                            appModel.path.append(GameConfigsModel(mode: .SUBTRACTION, difficulty: .EASY, timeLimit: .ONE_MIN, numQuestions: 10))
                                        }
                                    )
                                }

                                HStack(spacing: device.valueByDevice(small: 10, normal: 10, ipad: 15)) {
                                    ModeCard(
                                        title: "multiplication",
                                        iconName: "multiply",
                                        backgroundColor: Color("pastelRed"),
                                        shadowColor: Color("darkPastelRed"),
                                        action: {
                                            appModel.path.append(GameConfigsModel(mode: .MULTIPLICATION, difficulty: .EASY, timeLimit: .ONE_MIN, numQuestions: 10))
                                        }
                                    )

                                    ModeCard(
                                        title: "division",
                                        iconName: "divide",
                                        backgroundColor: Color("pastelGreen"),
                                        shadowColor: Color("darkPastelGreen"),
                                        action: {
                                            appModel.path.append(GameConfigsModel(mode: .DIVISION, difficulty: .EASY, timeLimit: .ONE_MIN, numQuestions: 10))
                                        }
                                    )
                                }
                            }
                        }
                    }
                    .padding(.bottom, device.valueByDevice(small: 15, normal: 20, ipad: 30))
                }
                .scrollIndicators(.hidden)
            }
            
            .padding(device.valueByDevice(small: 15, normal: 20, ipad: 30))
            
            SideBar(isViewingProfile: $isProfileView)
            
        } //: ZStack
        .onAppear {
            lastGame = UserDefaults.standard.loadLastGame()
        }
        .alert("No Account", isPresented: $showNoAccountAlert, actions: {
            Button(role: .none, action: {
                authInfo.user = nil
                authInfo.authState = .UNAUTHORIZED
                jwtToken = ""
                username = ""
                id = 0
                authState = authInfo.authState
                appModel.path.removeLast()
            }, label: {
                Text("Sign in")
            })
            
            Button(role: .cancel, action: {
                
            }, label: {
                Text("Cancel")
            })
        }, message: {
            Text("You're not signed in! Create an account or sign in to your QMM account.")
        })

    } // body
}


#Preview {
    GeometryReader { screen in
        HomeView()
            .environmentObject(AuthInfoModel())
            .environmentObject(AppModel(path: NavigationPath()))
            .environmentObject(DeviceModel(screen: screen))
    }
}
