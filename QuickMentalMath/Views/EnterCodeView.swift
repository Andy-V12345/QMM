//
//  EnterCodeView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/28/25.
//

import SwiftUI

struct EnterCodeView: View {
    @EnvironmentObject var device: DeviceModel
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var authInfo: AuthInfoModel
    @EnvironmentObject var networkMonitor: NetworkMonitor

    @Environment(\.dismiss) var dismiss
    
    @State var lobbyCode: String = ""
    @State var isLoading = false
    @State var error: String? = nil
    
    @FocusState var isFocused: Bool
    
    var isJoinDisabled: Bool {
        return lobbyCode.count < 6
    }
    
    func handleJoinLobby() {
        isFocused = false
        
        guard let user = authInfo.user else { return }

        // Clear previous error and show loading
        error = nil
        isLoading = true

        Task {
            let result = await MultiplayerService.joinLobby(
                code: lobbyCode.uppercased(),
                userId: user.id,
                username: user.username,
                jwtToken: user.jwtToken
            )

            await MainActor.run {
                switch result {
                case .success(let lobbyResponse):
                    // Successfully joined lobby - navigate to LobbyView
                    appModel.path.append(lobbyResponse)
                    dismiss()

                case .failure(let joinError):
                    let nsError = joinError as NSError
                    if nsError.code == 404 {
                        error = "lobby not found or already started"
                    } else if nsError.code == 409 {
                        error = "lobby is full"
                    } else if nsError.code == 400 {
                        error = "already in this lobby"
                    } else if nsError.code == 500 {
                        error = "server error - please try again"
                    } else if nsError.code == 503 {
                        error = "service unavailable - please try again"
                    } else {
                        error = "failed to join lobby"
                    }
                    isLoading = false
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Text("enter lobby code")
                    .font(device.valueByDevice(small: .title3, normal: .title3, ipad: .title))
                    .foregroundStyle(Color("darkPurple"))
                    .fontWeight(.heavy)
                
                TextField("6-digit code", text: $lobbyCode, prompt: Text("ABCDEF").foregroundStyle(Color("lightGray")))
                    .focused($isFocused)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .padding(.vertical, 15)
                    .font(Font.system(size: 50))
                    .tracking(8)
                    .fontWeight(.medium)
                    .foregroundStyle(Color("lightPurple"))
                    .multilineTextAlignment(.center)
                    .onChange(of: lobbyCode, { _, newVal in
                        if newVal.count > 6 {
                            lobbyCode = String(newVal.prefix(6))
                        }
                    })
                
                Spacer()
                
                VStack(spacing: device.valueByDevice(small: 35, normal: 35, ipad: 40)) {
                    
                    VStack(spacing: 15) {
                        if let errorMsg = error {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                
                                Text(errorMsg)
                                    .fontWeight(.bold)
                            }
                            .font(device.valueByDevice(small: .subheadline, normal: .subheadline, ipad: .body))
                            .foregroundStyle(Color.white)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .raisedButton(cornerRadius: 12, backgroundColor: Color("errorRed"), shadowColor: Color("darkErrorRed"), shadowOffset: 2, action: {})
                        }
                        
                        Button(action: {}, label: {
                            Text("join lobby")
                                .foregroundStyle(Color("darkPurple"))
                                .font(device.valueByDevice(small: .title2, normal: .title2, ipad: .title))
                                .fontWeight(.heavy)
                                .opacity(isJoinDisabled ? 0.5 : 1)
                        })
                        .padding(device.valueByDevice(small: 12, normal: 15, ipad: 15))
                        .frame(maxWidth: .infinity)
                        .raisedButton(impactStrength: .heavy, cornerRadius: device.valueByDevice(small: 18, normal: 20, ipad: 20), backgroundColor: Color("lighterPurple"), shadowColor: Color("lightPurple"), shadowOffset: device.valueByDevice(small: 8, normal: 8, ipad: 12),
                                      action: {
                            handleJoinLobby()
                        })
                        .disabled(isJoinDisabled)
                        //: Join lobby button
                    }
                    
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text("cancel")
                            .foregroundStyle(Color("darkPurple"))
                    })
                    .font(device.valueByDevice(small: .headline, normal: .headline, ipad: .title3))
                    .fontWeight(.heavy)
                }
            }
            .padding(device.valueByDevice(small: 15, normal: 20, ipad: 30))
            
            if isLoading {
                VStack(spacing: 20) {
                    Spacer()
                    
                    BouncingDotsLoader(dotSize: 10, spacing: 7)
                    
                    Text("joining lobby...")
                        .fontWeight(.bold)
                        .foregroundStyle(Color("darkPurple"))
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.8))
            }

        }
        .onTapGesture {
            isFocused = false
        }
        .onAppear {
            isFocused = true
        }
    }
}

#Preview {
    GeometryReader { screen in
        EnterCodeView()
            .environmentObject(DeviceModel(screen: screen))
            .environmentObject(AppModel(path: NavigationPath()))
    }
}
