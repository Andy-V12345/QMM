//
//  MultiplayerEndGameView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/22/25.
//

import SwiftUI

struct MultiplayerEndGameView: View {
    
    @EnvironmentObject var device: DeviceModel
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var authInfo: AuthInfoModel
    
    let isWinner = true
    let isNewBestTime = true
    let endGameModel: MultiplayerEndGameModel
    
    init(endGameModel: MultiplayerEndGameModel) {
        self.endGameModel = endGameModel
    }
        
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: device.valueByDevice(small: 20, normal: 20, ipad: 30)) {
                
                Text(isWinner ? "winner winner, chicken dinner" : "you need some more practice")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.largeTitle)
                    .foregroundStyle(Color("darkPurple"))
                    .bold()
                
                VStack(spacing: device.valueByDevice(small: 30, normal: 30, ipad: 40)) {
                    VStack(spacing: device.valueByDevice(small: 10, normal: 10, ipad: 15)) {
                        Text("updated stats")
                            .foregroundStyle(Color("lightPurple"))
                            .font(device.valueByDevice(small: .body, normal: .body, ipad: .title2))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fontWeight(.bold)
                        
                        HStack(spacing: device.valueByDevice(small: 8, normal: 12, ipad: 12)) {
                            VStack(spacing: 5) {
                                Text("wins")
                                    .foregroundStyle(isWinner ? Color("offWhite") : Color("correctGreen"))
                                    .fontWeight(.bold)
                                    .font(device.valueByDevice(small: .subheadline, normal: .body, ipad: .title2))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("1")
                                    .foregroundStyle(Color("darkPurple"))
                                    .fontWeight(.heavy)
                                    .font(device.valueByDevice(small: .title, normal: .title, ipad: Font.system(size: 45)))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, device.valueByDevice(small: 12, normal: 15, ipad: 20))
                            .padding(.vertical, device.valueByDevice(small: 10, normal: 12, ipad: 17))
                            .frame(maxWidth: .infinity)
                            .raisedButton(cornerRadius: 15, backgroundColor: isWinner ? Color("correctGreen") : Color("offWhite"), shadowColor: isWinner ? Color("darkPastelGreen") : Color.gray.opacity(0.4), shadowOffset: device.valueByDevice(small: 5, normal: 5, ipad: 8), action: {
                                
                            })
                            
                            VStack(spacing: 5) {
                                Text("losses")
                                    .foregroundStyle(!isWinner ? Color("offWhite") : Color("errorRed"))
                                    .fontWeight(.bold)
                                    .font(device.valueByDevice(small: .subheadline, normal: .body, ipad: .title2))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("2")
                                    .foregroundStyle(Color("darkPurple"))
                                    .fontWeight(.heavy)
                                    .font(device.valueByDevice(small: .title, normal: .title, ipad: Font.system(size: 45)))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, device.valueByDevice(small: 12, normal: 15, ipad: 20))
                            .padding(.vertical, device.valueByDevice(small: 10, normal: 12, ipad: 17))
                            .frame(maxWidth: .infinity)
                            .raisedButton(cornerRadius: 15, backgroundColor: !isWinner ? Color("errorRed") : Color("offWhite"), shadowColor: !isWinner ? Color("darkErrorRed") : Color.gray.opacity(0.4), shadowOffset: device.valueByDevice(small: 5, normal: 5, ipad: 8), action: {
                                
                            })
                            
                            VStack(spacing: 5) {
                                Text(isNewBestTime ? "new best" : "best")
                                    .foregroundStyle(isNewBestTime ? Color("offWhite") : Color("lightPurple"))
                                    .fontWeight(.bold)
                                    .font(device.valueByDevice(small: .subheadline, normal: .body, ipad: .title2))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("30s")
                                    .foregroundStyle(Color("darkPurple"))
                                    .fontWeight(.heavy)
                                    .font(device.valueByDevice(small: .title, normal: .title, ipad: Font.system(size: 45)))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, device.valueByDevice(small: 12, normal: 15, ipad: 20))
                            .padding(.vertical, device.valueByDevice(small: 10, normal: 12, ipad: 17))
                            .frame(maxWidth: .infinity)
                            .raisedButton(cornerRadius: 15, backgroundColor: isNewBestTime ? Color("lighterPurple") : Color("offWhite"), shadowColor: isNewBestTime ? Color("lightPurple") : Color.gray.opacity(0.4), shadowOffset: device.valueByDevice(small: 5, normal: 5, ipad: 8), action: {
                                
                            })
                            
                        }
                    }
                    
                    VStack(spacing: device.valueByDevice(small: 10, normal: 10, ipad: 15)) {
                        Text("results")
                            .foregroundStyle(Color("lightPurple"))
                            .font(device.valueByDevice(small: .body, normal: .body, ipad: .title2))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fontWeight(.bold)
                        
                        VStack(spacing: device.valueByDevice(small: 20, normal: 20, ipad: 30)) {
                            HStack(spacing: 20) {
                                Text("1")
                                    .fontWeight(.semibold)
                                
                                Text("andy.v123")
                                    .fontWeight(.heavy)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                Text("30s")
                                    .fontWeight(.heavy)
                            }
                            .padding(device.valueByDevice(small: 20, normal: 20, ipad: 25))
                            .font(device.valueByDevice(small: .title3, normal: .title3, ipad: .title))
                            .foregroundStyle(Color("darkPurple"))
                            .raisedButton(cornerRadius: 20, backgroundColor: Color("lighterPurple"), shadowColor: Color("lightPurple"), shadowOffset: device.valueByDevice(small: 5, normal: 5, ipad: 8), action: {})
                            
                            HStack(spacing: 20) {
                                Text("2")
                                    .fontWeight(.semibold)
                                
                                Text("ping123")
                                    .fontWeight(.heavy)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                Text("32s")
                                    .fontWeight(.heavy)
                            }
                            .padding(device.valueByDevice(small: 20, normal: 20, ipad: 25))
                            .font(device.valueByDevice(small: .title3, normal: .title3, ipad: .title))
                            .foregroundStyle(Color("darkPurple"))
                            .raisedButton(cornerRadius: 20, backgroundColor: Color("offWhite"), shadowColor: Color.gray.opacity(0.4), shadowOffset: device.valueByDevice(small: 5, normal: 5, ipad: 8), action: {})
                        }
                    }
                }
                
                Spacer()
                
                VStack(spacing: device.valueByDevice(small: 35, normal: 35, ipad: 40)) {
                    Button(action: {}, label: {
                        Text("rematch")
                            .foregroundStyle(Color("darkPurple"))
                            .font(device.valueByDevice(small: .title2, normal: .title2, ipad: .title))
                            .fontWeight(.heavy)
                    })
                    .padding(device.valueByDevice(small: 12, normal: 15, ipad: 15))
                    .frame(maxWidth: .infinity)
                    .raisedButton(impactStrength: .heavy, cornerRadius: 20, backgroundColor: Color("lighterPurple"), shadowColor: Color("lightPurple"), shadowOffset: device.valueByDevice(small: 11, normal: 11, ipad: 13),
                                  action: {
                        
                        // TODO: PLAY AGAIN
                    })
                    
                    Button(action: {
                        appModel.path = NavigationPath([AuthState.UNAUTHORIZED, authInfo.authState])
                    }, label: {
                        Text("back to home")
                            .foregroundStyle(Color("darkPurple"))
                    })
                    .font(device.valueByDevice(small: .headline, normal: .headline, ipad: .title3))
                    .fontWeight(.heavy)
                }
                
            }
            .padding(device.valueByDevice(small: 15, normal: 20, ipad: 30))
            
        }
    }
}

#Preview {
    GeometryReader { screen in
        MultiplayerEndGameView(endGameModel: MultiplayerEndGameModel(gameId: "123", players: [GamePlayer(uid: "1", displayName: "andy.v123"), GamePlayer(uid: "2", displayName: "ping")]))
            .environmentObject(DeviceModel(screen: screen))
            .environmentObject(AppModel(path: NavigationPath()))
            .environmentObject(AuthInfoModel())
    }
}
