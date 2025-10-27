//
//  StatPanel.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/3/25.
//

import SwiftUI
import EasySkeleton

struct StatPanel: View {

    let imageName: String
    let imageColor: Color
    let value: String
    let altValue: String
    let label: String
    let borderColor: Color
    let progress: Double?
    @Binding var isLoading: Bool
    @State var uiProgress: Double = 0
    @State var showAltValue = false
    
    @EnvironmentObject var device: DeviceModel

    init(imageName: String, imageColor: Color, value: String, altValue: String, label: String, borderColor: Color, progress: Double?, isLoading: Binding<Bool>) {
        self.imageName = imageName
        self.imageColor = imageColor
        self.value = value
        self.altValue = altValue
        self.label = label
        self.borderColor = borderColor
        self.progress = progress
        self._isLoading = isLoading
    }

    init(imageName: String, imageColor: Color, value: String, label: String, borderColor: Color, progress: Double?, isLoading: Binding<Bool>) {
        self.imageName = imageName
        self.imageColor = imageColor
        self.value = value
        self.altValue = value
        self.label = label
        self.borderColor = borderColor
        self.progress = progress
        self._isLoading = isLoading
    }
    
    
    var body: some View {
        HStack(alignment: .top, spacing: device.valueByDevice(small: 10, normal: 10, ipad: 15)) {
            Image(systemName: imageName)
                .foregroundStyle(imageColor)
                .font(device.valueByDevice(small: .title2, normal: .title2, ipad: .title))
                .bold()
                .skeletonable()
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(showAltValue ? altValue : value)")
                        .foregroundStyle(Color("darkPurple"))
                        .font(device.valueByDevice(small: .title2, normal: .title2, ipad: .title))
                        .fontWeight(.heavy)
                        .lineLimit(1)
                        .skeletonable()
                    
                    Text("\(label)")
                        .foregroundStyle(borderColor)
                        .fontWeight(.bold)
                        .font(device.valueByDevice(small: .headline, normal: .headline, ipad: .title3))
                        .skeletonable()
                }
                
                Spacer()
                
                if progress != nil {
                    Circle().stroke(Color("lightGray"), lineWidth: 5)
                        .frame(width: device.valueByDevice(small: 30, normal: 30, ipad: 35))
                        .overlay(
                            Circle()
                                .trim(from: 0.0, to: uiProgress)
                                .stroke(imageColor, lineWidth: 5)
                                .rotationEffect(Angle(degrees: -90))
                        )
                        .skeletonable()
                }
            }
        }
        .padding([.horizontal, .top], device.valueByDevice(small: 15, normal: 15, ipad: 20))
        .padding(.bottom, device.valueByDevice(small: 13, normal: 13, ipad: 18))
        .padding(.trailing, device.valueByDevice(small: 5, normal: 5, ipad: 10))
        .frame(maxWidth: .infinity)
        .raisedButton(cornerRadius: 15, backgroundColor: Color("offWhite"), shadowColor: Color.gray.opacity(0.4), shadowOffset: 6, action: {
            showAltValue.toggle()
        })
        .setSkeleton(
            $isLoading,
            animationType: .gradient([
                imageColor.opacity(0.3),
                imageColor.opacity(0.2),
                imageColor.opacity(0.3)
            ]),
            animation: Animation.linear(duration: 0.2).repeatForever(autoreverses: false),
            cornerRadius: 8
        )
        .onAppear {
            withAnimation(.linear(duration: 0.85)) {
                uiProgress = progress ?? 0
            }
        }
        .onChange(of: progress, perform: { newValue in
            withAnimation(.linear(duration: 0.85)) {
                uiProgress = newValue ?? 0
            }
        })
    }
}

#Preview {
    GeometryReader { screen in
        StatPanel(imageName: "timer", imageColor: Color("pastelPurple"), value: "80%", altValue: "8 / 10", label: "addition", borderColor: Color("pastelPurple"), progress: 0.8, isLoading: .constant(false))
            .padding(20)
            .environmentObject(DeviceModel(screen: screen))
    }
}
