//
//  SideBar.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 7/11/24.
//

import SwiftUI

struct SideBar: View {
    @Binding var isViewingProfile: Bool
    
    var sideBarWidth = UIScreen.main.bounds.size.width * 0.8
    
    @State var isDeleteAlert = false
    @State var deleteError = false
    @State var errorMsg = ""
    @State var errorTitle = ""
    @State var isLoading = false
    
    @State var usernameText = ""
    
    @State var displayStats = false
    @State var displayLeaderboard = false
    
    @EnvironmentObject var authInfo: AuthInfo
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
                            Text("Your Profile")
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
                            Button(action: {
                                displayStats = true
                            }, label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "rosette")
                                        .font(.title3)
                                    
                                    Text("Your stats")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            })
                            
                            Button(action: {
                                displayLeaderboard = true
                            }, label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "medal")
                                        .font(.title3)
                                    
                                    Text("Time trial leaderboard")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            })
                            
                            Button(action: {
                                authInfo.user = nil
                                authInfo.authState = .UNAUTHORIZED
                                jwtToken = ""
                                username = ""
                                id = 0
                                authState = authInfo.authState
                                appModel.path.removeLast()
                            }, label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "figure.walk.departure")
                                        .font(.title3)
                                    
                                    Text("Sign out")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            })
                        } //: Button VStack
                        .foregroundStyle(.white)
                        .font(.headline)
                        .bold()
                        
                        Spacer()
                        
                        Button(action: {
                            isDeleteAlert = true
                        }, label: {
                            Text("Delete Account")
                                .frame(maxWidth: .infinity)
                                .fontWeight(.semibold)
                                .padding()
                                .foregroundStyle(.red)
                                .background(RoundedRectangle(cornerRadius: 15).fill(.white))
                            
                        })
                    } //: VStack
                    .padding(.top, 80)
                    .padding(.bottom, 40)
                    .padding(.horizontal, 25)
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
        .sheet(isPresented: $displayStats, content: {
            StatsView()
        })
        .fullScreenCover(isPresented: $displayLeaderboard, content: {
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
                // TODO: DELETE ACCOUNT
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
