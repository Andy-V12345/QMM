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
    
    @State var leaderboard: [LeaderboardResponse]? = []
    
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
        GeometryReader { screen in
            ZStack {
                Color.white.ignoresSafeArea()
                
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
                .padding(20)
            }
            .onAppear {
                Task {
                    await loadLeaderboard()
                }
            }
        }
    }
}
