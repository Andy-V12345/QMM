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
    
    @EnvironmentObject var authInfo: AuthInfo
    
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
                
                VStack(spacing: 25) {
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
                        
                        Text("Time Trial Leaderboard")
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
                    .padding(.horizontal, 20)
                    
                    if viewState == .DEFAULT {
                        
                        VStack(spacing: 20) {
                            
                            HStack(alignment: .bottom) {
                                VStack {
                                    Image("secondPlace")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 80)
                                    
                                    VStack(spacing: 5) {
                                        Text(leaderboard![1].username)
                                            .foregroundStyle(Color("darkPurple"))
                                            .lineLimit(1)
                                        
                                        Text("\(leaderboard![1].ttHighScore)")
                                            .font(.subheadline)
                                            .foregroundStyle(Color("lightPurple"))
                                    }
                                    .bold()
                                    
                                    ZStack {
                                        Rectangle()
                                            .fill(Color("lightPurple"))
                                            .roundedCorner(10, corners: [.topLeft, .topRight])
                                        
                                        VStack {
                                            Text("2nd")
                                                .font(.title3)
                                                .foregroundStyle(.white)
                                                .bold()
                                            
                                            Spacer()
                                        }
                                        .padding(.top, 15)
                                    }
                                    .frame(height: 75)
                                        
                                }
                                .frame(maxWidth: .infinity)
                                
                                VStack {
                                    Image("firstPlace")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 80)
                                    
                                    VStack(spacing: 5) {
                                        Text(leaderboard![0].username)
                                            .foregroundStyle(Color("darkPurple"))
                                            .lineLimit(1)

                                        
                                        Text("\(leaderboard![0].ttHighScore)")
                                            .font(.subheadline)
                                            .foregroundStyle(Color("lightPurple"))
                                    }
                                    .bold()
                                    
                                    ZStack {
                                        Rectangle()
                                            .fill(Color("lightPurple"))
                                            .roundedCorner(10, corners: [.topLeft, .topRight])
                                        
                                        VStack {
                                            Text("1st")
                                                .font(.title3)
                                                .foregroundStyle(.white)
                                                .bold()
                                            
                                            Spacer()
                                        }
                                        .padding(.top, 15)
                                    }
                                    .frame(height: 100)
                                }
                                .frame(maxWidth: .infinity)

                                
                                VStack {
                                    Image("thirdPlace")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 80)
                                    
                                    VStack(spacing: 5) {
                                        Text(leaderboard![2].username)
                                            .foregroundStyle(Color("darkPurple"))
                                            .lineLimit(1)

                                        
                                        Text("\(leaderboard![2].ttHighScore)")
                                            .font(.subheadline)
                                            .foregroundStyle(Color("lightPurple"))
                                    }
                                    .bold()
                                    
                                    ZStack {
                                        Rectangle()
                                            .fill(Color("lightPurple"))
                                            .roundedCorner(10, corners: [.topLeft, .topRight])
                                        
                                        VStack {
                                            Text("3rd")
                                                .font(.title3)
                                                .foregroundStyle(.white)
                                                .bold()
                                            
                                            Spacer()
                                        }
                                        .padding(.top, 15)
                                    }
                                    .frame(height: 75)
                                }
                                .frame(maxWidth: .infinity)

                            }
                            .padding(.horizontal, 20)
                            
                            ScrollView {
                                VStack(spacing: 10) {
                                    ForEach(3..<leaderboard!.count) { i in
                                        LeaderboardEntry(rank: i+1, username: leaderboard![i].username, score: leaderboard![i].ttHighScore)
                                    }
                                }
                                .padding(20)
                            }
                            .scrollIndicators(.hidden)
                        }
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
                                            .stroke(Color("lightPurple"), lineWidth: 3)
                                    )
                            })
                        }
                        .foregroundStyle(Color("lightPurple"))
                        
                        Spacer()
                    }
                }
                .padding(.vertical, 25)
            }
            .onAppear {
                Task {
                    await loadLeaderboard()
                }
            }
        }
    }
}
