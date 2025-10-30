//
//  AnimatedErrorMark.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/28/25.
//

import SwiftUI

struct AnimatedErrorMark: View {

    let size: CGFloat
    let color: Color
    let strokeWidth: CGFloat

    @State private var xMarkProgress: CGFloat = 0
    @State private var circleProgress: CGFloat = 0

    init(size: CGFloat = 100, color: Color = Color("errorRed"), strokeWidth: CGFloat = 4) {
        self.size = size
        self.color = color
        self.strokeWidth = strokeWidth
    }

    var body: some View {
        ZStack {
            // Circle
            Circle()
                .trim(from: 0, to: circleProgress)
                .stroke(color, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))

            // X Mark
            XMarkShape()
                .trim(from: 0, to: xMarkProgress)
                .stroke(color, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round, lineJoin: .round))
                .frame(width: size * 0.45, height: size * 0.45)
        }
        .onAppear {
            // Animate X mark first
            withAnimation(.easeInOut(duration: 0.5)) {
                xMarkProgress = 1.0
            }

            // Then animate circle after X mark completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    circleProgress = 1.0
                }
            }
        }
    }
}

// Custom shape for X mark
struct XMarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // First diagonal line (top-left to bottom-right)
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))

        // Second diagonal line (top-right to bottom-left)
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))

        return path
    }
}

#Preview {
    GeometryReader { screen in
        VStack(spacing: 40) {
            AnimatedErrorMark()

            AnimatedErrorMark(size: 150, color: .red, strokeWidth: 6)

            AnimatedErrorMark(size: 80, color: .orange, strokeWidth: 3)
        }
    }
}
