//
//  StatsView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 7/14/24.
//

import SwiftUI
import EasySkeleton

struct StatsView: View {

    @Environment(\.dismiss) var dismiss

    @State var accuracy: Double = 0

    @EnvironmentObject var authInfo: AuthInfoModel
    @EnvironmentObject var device: DeviceModel
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var networkMonitor: NetworkMonitor

    @State var additionPercent: Double = 0
    @State var subtractionPercent: Double = 0
    @State var multiplicationPercent: Double = 0
    @State var divisionPercent: Double = 0

    // Local stats state
    @State private var userStats: UserStats?
    @State private var isLoadingStats: Bool = true
    @State private var isError: Bool = false
    
    @AppStorage("authState") var authState: AuthState = .UNAUTHORIZED
    @AppStorage("jwtToken") var jwtToken = ""
    @AppStorage("username") var username = ""
    @AppStorage("id") var id = 0

    private func fetchUserStats() async {
        guard let user = authInfo.user else { return }

        do {
            if let stats = try await AuthService.loadUserStats(userId: user.id, jwtToken: user.jwtToken) {
                await MainActor.run {
                    userStats = stats
                    isLoadingStats = false
                    
                    // Calculate percentages
                    additionPercent = stats.additionTot == 0 ? 0 : Double(stats.additionScore) / Double(stats.additionTot)
                    subtractionPercent = stats.subtractionTot == 0 ? 0 : Double(stats.subtractionScore) / Double(stats.subtractionTot)
                    multiplicationPercent = stats.multiplicationTot == 0 ? 0 : Double(stats.multiplicationScore) / Double(stats.multiplicationTot)
                    divisionPercent = stats.divisionTot == 0 ? 0 : Double(stats.divisionScore) / Double(stats.divisionTot)
                }
            } else {
                await MainActor.run {
                    isLoadingStats = false
                    isError = true
                }
            }
        }
        catch {
            isLoadingStats = false
            isError = true
        }
    }

