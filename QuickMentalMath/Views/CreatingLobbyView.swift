//
//  CreatingLobbyView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/28/25.
//

import SwiftUI

struct CreatingLobbyView: View {
    @EnvironmentObject var device: DeviceModel
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var authInfoModel: AuthInfoModel
    
    @Environment(\.dismiss) var dismiss
    
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var statusText = "creating lobby..."

    private func handleCreateLobby() {
        guard let user = authInfoModel.user else { return }

        Task {
            let result = await MultiplayerService.createLobby(
                userId: user.id,
                username: user.username,
                jwtToken: user.jwtToken
            )

            await MainActor.run {
                switch result {
                case .success(let response):
                    // Successfully created lobby
                    statusText = "lobby created"
                    appModel.path.append(response)
                    dismiss()

                case .failure(let error):
                    // Show error UI
                    print("Error creating lobby: \(error.localizedDescription)")
                    errorMessage = "failed to create lobby"
                    showError = true
                }
            }
        }
    }
    
    private func handleCancel() {
        dismiss()
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            // Check if connected to wifi
            if !networkMonitor.isConnected {
                VStack(spacing: 10) {
                    Spacer()
                    
                    Text("not connected to wifi")
                        .foregroundStyle(Color("errorRed"))
                        .fontWeight(.semibold)
                        .font(device.valueByDevice(small: .body, normal: .body, ipad: .title2))
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                    
                    // Leave queue button
                    Button(action: {}, label: {
                        Text("cancel")
                            .foregroundStyle(Color("offWhite"))
                            .font(device.valueByDevice(small: .body, normal: .body, ipad: .title2))
                            .fontWeight(.bold)
                    })
                    .padding(device.valueByDevice(small: 10, normal: 12, ipad: 14))
                    .frame(maxWidth: .infinity)
                    .raisedButton(
                        impactStrength: .medium,
                        cornerRadius: 20,
                        backgroundColor: Color("errorRed"),
                        shadowColor: Color("darkErrorRed"),
                        shadowOffset: device.valueByDevice(small: 6, normal: 8, ipad: 10),
                        action: {
                            
                        }
                    )
                }
                .padding(device.valueByDevice(small: 15, normal: 20, ipad: 30))
            }
            else {
                VStack(spacing: 10) {
                    Spacer()
                    
                    if !showError {
                        BouncingDotsLoader()
                            .padding(.bottom, 15)
                        
                        // Status text
                        Text(statusText)
                            .font(device.valueByDevice(small: .title2, normal: .title, ipad: .largeTitle))
                            .fontWeight(.heavy)
                            .foregroundStyle(Color("darkPurple"))
                    } else {
                        // Error UI
                        VStack(spacing: 15) {
                            Text(errorMessage)
                                .foregroundStyle(Color("errorRed"))
                                .fontWeight(.semibold)
                                .font(device.valueByDevice(small: .body, normal: .body, ipad: .title2))
                                .multilineTextAlignment(.center)
                            
                            Button(action: {}, label: {
                                Text("retry")
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
                                            // Reset error state and retry
                                            showError = false
                                            errorMessage = ""
                                            statusText = "creating lobby"
                                            
                                            handleCreateLobby()

                                        }
                                    )
                            })
                        }
                    }
                    
                    // Quote
                    
                    
                    Spacer()
                    
                    Button(action: {
                        handleCancel()
                    }, label: {
                        Text("cancel")
                            .foregroundStyle(Color("errorRed"))
                            .font(device.valueByDevice(small: .body, normal: .body, ipad: .title2))
                            .fontWeight(.bold)
                    })
                }
                .padding(device.valueByDevice(small: 15, normal: 20, ipad: 30))
            }
        }
        .onAppear {
            handleCreateLobby()
        }
    }
}

#Preview {
    GeometryReader { screen in
        CreatingLobbyView()
            .environmentObject(NetworkMonitor())
            .environmentObject(AppModel(path: NavigationPath()))
            .environmentObject(DeviceModel(screen: screen))
            .environmentObject(AuthInfoModel(user: User(id: 1, username: "andyv.123", jwtToken: "adflaj")))
    }
}
