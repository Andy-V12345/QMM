//
//  TimeSelectView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 5/14/23.
//

import SwiftUI


struct ExtraOptionsView: View {
    
    @State var progress = 10.0
    var progressString: Binding<String> {
        Binding(
            get: { String(Int(progress)) },
            set: { newValue in
                if let newValueAsDouble = Double(newValue) {
                    self.progress = newValueAsDouble
                }
            }
        )
    }
    
    @State var showGame = false
    
    @State var timeIndex = 0
    @State var difficultyIndex = 0
    
    @EnvironmentObject private var gameModel: GameModel
    @EnvironmentObject private var appModel: AppModel
    @EnvironmentObject private var device: DeviceModel
    
    @Environment(\.presentationMode) var presentationMode
    
    func handleStart() {
        gameModel.setTime(timeIndex: timeIndex)
        gameModel.setDifficulty(difficultyIndex: difficultyIndex)
        gameModel.totQuestions = Int(round(progress))
        
        appModel.path.append(AppState.GAME)
    }
    
    var body: some View {
        ZStack {
            Color.white
                .clipShape(RoundedRectangle(cornerRadius: 30))
            
            VStack(spacing: device.valueByDevice(small: 15, normal: 20, ipad: 30)) {
                VStack(spacing: device.valueByDevice(small: 5, normal: 5, ipad: 10)) {
                    HStack(spacing: device.valueByDevice(small: 20, normal: 20, ipad: 30)) {
                        Button(action: {}, label: {
                            Image(systemName: "minus")
                        })
                        .font(device.valueByDevice(small: .subheadline, normal: .subheadline, ipad: .headline))
                        .foregroundStyle(Color("darkPurple"))
                        .bold()
                        .padding(.horizontal, device.valueByDevice(small: 6, normal: 6, ipad: 10))
                        .frame(height: device.valueByDevice(small: 25, normal: 25, ipad: 32))
                        .raisedButton(impactStrength: .soft, cornerRadius: 10, backgroundColor: Color("lighterPurple"), shadowColor: Color("lightPurple"), shadowOffset: 3, action: {
                            progress -= 1
                        })
                        
                        RollingNumber(number: progressString, color: Color("darkPurple"), font: device.valueByDevice(small: nil, normal: nil, ipad: Font.system(size: 55, weight: .bold)), digitWidth: device.valueByDevice(small: 22, normal: 22, ipad: 35), digitHeight: device.valueByDevice(small: 38, normal: 38, ipad: 75))
                        
                        Button(action: {}, label: {
                            Image(systemName: "plus")
                        })
                        .font(device.valueByDevice(small: .subheadline, normal: .subheadline, ipad: .headline))
                        .foregroundStyle(Color("darkPurple"))
                        .bold()
                        .padding(.horizontal, device.valueByDevice(small: 6, normal: 6, ipad: 10))
                        .frame(height: device.valueByDevice(small: 25, normal: 25, ipad: 32))
                        .raisedButton(impactStrength: .soft, cornerRadius: 10, backgroundColor: Color("lighterPurple"), shadowColor: Color("lightPurple"), shadowOffset: 3, action: {
                            progress += 1
                        })
                    }
                    
                    Slider(value: $progress, in: 10...99)
                        .tint(Color("darkPurple"))
                    
                    Text("number of problems")
                        .font(device.valueByDevice(small: .subheadline, normal: .headline, ipad: .title2))
                        .fontWeight(.heavy)
                        .foregroundStyle(Color("lightPurple"))
                    
                    
                }
                .padding(device.valueByDevice(small: 15, normal: 15, ipad: 20))
                .background(.white)
                .roundedCorner(20, corners: .allCorners)
                .clipped()
                .shadow(radius: 2)
                
                HStack(spacing: device.valueByDevice(small: 15, normal: 20, ipad: 30)) {
                    DifficultySelector(difficultyIndex: $difficultyIndex, isTimeTrial: false)
                    
                    TimeSelector(timeIndex: $timeIndex, isTimeTrial: false)
                }
                
                Spacer()
                
                VStack(spacing: device.valueByDevice(small: 35, normal: 35, ipad: 40)) {
                    Button(action: {}, label: {
                        HStack {
                            Text("start")
                            
                            Image(systemName: "arrow.right")
                        }
                        .foregroundStyle(Color("darkPurple"))
                        .font(device.valueByDevice(small: .title2, normal: .title2, ipad: .title))
                        .fontWeight(.heavy)
                    })
                    .padding(device.valueByDevice(small: 12, normal: 15, ipad: 15))
                    .frame(maxWidth: .infinity)
                    .raisedButton(impactStrength: .heavy, cornerRadius: 20, backgroundColor: Color("lighterPurple"), shadowColor: Color("lightPurple"), shadowOffset: device.valueByDevice(small: 11, normal: 11, ipad: 13),
                                  action: {
                        handleStart()
                    })
                    //: Start Button
                    
                    Button(action: {
                        appModel.path.removeLast()
                    }, label: {
                        Text("back to home")
                            .foregroundStyle(Color("darkPurple"))
                    })
                    .font(device.valueByDevice(small: .headline, normal: .headline, ipad: .title3))
                    .fontWeight(.heavy)
                }
            } //: VStack
            .padding(device.valueByDevice(small: 15, normal: 20, ipad: 30))
            
        } // ZStack
    }
}

#Preview {
    GeometryReader { screen in
        ExtraOptionsView()
            .environmentObject(GameModel())
            .environmentObject(AppModel(path: NavigationPath()))
            .environmentObject(DeviceModel(screen: screen))
    }
}