    var body: some View {
        GeometryReader { screen in
            ZStack {
                Color.white.ignoresSafeArea()

                // Check if connected to wifi
                if !networkMonitor.isConnected {
                    VStack(spacing: 25) {
                        HStack {
                            Text("your stats")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(Color("darkPurple"))
                                .font(.largeTitle)
                                .bold()

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
                    .padding([.top, .horizontal], device.valueByDevice(small: 15, normal: 20, ipad: 30))
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
                                        dismiss()
                                        appModel.path.removeLast()
                                    }
                                )
                        })
                    }
                } else {
                    VStack(spacing: 25) {
                        HStack {
                            Text("your stats")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(Color("darkPurple"))
                                .font(.largeTitle)
                                .bold()

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
                        
                        if !isError {
                            ScrollView {
                                VStack(spacing: 25) {
                                    VStack(alignment: .leading, spacing: 15) {
                                        Text("one vs one")
                                            .fontWeight(.heavy)
                                            .foregroundStyle(Color("lightPurple"))

                                        HStack(spacing: device.valueByDevice(small: 8, normal: 8, ipad: 12)) {
                                            VStack(spacing: 5) {
                                                Text("wins")
                                                    .foregroundStyle(Color("correctGreen"))
                                                    .fontWeight(.bold)
                                                    .font(device.valueByDevice(small: .headline, normal: .headline, ipad: .title3))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .skeletonable()

                                                Text("\(userStats?.wins ?? 0)")
                                                    .foregroundStyle(Color("darkPurple"))
                                                    .fontWeight(.heavy)
                                                    .font(device.valueByDevice(small: .title2, normal: .title2, ipad: .title))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .lineLimit(1)
                                                    .skeletonable()
                                            }
                                            .padding(.horizontal, device.valueByDevice(small: 12, normal: 15, ipad: 20))
                                            .padding(.vertical, device.valueByDevice(small: 10, normal: 12, ipad: 17))
                                            .frame(maxWidth: .infinity)
                                            .raisedButton(cornerRadius: 15, backgroundColor: Color("offWhite"), shadowColor: Color.gray.opacity(0.4), shadowOffset: device.valueByDevice(small: 5, normal: 5, ipad: 8), action: {})
                                            .setSkeleton(
                                                $isLoadingStats,
                                                animationType: .gradient([
                                                    Color("correctGreen").opacity(0.3),
                                                    Color("correctGreen").opacity(0.2),
                                                    Color("correctGreen").opacity(0.3)
                                                ]),
                                                animation: Animation.linear(duration: 0.2).repeatForever(autoreverses: false),
                                                cornerRadius: 8
                                            )

                                            VStack(spacing: 5) {
                                                Text("losses")
                                                    .foregroundStyle(Color("errorRed"))
                                                    .fontWeight(.bold)
                                                    .font(device.valueByDevice(small: .headline, normal: .headline, ipad: .title3))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .skeletonable()

                                                Text("\(userStats?.losses ?? 0)")
                                                    .foregroundStyle(Color("darkPurple"))
                                                    .fontWeight(.heavy)
                                                    .font(device.valueByDevice(small: .title2, normal: .title2, ipad: .title))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .lineLimit(1)
                                                    .skeletonable()
                                            }
                                            .padding(.horizontal, device.valueByDevice(small: 12, normal: 15, ipad: 20))
                                            .padding(.vertical, device.valueByDevice(small: 10, normal: 12, ipad: 17))
                                            .frame(maxWidth: .infinity)
                                            .raisedButton(cornerRadius: 15, backgroundColor: Color("offWhite"), shadowColor: Color.gray.opacity(0.4), shadowOffset: device.valueByDevice(small: 5, normal: 5, ipad: 8), action: {})
                                            .setSkeleton(
                                                $isLoadingStats,
                                                animationType: .gradient([
                                                    Color("errorRed").opacity(0.3),
                                                    Color("errorRed").opacity(0.2),
                                                    Color("errorRed").opacity(0.3)
                                                ]),
                                                animation: Animation.linear(duration: 0.2).repeatForever(autoreverses: false),
                                                cornerRadius: 8
                                            )

                                            VStack(spacing: 5) {
                                                Text("best")
                                                    .foregroundStyle(Color("lightPurple"))
                                                    .fontWeight(.bold)
                                                    .font(device.valueByDevice(small: .headline, normal: .headline, ipad: .title3))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .skeletonable()

                                                Text(userStats?.bestTime != nil ? String(format: "%.1fs", Double(userStats!.bestTime!) / 10.0) : "--")
                                                    .foregroundStyle(Color("darkPurple"))
                                                    .fontWeight(.heavy)
                                                    .font(device.valueByDevice(small: .title2, normal: .title2, ipad: .title))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .lineLimit(1)
                                                    .skeletonable()
                                            }
                                            .padding(.horizontal, device.valueByDevice(small: 12, normal: 15, ipad: 20))
                                            .padding(.vertical, device.valueByDevice(small: 10, normal: 12, ipad: 17))
                                            .frame(maxWidth: .infinity)
                                            .raisedButton(cornerRadius: 15, backgroundColor: Color("offWhite"), shadowColor: Color.gray.opacity(0.4), shadowOffset: device.valueByDevice(small: 5, normal: 5, ipad: 8), action: {})
                                            .setSkeleton(
                                                $isLoadingStats,
                                                animationType: .gradient([
                                                    Color("lightPurple").opacity(0.3),
                                                    Color("lightPurple").opacity(0.2),
                                                    Color("lightPurple").opacity(0.3)
                                                ]),
                                                animation: Animation.linear(duration: 0.2).repeatForever(autoreverses: false),
                                                cornerRadius: 8
                                            )
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 15) {
                                        Text("high scores")
                                            .fontWeight(.heavy)
                                            .foregroundStyle(Color("lightPurple"))

                                        VStack(spacing: 20) {
                                            StatPanel(imageName: "bolt.fill", imageColor: Color("gold"), value: String(userStats?.highScore ?? 0), label: "high score", borderColor: Color("gold"), progress: nil, isLoading: $isLoadingStats)

                                            StatPanel(imageName: "timer", imageColor: Color("correctGreen"), value: String(userStats?.ttHighScore ?? 0), label: "time trial best", borderColor: Color("correctGreen"), progress: nil, isLoading: $isLoadingStats)
                                        }
                                    }

                                    VStack(alignment: .leading, spacing: 15) {
                                        Text("by section")
                                            .fontWeight(.heavy)
                                            .foregroundStyle(Color("lightPurple"))
                                        
                                        VStack(spacing: 20) {
                                            StatPanel(imageName: "plus.circle.fill", imageColor: Color("pastelPurple"), value: "\(Int(additionPercent * 100))%", altValue: "\(userStats?.additionScore ?? 0) / \(userStats?.additionTot ?? 0)", label: "addition", borderColor: Color("pastelPurple"), progress: additionPercent, isLoading: $isLoadingStats)
                                            
                                            StatPanel(imageName: "minus.circle.fill", imageColor: Color("pastelBlue"), value: "\(Int(subtractionPercent * 100))%", altValue: "\(userStats?.subtractionScore ?? 0) / \(userStats?.subtractionTot ?? 0)", label: "subtraction", borderColor: Color("pastelBlue"), progress: subtractionPercent, isLoading: $isLoadingStats)
                                            
                                            StatPanel(imageName: "multiply.circle.fill", imageColor: Color("pastelRed"), value: "\(Int(multiplicationPercent * 100))%", altValue: "\(userStats?.multiplicationScore ?? 0) / \(userStats?.multiplicationTot ?? 0)", label: "multiplication", borderColor: Color("pastelRed"), progress: multiplicationPercent, isLoading: $isLoadingStats)
                                            
                                            StatPanel(imageName: "divide.circle.fill", imageColor: Color("pastelGreen"), value: "\(Int(divisionPercent * 100))%", altValue: "\(userStats?.divisionScore ?? 0) / \(userStats?.divisionTot ?? 0)", label: "division", borderColor: Color("pastelGreen"), progress: divisionPercent, isLoading: $isLoadingStats)
                                        }
                                    }
                                }
                                .padding(.bottom, 20)
                            } //: ScrollView
                            .scrollIndicators(.hidden)
                        }
                        else {
                            Spacer()
                            
                            VStack(spacing: 15) {
                                Text("failed to load stats")
                                    .foregroundStyle(Color("errorRed"))
                                    .fontWeight(.semibold)
                                    .font(device.valueByDevice(small: .body, normal: .body, ipad: .title2))
                                
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
                                                isLoadingStats = true
                                                isError = false
                                                Task {
                                                    await fetchUserStats()
                                                }
                                            }
                                        )
                                })
                            }
                        }
                        
