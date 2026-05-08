//
//  KeyPadButton.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/3/25.
//

import SwiftUI

struct KeyPadButton: View {

    let id: String
    let onClick: (String) -> Void

    // UI Customization - required from parent
    let foregroundColor: Color
    let backgroundColor: Color
    let shadowColor: Color
    let imageName: String?
    let isDisabled: Bool
    
    init(id: String, onClick: @escaping (String) -> Void) {
        self.id = id
        self.foregroundColor = Color("darkPurple")
        self.backgroundColor = Color("lighterPurple")
        self.shadowColor = Color("lightPurple")
        self.isDisabled = false
        self.imageName = nil
        self.onClick = onClick
    }
    
    init(id: String, foregroundColor: Color, backgroundColor: Color, shadowColor: Color, imageName: String, isDisabled: Bool, onClick: @escaping (String) -> Void) {
        self.id = id
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.shadowColor = shadowColor
        self.imageName = imageName
        self.onClick = onClick
        self.isDisabled = isDisabled
    }

    @EnvironmentObject var device: DeviceModel

    var body: some View {
        GeometryReader { screen in
            Button(action: {}, label: {
                if let image = imageName {
                    Image(systemName: image)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else {
                    Text(id == "12" ? "." : id)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            })
            .font(device.valueByDevice(small: .title2, normal: .title2, ipad: .largeTitle))
            .foregroundColor(foregroundColor)
            .fontWeight(.heavy)
            .raisedButton(impactStrength: .soft, backgroundColor: backgroundColor, shadowColor: shadowColor, shadowOffset: device.valueByDevice(small: 5, normal: 5, ipad: 8), allowsDoubleTap: true, action: {
                onClick(id)
            })
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.4 : 1)
        }
    }
}
