//
//  HomeView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 7/7/24.
//

import SwiftUI

enum AppState: Hashable {
    case HOME, SETTINGS, GAME, END
}

struct HomeView: View {
    @State var showOptions = false
    
    @State var width1: CGFloat = 0
    @State var width2: CGFloat = 0
    @State var width3: CGFloat = 0
    @State var width4: CGFloat = 0
    
    @State var height: CGFloat = 80
    
    @State var modeIndex = 0
    
    @State var isProfileView = false
    @State var showNoAccountAlert = false
    
    @EnvironmentObject var authInfo: AuthInfoModel
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var game: GameModel
    
    @AppStorage("authState") var authState: AuthState = .UNAUTHORIZED
    @AppStorage("jwtToken") var jwtToken = ""
    @AppStorage("username") var username = ""
    @AppStorage("id") var id = 0
    
    var body: some View {
        GeometryReader { screen in
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 40) {
                    HStack {
                        VStack {
                            Text("welcome to qmm!")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(Color("darkPurple"))
                                .fontWeight(.semibold)
                                .font(screen.size.height < 700 ? .headline : .title2)
                            
                            Text("choose a mode")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(Color("lightPurple"))
                                .font(screen.size.height < 700 ? .title : .largeTitle)
                                .bold()
                        }
                        
                        Spacer()
                        
                        Button(action: {}, label: {
                            Image(systemName: "person.fill")
                                .font(.title3)
                                .foregroundStyle(.white)
                        })
                        .frame(width: 37, height: 35)
                        .raisedButton(cornerRadius: 100, shadowOffset: 2, action: {
                            if authInfo.authState == .AUTHORIZED {
                                isProfileView = true
                            }
                            else {
                                showNoAccountAlert = true
                            }
                        })
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(alignment: .leading, spacing: screen.size.width > 500 ? 70 : 30) {
                        
                        HStack(spacing: 0) {
                            Text("addition")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .font(screen.size.width > 500 ? .title : .title2)
                                .fontWeight(.bold)
                                .foregroundStyle(Color("pastelPurple"))
                            Image(systemName: "plus")
                                .padding(.horizontal, screen.size.width > 500 ? 30 : 20)
                                .font(screen.size.width > 500 ? .title : .title2)
                                .frame(maxHeight: .infinity)
                                .roundedCorner(10, corners: [.topRight, .bottomRight])
                                .background(Color("pastelPurple"))
                                .foregroundStyle(.white)
                                .fontWeight(.semibold)
                            
                        }
                        .frame(maxWidth: .infinity)
                        .frame(width: modeIndex != 0 ? screen.size.width * 0.7 : screen.size.width * 0.95, height: screen.size.height < 750 ? 70 : height)
                        .background(.white)
                        .roundedCorner(10, corners: [.topRight, .bottomRight])
                        .shadow(color: modeIndex == 0 ? Color("lightPurple") : Color.black.opacity(0.2), radius: modeIndex == 0 ? 8 : 3)
                        .padding(0)
                        .onTapGesture {
                            modeIndex = 0
                        }
                        .animation(.spring(duration: 0.3, bounce: 0.6), value: modeIndex)
                        
                        HStack {
                            Spacer()
                            HStack(spacing: 0) {
                                Image(systemName: "minus")
                                    .padding(.horizontal, screen.size.width > 500 ? 30 : 20)
                                    .font(screen.size.width > 500 ? .title : .title2)
                                    .frame(maxHeight: .infinity)
                                    .roundedCorner(10, corners: [.topLeft, .bottomLeft])
                                    .background(Color("pastelBlue"))
                                    .foregroundStyle(.white)
                                    .fontWeight(.semibold)
                                
                                Text("subtraction")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .font(screen.size.width > 500 ? .title : .title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color("pastelBlue"))
                                
                            }
                            .frame(maxWidth: .infinity)
                            .frame(width: modeIndex != 1 ? screen.size.width * 0.7 : screen.size.width * 0.95, height: screen.size.height < 750 ? 70 : height)
                            .background(.white)
                            .roundedCorner(10, corners: [.topLeft, .bottomLeft])
                            .shadow(color: modeIndex == 1 ? Color("lightBlue") : Color.black.opacity(0.2), radius: modeIndex == 1 ? 8 : 3)
                            .onTapGesture {
                                modeIndex = 1
                            }
                            .animation(.spring(duration: 0.3, bounce: 0.6), value: modeIndex)
                        }
                        
                        HStack(spacing: 0) {
                            Text("multiplication")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .font(screen.size.width > 500 ? .title : .title2)
                                .fontWeight(.bold)
                                .foregroundStyle(Color("pastelRed"))
                            Image(systemName: "multiply")
                                .padding(.horizontal, screen.size.width > 500 ? 30 : 20)
                                .font(screen.size.width > 500 ? .title : .title2)
                                .frame(maxHeight: .infinity)
                                .roundedCorner(10, corners: [.topRight, .bottomRight])
                                .background(Color("pastelRed"))
                                .foregroundStyle(.white)
                                .fontWeight(.semibold)
                            
                        }
                        .frame(maxWidth: .infinity)
                        .frame(width: modeIndex != 2 ? screen.size.width * 0.7 : screen.size.width * 0.95, height: screen.size.height < 750 ? 70 : height)
                        .background(.white)
                        .roundedCorner(10, corners: [.topRight, .bottomRight])
                        .shadow(color: modeIndex == 2 ? Color("pastelRed") : Color.black.opacity(0.2), radius: modeIndex == 2 ? 8 : 3)
                        .onTapGesture {
                            modeIndex = 2
                        }
                        .animation(.spring(duration: 0.3, bounce: 0.6), value: modeIndex)
                        
                        HStack {
                            Spacer()
                            HStack(spacing: 0) {
                                Image(systemName: "divide")
                                    .padding(.horizontal, screen.size.width > 500 ? 30 : 20)
                                    .font(screen.size.width > 500 ? .title : .title2)
                                    .frame(maxHeight: .infinity)
                                    .roundedCorner(10, corners: [.topLeft, .bottomLeft])
                                    .background(Color("pastelGreen"))
                                    .foregroundStyle(.white)
                                    .fontWeight(.semibold)
                                
                                Text("division")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .font(screen.size.width > 500 ? .title : .title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color("pastelGreen"))
                                
                            }
                            .frame(maxWidth: .infinity)
                            .frame(width: modeIndex != 3 ? screen.size.width * 0.7 : screen.size.width * 0.95, height: screen.size.height < 750 ? 70 : height)
                            .background(.white)
                            .roundedCorner(10, corners: [.topLeft, .bottomLeft])
                            .shadow(color: modeIndex == 3 ? Color("lightGreen") : Color.black.opacity(0.2), radius: modeIndex == 3 ? 8 : 3)
                            .onTapGesture {
                                modeIndex = 3
                            }
                            .animation(.spring(duration: 0.3, bounce: 0.6), value: modeIndex)
                        }
                        
                        HStack(spacing: 0) {
                            Text("time trial")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .font(screen.size.width > 500 ? .title : .title2)
                                .fontWeight(.bold)
                                .foregroundStyle(Color("pastelPink"))
                            Image(systemName: "timer")
                                .padding(.horizontal, screen.size.width > 500 ? 30 : 20)
                                .font(screen.size.width > 500 ? .title : .title2)
                                .frame(maxHeight: .infinity)
                                .roundedCorner(10, corners: [.topRight, .bottomRight])
                                .background(Color("pastelPink"))
                                .foregroundStyle(.white)
                                .fontWeight(.semibold)
                            
                        }
                        .frame(maxWidth: .infinity)
                        .frame(width: modeIndex != 4 ? screen.size.width * 0.7 : screen.size.width * 0.95, height: screen.size.height < 750 ? 70 : height)
                        .background(.white)
                        .roundedCorner(10, corners: [.topRight, .bottomRight])
                        .shadow(color: modeIndex == 4 ? Color("pastelPink") : Color.black.opacity(0.2), radius: modeIndex == 4 ? 8 : 3)
                        .onTapGesture {
                            modeIndex = 4
                        }
                        .animation(.spring(duration: 0.3, bounce: 0.6), value: modeIndex)
                    }
                                                            
                    HStack {
                        Button(action: {}, label: {
                            HStack {
                                Text("next")
                                
                                Image(systemName: "arrow.right")
                            }
                            .font(.title2)
                            .foregroundStyle(Color("darkPurple"))
                            .fontWeight(.heavy)
                        })
                        .padding(15)
                        .frame(maxWidth: .infinity)
                        .raisedButton(impactStrength: .heavy, cornerRadius: 20, backgroundColor: Color("lighterPurple"), shadowColor: Color("lightPurple"), shadowOffset: 11,
                                      action: {
                            game.setMode(modeIndex: modeIndex)
                            appModel.path.append(AppState.SETTINGS)
                        })
                        .opacity(modeIndex == -1 ? 0.5 : 1)
                        .disabled(modeIndex == -1)

                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                } //: VStack
                .padding(.top, 20)
                
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
            
        }
    } // body
}


#Preview {
    HomeView()
        .environmentObject(AuthInfoModel())
        .environmentObject(AppModel(path: NavigationPath()))
        .environmentObject(GameModel())
}
