//
//  TimeSelectView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 5/14/23.
//

import SwiftUI


struct ExtraOptionsView: View {
    
    @State var numQuestions: Double
    var numQuestionsString: Binding<String> {
        Binding(
            get: { String(Int(numQuestions)) },
            set: { newValue in
                if let newValueAsDouble = Double(newValue) {
                    self.numQuestions = newValueAsDouble
                }
            }
        )
    }
    
    @State var timeLimit: TimeLimit
    @State var difficulty: GameDifficulty
    @State var mode: GameMode
    
    @EnvironmentObject private var appModel: AppModel
    @EnvironmentObject private var device: DeviceModel
    
    @Environment(\.presentationMode) var presentationMode
    
    init(gameConfigsModel: GameConfigsModel) {
        self.timeLimit = gameConfigsModel.timeLimit
        self.difficulty = gameConfigsModel.difficulty
        self.mode = gameConfigsModel.mode
        self.numQuestions = Double(gameConfigsModel.numQuestions)
    }
    
    func handleStart() {
        let configs = GameConfigsModel(mode: self.mode, difficulty: self.difficulty, timeLimit: self.timeLimit, numQuestions: Int(self.numQuestions))
        
        appModel.path.append(
            GameModel(gameConfigs: configs)
        )
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
                            if numQuestions > 10 {
                                numQuestions -= 1
                            }
                        })
                        .disabled(numQuestions == 10)
                        .opacity(numQuestions == 10 ? 0.3 : 1)
                        
                        RollingNumber(number: numQuestionsString, color: Color("darkPurple"), font: device.valueByDevice(small: nil, normal: nil, ipad: Font.system(size: 55, weight: .bold)), digitWidth: device.valueByDevice(small: 22, normal: 22, ipad: 35), digitHeight: device.valueByDevice(small: 40, normal: 40, ipad: 75))
                        
                        Button(action: {}, label: {
                            Image(systemName: "plus")
                        })
                        .font(device.valueByDevice(small: .subheadline, normal: .subheadline, ipad: .headline))
                        .foregroundStyle(Color("darkPurple"))
                        .bold()
                        .padding(.horizontal, device.valueByDevice(small: 6, normal: 6, ipad: 10))
                        .frame(height: device.valueByDevice(small: 25, normal: 25, ipad: 32))
                        .raisedButton(impactStrength: .soft, cornerRadius: 10, backgroundColor: Color("lighterPurple"), shadowColor: Color("lightPurple"), shadowOffset: 3, action: {
                            if numQuestions < 99 {
                                numQuestions += 1
                            }
                        })
                        .disabled(numQuestions == 99)
                        .opacity(numQuestions == 99 ? 0.3 : 1)
                    }
                    
                    Slider(value: $numQuestions, in: 10...99)
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
                .onChange(of: numQuestions) { _ in
                    HapticManager.shared.trigger(.soft)
                }
                
                HStack(spacing: device.valueByDevice(small: 15, normal: 20, ipad: 30)) {
                    DifficultySelector(difficulty: $difficulty, isTimeTrial: false)
                    
                    TimeSelector(timeLimit: $timeLimit, isTimeTrial: false)
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

//#Preview {
//    GeometryReader { screen in
//        ExtraOptionsView()
//            .environmentObject(GameModel())
//            .environmentObject(AppModel(path: NavigationPath()))
//            .environmentObject(DeviceModel(screen: screen))
//    }
//}




