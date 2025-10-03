//
//  ViewExtensions.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/1/25.
//

import SwiftUI

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct RaisedButtonStyle: ViewModifier {
    @State private var isPressed = false
    let impactStrength: UIImpactFeedbackGenerator.FeedbackStyle
    let cornerRadius: CGFloat
    let backgroundColor: Color
    let shadowColor: Color
    let toggleColor: Color?
    let isToggled: Bool?
    let shadowOffset: CGFloat
    let action: () -> Void
    
    @Environment(\.isEnabled) var isEnabled

    func body(content: Content) -> some View {
        content
            .background(RoundedRectangle(cornerRadius: cornerRadius).fill(backgroundColor))
            .clipped()
            .offset(x: 0, y: isPressed ? shadowOffset : 0)
            .shadow(color: isToggled == true ? toggleColor! : shadowColor, radius: 0, x: 0, y: isPressed ? 0 : shadowOffset + 2)
            .simultaneousGesture(
                TapGesture()
                    .onEnded {
                        if isEnabled {
                            withAnimation(.easeOut(duration: 0.1)) {
                                isPressed = true
                            }
                            
                            UIImpactFeedbackGenerator(style: impactStrength).impactOccurred()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                
                                withAnimation(.easeOut(duration: 0.15)) {
                                    isPressed = false
                                }
                                
                                action()
                            }
                        }
                    }
            )
            .onAppear {
                if !isEnabled {
                    isPressed = true
                }
            }
            .onChange(of: isEnabled, perform: { newValue in
                if newValue {
                    withAnimation(.easeOut(duration: 0.15)) {
                        isPressed = false
                    }
                }
                else {
                    withAnimation(.easeOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
            })
    }
}

extension View {
    func roundedCorner(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners) )
    }
    
    func raisedButton(
        impactStrength: UIImpactFeedbackGenerator.FeedbackStyle = .medium,
        cornerRadius: CGFloat = 10,
        backgroundColor: Color = Color("lighterPurple"),
        shadowColor: Color = Color("lightPurple"),
        toggleColor: Color? = nil,
        isToggled: Bool? = nil,
        shadowOffset: CGFloat = 10,
        action: @escaping () -> Void
    ) -> some View {
        self.modifier(
            RaisedButtonStyle(
                impactStrength: impactStrength,
                cornerRadius: cornerRadius,
                backgroundColor: backgroundColor,
                shadowColor: shadowColor,
                toggleColor: toggleColor,
                isToggled: isToggled,
                shadowOffset: shadowOffset,
                action: action
            )
        )
    }
}
