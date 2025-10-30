//
//  CustomLobbyInfoView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/28/25.
//

import SwiftUI

struct CustomLobbyInfoView: View {
    @EnvironmentObject var device: DeviceModel
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var authInfo: AuthInfoModel
    @EnvironmentObject var networkMonitor: NetworkMonitor

    // State for future functionality
    @State private var showingCreateLobby = false
    @State private var showingJoinLobby = false
    @State private var lobbyCode: String = ""

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            if !networkMonitor.isConnected {
                // Network error view
                VStack(spacing: device.valueByDevice(small: 35, normal: 35, ipad: 40)) {
                    Spacer()

                    Text("not connected to wifi")
                        .foregroundStyle(Color("errorRed"))
                        .fontWeight(.semibold)
                        .font(device.valueByDevice(small: .body, normal: .body, ipad: .title2))
                        .multilineTextAlignment(.center)

                    Spacer()

                    Button(action: {
                        appModel.path.removeLast()
                    }, label: {
                        Text("back to home")
                            .foregroundStyle(Color("darkPurple"))
                    })
                    .font(device.valueByDevice(small: .headline, normal: .headline, ipad: .title3))
                    .fontWeight(.heavy)
                }
                .padding(device.valueByDevice(small: 15, normal: 20, ipad: 30))
            } else if authInfo.user == nil {
                // Sign-in prompt
                SignInNeededView()

            } else {
                // Main content
                VStack(spacing: device.valueByDevice(small: 30, normal: 40, ipad: 60)) {
                    // Header section
                    VStack(spacing: 0) {
                        Text("welcome to")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color("darkPurple"))
                            .font(device.valueByDevice(small: .title2, normal: .title2, ipad: .title))
                            .fontWeight(.bold)

                        HStack(spacing: 15) {
                            Text("custom lobbies")
                                .fontWeight(.heavy)
                            
                            Image(systemName: "arcade.stick")
                                .font(device.valueByDevice(small: .title, normal: .largeTitle, ipad: .largeTitle))
                                .bold()
                            
                            Spacer()
                        }
                        .font(device.valueByDevice(small: .title, normal: .largeTitle, ipad: .largeTitle))
                        .foregroundStyle(Color("lightPurple"))


                        
                        Text("create or join a private lobby to play with your friends")
                            .font(device.valueByDevice(small: .body, normal: .body, ipad: .title3))
                            .fontWeight(.semibold)
                            .foregroundStyle(Color("darkPastelGray"))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 5)
                    }

                    VStack(spacing: device.valueByDevice(small: 25, normal: 30, ipad: 40)) {
                        

                        // Mode cards
                        VStack(spacing: device.valueByDevice(small: 20, normal: 20, ipad: 25)) {
                            // Create Lobby Card
                            ModeCard(
                                title: "create lobby",
                                iconName: "person.line.dotted.person.fill",
                                backgroundColor: Color("pastelGreen"),
                                shadowColor: Color("darkPastelGreen"),
                                action: {
                                    showingCreateLobby = true
                                }
                            )

                            // Join Lobby Card
                            ModeCard(
                                title: "join lobby",
                                iconName: "number.square.fill",
                                backgroundColor: Color("pastelBlue"),
                                shadowColor: Color("darkPastelBlue"),
                                action: {
                                    showingJoinLobby = true
                                }
                            )
                        }
                    }

                    Spacer()

                    // Bottom actions
                    VStack(spacing: 35) {
                        Button(action: {
                            appModel.path.removeLast()
                        }) {
                            Text("back to home")
                                .foregroundStyle(Color("darkPurple"))
                                .font(.headline)
                                .fontWeight(.heavy)
                        }
                    }
                }
                .padding(device.valueByDevice(small: 15, normal: 20, ipad: 30))
            }
        } //: ZStack
        .fullScreenCover(isPresented: $showingJoinLobby, content: {
            EnterCodeView()
        })
        .fullScreenCover(isPresented: $showingCreateLobby, content: {
            CreatingLobbyView()
        })
    }
}

#Preview {
    GeometryReader { screen in
        CustomLobbyInfoView()
            .environmentObject(DeviceModel(screen: screen))
            .environmentObject(AppModel(path: NavigationPath()))
            .environmentObject(AuthInfoModel(user: User(id: 123, username: "andy.v", jwtToken: "123dkfja")))
            .environmentObject(NetworkMonitor())
    }
}
