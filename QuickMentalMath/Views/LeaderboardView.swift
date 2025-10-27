//
//  LeaderboardView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 7/14/24.
//

import SwiftUI

struct LeaderboardView: View {
    
    @Environment(\.dismiss) var dismiss

    @State var viewState: ViewState = .LOADING

    @EnvironmentObject var authInfo: AuthInfoModel
    @EnvironmentObject var device: DeviceModel
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var networkMonitor: NetworkMonitor

    @State var leaderboard: [LeaderboardResponse]? = []

    @AppStorage("authState") var authState: AuthState = .UNAUTHORIZED
    @AppStorage("jwtToken") var jwtToken = ""
    @AppStorage("username") var username = ""
    @AppStorage("id") var id = 0
    
    func loadLeaderboard() async {
        viewState = .LOADING
        
        leaderboard = await authInfo.getLeaderboard(topN: 50)
        
        if leaderboard == nil {
            viewState = .ERROR
        }
        else {
            viewState = .DEFAULT
        }
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            // Check if connected to wifi
            if !networkMonitor.isConnected {
                VStack(spacing: 20) {
                    HStack {
                        Button(action: {
                            Task {
                                await loadLeaderboard()
                            }
                        }, label: {
                            Image(systemName: "arrow.clockwise")
                                .font(.title3)
                                .bold()
                                .foregroundStyle(Color("darkPurple"))
                        })

                        Spacer()

                        Text("leaderboard")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(Color("darkPurple"))

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

                    Spacer()

                    Text("not connected to wifi")
                        .foregroundStyle(Color("errorRed"))
                        .fontWeight(.semibold)
                        .font(device.valueByDevice(small: .body, normal: .body, ipad: .title2))
                        .multilineTextAlignment(.center)

                    Spacer()
                }
                .padding(device.valueByDevice(small: 15, normal: 20, ipad: 30))
                .dynamicTypeSize(.large ... .xxLarge)
            } else if authInfo.user == nil {
                // Check if user is signed in
                VStack(spacing: 15) {
                    Text("looks like you're not signed in")
                        .foregroundStyle(Color("errorRed"))
                        .fontWeight(.semibold)
                        .font(device.valueByDevice(small: .body, normal: .body, ipad: .title2))

                    Button(action: {}, label: {
                        Text("sign in")
                            .foregroundStyle(Color("offWhite"))
                            .font(device.valueByDevice(small: .body, normal: .body, ipad: .title2))
                            .fontWeight(.bold)
                            .padding(.horizontal, device.valueByDevice(small: 12, normal: 14, ipad: 16))
                            .padding(.vertical, 4)
                            .raisedButton(
                                cornerRadius: 12,
                                backgroundColor: Color("errorRed"),
                                shadowColor: Color("darkErrorRed"),
                                shadowOffset: device.valueByDevice(small: 3, normal: 4, ipad: 6),
                                action: {
                                    authInfo.user = nil
                                    authInfo.authState = .UNAUTHORIZED
                                    jwtToken = ""
                                    username = ""
                                    id = 0
                                    authState = authInfo.authState
                                    appModel.path = NavigationPath([AuthState.UNAUTHORIZED])
                                    dismiss()
                                }
                            )
                    })
                }
            } else {
                VStack(spacing: 20) {
                    HStack {
                        Button(action: {
                            Task {
                                await loadLeaderboard()
                            }
                        }, label: {
                            Image(systemName: "arrow.clockwise")
                                .font(.title3)
                                .bold()
                                .foregroundStyle(Color("darkPurple"))
                        })

                        Spacer()

                        Text("leaderboard")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(Color("darkPurple"))

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

                    if viewState == .DEFAULT {
                        ScrollView {
                            LazyVStack(spacing: 20) {
                                ForEach(0..<leaderboard!.count) { i in
                                    LeaderboardEntry(rank: i+1, username: leaderboard![i].username, score: leaderboard![i].ttHighScore)
                                }
                            }
                            .padding(.bottom, 20)
                        }
                        .scrollIndicators(.hidden)
                    }
                    else if viewState == .LOADING {
                        Spacer()

                        LoadingSpinner(size: 25, color: Color("lightPurple"), width: 5)

                        Spacer()
                    }
                    else {
                        Spacer()

                        VStack(spacing: 15) {
                            Text("Something went wrong!")

                            Button(action: {
                                Task {
                                    await loadLeaderboard()
                                }
                            }, label: {
                                Text("Try Again")
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color("errorRed"), lineWidth: 3)
                                    )
                            })
                        }
                        .foregroundStyle(Color("errorRed"))

                        Spacer()
                    }
                }
                .padding(device.valueByDevice(small: 15, normal: 20, ipad: 30))
                .dynamicTypeSize(.large ... .xxLarge)
            }
        }
        .onAppear {
            if authInfo.user != nil {
                Task {
                    await loadLeaderboard()
                }
            }
        }
    }
}
