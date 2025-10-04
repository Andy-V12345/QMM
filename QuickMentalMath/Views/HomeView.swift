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
    
    let smallHeight: CGFloat = 70
    let normalheight: CGFloat = 80
    let iPadHeight: CGFloat = 100
    
    @State var modeIndex = 0
    
    @State var isProfileView = false
    @State var showNoAccountAlert = false
    
    @EnvironmentObject var authInfo: AuthInfoModel
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var game: GameModel
    @EnvironmentObject var device: DeviceModel
    
    @AppStorage("authState") var authState: AuthState = .UNAUTHORIZED
    @AppStorage("jwtToken") var jwtToken = ""
    @AppStorage("username") var username = ""
    @AppStorage("id") var id = 0
    
    var body: some View {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 0) {
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
                        .padding(.horizontal, device.valueByDevice(small: 15, normal: 20, ipad: 30))
                        
                        VStack(alignment: .leading, spacing: device.valueByDevice(small: 25, normal: 30, ipad: 55)) {
                            HStack(spacing: 0) {
                                Text("addition")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .font(device.valueByDevice(small: .title2, normal: .title2, ipad: .title))
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color("pastelPurple"))
                                Image(systemName: "plus")
                                    .padding(.horizontal, device.valueByDevice(small: 20, normal: 20, ipad: 30))
                                    .font(device.valueByDevice(small: .title2, normal: .title2, ipad: .title))
                                    .frame(maxHeight: .infinity)
                                    .roundedCorner(10, corners: [.topRight, .bottomRight])
                                    .background(Color("pastelPurple"))
                                    .foregroundStyle(.white)
                                    .fontWeight(.semibold)
                                
                            }
                            .frame(maxWidth: .infinity)
                            .frame(width: modeIndex != 0 ? device.screen!.size.width * 0.7 : device.screen!.size.width * 0.95, height: device.valueByDevice(small: smallHeight, normal: normalheight, ipad: iPadHeight))
                            .background(.white)
                            .roundedCorner(10, corners: [.topRight, .bottomRight])
                            .shadow(color: modeIndex == 0 ? Color("pastelPurple") : Color.black.opacity(0.2), radius: modeIndex == 0 ? 8 : 3)
                            .padding(0)
                            .onTapGesture {
                                modeIndex = 0
                            }
                            .animation(.spring(duration: 0.3, bounce: 0.6), value: modeIndex)
                            
                            HStack {
                                Spacer()
                                HStack(spacing: 0) {
                                    Image(systemName: "minus")
                                        .padding(.horizontal, device.valueByDevice(small: 20, normal: 20, ipad: 30))
                                        .font(device.valueByDevice(small: .title2, normal: .title2, ipad: .title))
                                        .frame(maxHeight: .infinity)
                                        .roundedCorner(10, corners: [.topRight, .bottomRight])
                                        .background(Color("pastelBlue"))
                                        .foregroundStyle(.white)
                                        .fontWeight(.semibold)
                                    
                                    Text("subtraction")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .font(device.valueByDevice(small: .title2, normal: .title2, ipad: .title))
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color("pastelBlue"))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(width: modeIndex != 1 ? device.screen!.size.width * 0.7 : device.screen!.size.width * 0.95, height: device.valueByDevice(small: smallHeight, normal: normalheight, ipad: iPadHeight))
                                .background(.white)
                                .roundedCorner(10, corners: [.topLeft, .bottomLeft])
                                .shadow(color: modeIndex == 1 ? Color("pastelBlue") : Color.black.opacity(0.2), radius: modeIndex == 1 ? 8 : 3)
                                .onTapGesture {
                                    modeIndex = 1
                                }
                                .animation(.spring(duration: 0.3, bounce: 0.6), value: modeIndex)
                            }
                            
                            HStack(spacing: 0) {
                                Text("multiplication")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .font(device.valueByDevice(small: .title2, normal: .title2, ipad: .title))
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color("pastelRed"))
                                Image(systemName: "multiply")
                                    .padding(.horizontal, device.valueByDevice(small: 20, normal: 20, ipad: 30))
                                    .font(device.valueByDevice(small: .title2, normal: .title2, ipad: .title))
                                    .frame(maxHeight: .infinity)
                                    .roundedCorner(10, corners: [.topRight, .bottomRight])
                                    .background(Color("pastelRed"))
                                    .foregroundStyle(.white)
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(width: modeIndex != 2 ? device.screen!.size.width * 0.7 : device.screen!.size.width * 0.95, height: device.valueByDevice(small: smallHeight, normal: normalheight, ipad: iPadHeight))
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
                                        .padding(.horizontal, device.valueByDevice(small: 20, normal: 20, ipad: 30))
                                        .font(device.valueByDevice(small: .title2, normal: .title2, ipad: .title))
                                        .frame(maxHeight: .infinity)
                                        .roundedCorner(10, corners: [.topRight, .bottomRight])
                                        .background(Color("pastelGreen"))
                                        .foregroundStyle(.white)
                                        .fontWeight(.semibold)
                                    
                                    Text("division")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .font(device.valueByDevice(small: .title2, normal: .title2, ipad: .title))
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color("pastelGreen"))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(width: modeIndex != 3 ? device.screen!.size.width * 0.7 : device.screen!.size.width * 0.95, height: device.valueByDevice(small: smallHeight, normal: normalheight, ipad: iPadHeight))
                                .background(.white)
                                .roundedCorner(10, corners: [.topLeft, .bottomLeft])
                                .shadow(color: modeIndex == 3 ? Color("pastelGreen") : Color.black.opacity(0.2), radius: modeIndex == 3 ? 8 : 3)
                                .onTapGesture {
                                    modeIndex = 3
                                }
                                .animation(.spring(duration: 0.3, bounce: 0.6), value: modeIndex)
                            }
                            
                            HStack(spacing: 0) {
                                Text("time trial")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .font(device.valueByDevice(small: .title2, normal: .title2, ipad: .title))
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color("pastelPink"))
                                Image(systemName: "timer")
                                    .padding(.horizontal, device.valueByDevice(small: 20, normal: 20, ipad: 30))
                                    .font(device.valueByDevice(small: .title2, normal: .title2, ipad: .title))
                                    .frame(maxHeight: .infinity)
                                    .roundedCorner(10, corners: [.topRight, .bottomRight])
                                    .background(Color("pastelPink"))
                                    .foregroundStyle(.white)
                                    .fontWeight(.semibold)
                                
                            }
                            .frame(maxWidth: .infinity)
                            .frame(width: modeIndex != 4 ? device.screen!.size.width * 0.7 : device.screen!.size.width * 0.95, height: device.valueByDevice(small: smallHeight, normal: normalheight, ipad: iPadHeight))
                            .background(.white)
                            .roundedCorner(10, corners: [.topRight, .bottomRight])
                            .shadow(color: modeIndex == 4 ? Color("pastelPink") : Color.black.opacity(0.2), radius: modeIndex == 4 ? 8 : 3)
                            .onTapGesture {
                                modeIndex = 4
                            }
                            .animation(.spring(duration: 0.3, bounce: 0.6), value: modeIndex)
                        }
                    }
                    
                    Spacer()
                                                        
                    HStack {
                        Button(action: {}, label: {
                            HStack {
                                Text("next")
                                
                                Image(systemName: "arrow.right")
                            }
                            .font(device.valueByDevice(small: .title2, normal: .title2, ipad: .title))
                            .foregroundStyle(Color("darkPurple"))
                            .fontWeight(.heavy)
                        })
                        .padding(device.valueByDevice(small: 12, normal: 15, ipad: 15))
                        .frame(maxWidth: .infinity)
                        .raisedButton(impactStrength: .heavy, cornerRadius: 20, backgroundColor: Color("lighterPurple"), shadowColor: Color("lightPurple"), shadowOffset: device.valueByDevice(small: 11, normal: 11, ipad: 13),
                                      action: {
                            game.setMode(modeIndex: modeIndex)
                            appModel.path.append(AppState.SETTINGS)
                        })
                        .opacity(modeIndex == -1 ? 0.5 : 1)
                        .disabled(modeIndex == -1)

                    }
                    .padding(.horizontal, device.valueByDevice(small: 15, normal: 20, ipad: 30))
                } //: VStack
                .padding(.vertical, device.valueByDevice(small: 15, normal: 20, ipad: 30))
                
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
            .environmentObject(GameModel())
            .environmentObject(DeviceModel(screen: screen))
    }
}