                        Spacer()
                    } //: Parent VStack
                    .padding([.top, .horizontal], device.valueByDevice(small: 15, normal: 20, ipad: 30))
                }
            } //: ZStack
            .onAppear {
                Task {
                    await fetchUserStats()
                }
            }
        }
        .dynamicTypeSize(.large ... .xxLarge)
    }
}

// Preview wrapper to show error state
private struct StatsViewErrorPreview: View {
    @State private var isError = true

    var body: some View {
        GeometryReader { screen in
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 25) {
                    HStack {
                        Text("your stats")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color("darkPurple"))
                            .font(.largeTitle)
                            .bold()

                        Spacer()

                        Button(action: {}, label: {
                            Image(systemName: "chevron.down")
                                .font(.title3)
                                .bold()
                                .foregroundStyle(Color("darkPurple"))
                        })
                    }

                    Spacer()

                    if isError {
                        VStack(spacing: 15) {
                            Text("failed to load stats")
                                .foregroundStyle(Color("errorRed"))
                                .fontWeight(.semibold)
                                .font(.body)

                            Button(action: {}, label: {
                                Text("retry")
                                    .foregroundStyle(Color("offWhite"))
                                    .font(.body)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .raisedButton(
                                        cornerRadius: 12,
                                        backgroundColor: Color("errorRed"),
                                        shadowColor: Color("darkErrorRed"),
                                        shadowOffset: 3,
                                        action: {
                                            isError = false
                                        }
                                    )
                            })
                        }
                    }

                    Spacer()
                }
                .padding([.top, .horizontal], 15)
            }
            .environmentObject(DeviceModel(screen: screen))
        }
    }
}

#Preview("Error State") {
    StatsViewErrorPreview()
}

#Preview("Not Signed In") {
    GeometryReader { screen in
        StatsView()
            .environmentObject(AuthInfoModel()) // No user, so will show sign-in error
            .environmentObject(DeviceModel(screen: screen))
            .environmentObject(AppModel(path: NavigationPath()))
    }
}

#Preview("Normal State") {
    let userStats = UserStats(id: 0, additionScore: 20, additionTot: 40, subtractionScore: 10, subtractionTot: 30, multiplicationScore: 0, multiplicationTot: 0, divisionScore: 10, divisionTot: 50, highScore: 45, ttHighScore: 100, wins: 5, losses: 3, bestTime: 247)

    let user = User(id: 0, username: "Andyv123", jwtToken: "dfafdsaf", stats: userStats)

    return (
        GeometryReader { screen in
            StatsView()
                .environmentObject(AuthInfoModel(user: user))
                .environmentObject(DeviceModel(screen: screen))
                .environmentObject(AppModel(path: NavigationPath()))
                .environmentObject(NetworkMonitor())
            
        }
    )
}
