//
//  HomeView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 7/7/24.
//

import SwiftUI

struct HomeView: View {
    @State var showOptions = false
    
    @State var width1: CGFloat = 0
    @State var width2: CGFloat = 0
    @State var width3: CGFloat = 0
    @State var width4: CGFloat = 0
    
    let smallHeight: CGFloat = 70
    let normalheight: CGFloat = 80
    let iPadHeight: CGFloat = 100
    
    @State var mode: GameMode = .ADDITION
    
    @State var isProfileView = false
    @State var showNoAccountAlert = false
    
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
                
                VStack(spacing: 10) {
                    Text("compete")
                        .foregroundStyle(Color("darkPurple"))
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 10) {
                        Button(action: {}, label: {
                            VStack(alignment: .trailing, spacing: 10) {
                                Text("one vs one")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .fontWeight(.bold)
                                
                                
                                
                                Image(systemName: "flag.pattern.checkered")
                                    .font(.largeTitle)
                                    .frame(height: 32)
                            }
                            .foregroundStyle(.white)
                        })
                        .padding(15)
                        .raisedButton(cornerRadius: 17, backgroundColor: Color("pastelOrange"), shadowColor: Color("darkPastelOrange"), action: {})
                        
                        Button(action: {}, label: {
                            VStack(alignment: .trailing, spacing: 10) {
                                Text("time trial")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .fontWeight(.bold)
                                
                                Image(systemName: "timer")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .frame(height: 32)
                                
                            }
                            .foregroundStyle(.white)
                        })
                        .padding(15)
                        .raisedButton(cornerRadius: 17, backgroundColor: Color("pastelPink"), shadowColor: Color("darkPastelPink"), action: {
                            
                            appModel.path.append(GameConfigsModel(mode: .TIME, difficulty: .MEDIUM, timeLimit: .ONE_MIN, numQuestions: 10))
                        })
                    }
                }
                
                VStack(spacing: 10) {
                    Text("solo practice")
                        .foregroundStyle(Color("darkPurple"))
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 22) {
                        HStack(spacing: 10) {
                            Button(action: {}, label: {
                                VStack(alignment: .trailing, spacing: 10) {
                                    Text("addition")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .fontWeight(.bold)
                                    
                                    Image(systemName: "plus")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .frame(height: 32)
                                }
                                .foregroundStyle(.white)
                            })
                            .padding(15)
                            .raisedButton(cornerRadius: 17, backgroundColor: Color("pastelPurple"), shadowColor: Color("darkPastelPurple"), action: {
                                
                                appModel.path.append(GameConfigsModel(mode: .ADDITION, difficulty: .EASY, timeLimit: .ONE_MIN, numQuestions: 10))
                            })
                            
                            Button(action: {}, label: {
                                VStack(alignment: .trailing, spacing: 10) {
                                    Text("subtraction")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .fontWeight(.bold)
                                    
                                    Image(systemName: "minus")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .frame(height: 32)
                                    
                                }
                                .foregroundStyle(.white)
                            })
                            .padding(15)
                            .raisedButton(cornerRadius: 17, backgroundColor: Color("pastelBlue"), shadowColor: Color("darkPastelBlue"), action: {
                                
                                appModel.path.append(GameConfigsModel(mode: .SUBTRACTION, difficulty: .EASY, timeLimit: .ONE_MIN, numQuestions: 10))
                            })
                        }
                        
                        HStack(spacing: 10) {
                            Button(action: {}, label: {
                                VStack(alignment: .trailing, spacing: 10) {
                                    Text("multiplication")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .fontWeight(.bold)
                                    
                                    Image(systemName: "multiply")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .frame(height: 32)
                                }
                                .foregroundStyle(.white)
                            })
                            .padding(15)
                            .raisedButton(cornerRadius: 17, backgroundColor: Color("pastelRed"), shadowColor: Color("darkPastelRed"), action: {
                                
                                appModel.path.append(GameConfigsModel(mode: .MULTIPLICATION, difficulty: .EASY, timeLimit: .ONE_MIN, numQuestions: 10))
                            })
                            
                            Button(action: {}, label: {
                                VStack(alignment: .trailing, spacing: 10) {
                                    Text("division")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .fontWeight(.bold)
                                    
                                    Image(systemName: "divide")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .frame(height: 32)
                                    
                                }
                                .foregroundStyle(.white)
                            })
                            .padding(15)
                            .raisedButton(cornerRadius: 17, backgroundColor: Color("pastelGreen"), shadowColor: Color("darkPastelGreen"), action: {
                                
                                appModel.path.append(GameConfigsModel(mode: .DIVISION, difficulty: .EASY, timeLimit: .ONE_MIN, numQuestions: 10))
                            })
                        }
                    }
                }
                
                Spacer()
            }
            
            .padding(device.valueByDevice(small: 15, normal: 20, ipad: 30))
            
            SideBar(isViewingProfile: $isProfileView)
            
        } //: ZStack
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
