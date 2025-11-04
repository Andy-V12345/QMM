//
//  SideBar.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 7/11/24.
//

import SwiftUI

struct SideBar: View {
    @Binding var isViewingProfile: Bool
    
    var sideBarWidth = UIScreen.main.bounds.size.width * 0.85
    
    @State var isDeleteAlert = false
    @State var deleteError = false
    @State var errorMsg = ""
    @State var errorTitle = ""
    @State var isLoading = false

    @State var usernameText = ""

    @EnvironmentObject var authInfo: AuthInfoModel
    @EnvironmentObject var appModel: AppModel
    
    @AppStorage("authState") var authState: AuthState = .NO_ACCOUNT
    @AppStorage("jwtToken") var jwtToken = ""
    @AppStorage("username") var username = ""
    @AppStorage("id") var id = 0
    
    var body: some View {
        ZStack {
            GeometryReader { _ in
                EmptyView()
            }
            .background(.black.opacity(0.6))
            .opacity(isViewingProfile ? 1 : 0)
            .animation(.easeInOut.delay(0.2), value: isViewingProfile)
            .onTapGesture {
                isViewingProfile.toggle()
            }
            
            HStack(alignment: .top) {
                ZStack(alignment: .top) {
                    Color("darkPurple")
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color("darkPurple"))
                            .frame(width: 60, height: 60)
                            .rotationEffect(Angle(degrees: 45))
                            .offset(x: isViewingProfile ? -18 : -40)
                            .onTapGesture {
                                isViewingProfile.toggle()
                            }
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                            .rotationEffect(Angle(degrees: 180))
                            .offset(x: isViewingProfile ? -4 : -30)
                    }
                    .offset(x: sideBarWidth / 2, y: 80)
                    .animation(.default, value: isViewingProfile)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        VStack {
                            Text("your profile")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .bold()
                                .font(.title)
                            Text(username)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fontWeight(.semibold)
                        } //: Text VStack
                        
                        Divider()
                            .overlay(.white)
                        
                        VStack(spacing: 25) {
                            Button(action: {}, label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "chart.bar.xaxis")
                                        .font(.title3)
                                        .foregroundStyle(Color("correctGreen"))
                                    
                                    Text("your stats")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(0)
                                }
                            })
                            .padding(.vertical, 8)
                            .padding(.horizontal, 10)
                            .frame(maxWidth: .infinity)
                            .raisedButton(cornerRadius: 20, backgroundColor: Color("offWhite"), shadowColor: Color("lightGray"), shadowOffset: 4, action: {
                                appModel.showStats = true
                            })
                            
                            Button(action: {}, label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "trophy.fill")
                                        .font(.headline)
                                        .foregroundStyle(Color("gold"))
                                    
                                    Text("time trial leaderboard")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(0)
                                }
                            })
                            .padding(.vertical, 8)
                            .padding(.horizontal, 10)
                            .frame(maxWidth: .infinity)
                            .raisedButton(cornerRadius: 20, backgroundColor: Color("offWhite"), shadowColor: Color("lightGray"), shadowOffset: 4, action: {
                                appModel.showLeaderboard = true
                            })
                            
                            Spacer()
                            
                            Button(action: {}, label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "figure.walk.departure")
                                        .font(.headline)
                                        .foregroundStyle(Color("errorRed"))
                                    
                                    Text("sign out")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(0)
                                }
                            })
                            .padding(.vertical, 8)
                            .padding(.horizontal, 10)
                            .frame(maxWidth: .infinity)
                            .raisedButton(cornerRadius: 20, backgroundColor: Color("offWhite"), shadowColor: Color("lightGray"), shadowOffset: 4, action: {
                                authInfo.user = nil
                                authInfo.authState = .UNAUTHORIZED
                                UserDefaults.standard.clearLastGame()
                                jwtToken = ""
                                username = ""
                                id = 0
                                authState = authInfo.authState
                                appModel.path.removeLast()
                            })
                            
                            Button(action: {}, label: {
                                Text("delete account")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                
                            })
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .raisedButton(cornerRadius: 20, backgroundColor: Color("errorRed"), shadowColor: Color("darkErrorRed"), shadowOffset: 5, action: {
                                isDeleteAlert = true
                            })
                        } //: Button VStack
                        .foregroundStyle(Color("darkPurple"))
                        .font(.headline)
                        .bold()
                        
                        
                    } //: VStack
                    .padding(.top, 80)
                    .padding(.bottom, 40)
                    .padding(.horizontal, 20)
                    .foregroundStyle(.white)
                }
                .frame(width: sideBarWidth)
                .offset(x: isViewingProfile ? 0 : -sideBarWidth)
                .animation(.default, value: isViewingProfile)
                
                Spacer()
            }
            
            if isLoading {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                
                LoadingSpinner(size: 25, color: Color("lightPurple"), width: 5)
            }
        }
        .ignoresSafeArea(edges: .all)
        .preferredColorScheme(.light)
        .fullScreenCover(isPresented: $appModel.showStats, content: {
            StatsView()
        })
        .fullScreenCover(isPresented: $appModel.showLeaderboard, content: {
            LeaderboardView()
        })
        .alert(errorTitle, isPresented: $deleteError) {
            Button(role: .cancel) {
                usernameText = ""
            } label: {
                Text("Cancel")
            }
            
            Button(role: .destructive) {
                isDeleteAlert = true
            } label: {
                Text("Try Again")
            }
            
        } message: {
            Text(errorMsg)
        }
        .alert("Are You Sure?", isPresented: $isDeleteAlert) {
            Button(role: .destructive) {
                if usernameText.trimmingCharacters(in: .whitespacesAndNewlines) != "" && usernameText == authInfo.user?.username {
                    isLoading = true
                    
                    Task {
                        let result = await authInfo.deleteAccount()
                        
                        isLoading = false
                        
                        if result {
                            authInfo.user = nil
                            authInfo.authState = .UNAUTHORIZED
                            jwtToken = ""
                            username = ""
                            id = 0
                            authState = authInfo.authState
                            appModel.path.removeLast()
                        }
                        else {
                            errorTitle = "Error"
                            errorMsg = "Something went wrong! Please try again."
                            deleteError = true
                        }
                    }
                }
                else {
                    errorTitle = "Error"
                    errorMsg = "The username you entered is not valid."
                    deleteError = true
                }
            } label: {
                Text("Delete")
            }
            .disabled(usernameText.trimmingCharacters(in: .whitespacesAndNewlines) == "")
            .opacity(usernameText.trimmingCharacters(in: .whitespacesAndNewlines) == "" ? 0.4 : 1)
            
            Button(role: .cancel) {
                
            } label: {
                Text("Cancel")
            }
            
            TextField("Enter your username", text: $usernameText)
                .font(.subheadline)
            
        } message: {
            
            Text("This will permanently delete your account and all of your data! Please enter your username to confirm the deletion of your account.")
            
        }
        
    }
}
