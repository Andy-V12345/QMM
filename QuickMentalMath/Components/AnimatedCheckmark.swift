//
//  AnimatedCheckmark.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/28/25.
//

import SwiftUI

struct AnimatedCheckmark: View {

    let size: CGFloat
    let color: Color
    let strokeWidth: CGFloat

    @State private var checkmarkProgress: CGFloat = 0
    @State private var circleProgress: CGFloat = 0

    init(size: CGFloat = 100, color: Color = Color("correctGreen"), strokeWidth: CGFloat = 4) {
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

            // Checkmark
            CheckmarkShape()
                .trim(from: 0, to: checkmarkProgress)
                .stroke(color, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round, lineJoin: .round))
                .frame(width: size * 0.45, height: size * 0.45)
        }
        .onAppear {
            // Animate checkmark first
            withAnimation(.easeInOut(duration: 0.5)) {
                checkmarkProgress = 1.0
            }

            // Then animate circle after checkmark completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    circleProgress = 1.0
                }
            }
        }
    }
}

// Custom shape for checkmark
struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Start from bottom left of checkmark
        let startPoint = CGPoint(x: rect.minX, y: rect.midY)
        path.move(to: startPoint)

        // Move to the bend point (bottom of checkmark)
        let bendPoint = CGPoint(x: rect.midX - rect.width * 0.1, y: rect.maxY)
        path.addLine(to: bendPoint)

        // Move to top right (end of checkmark)
        let endPoint = CGPoint(x: rect.maxX, y: rect.minY)
        path.addLine(to: endPoint)

        return path
    }
}

#Preview {
    GeometryReader { screen in
        VStack(spacing: 40) {
            AnimatedCheckmark()

            AnimatedCheckmark(size: 150, color: .blue, strokeWidth: 6)

            AnimatedCheckmark(size: 80, color: .red, strokeWidth: 3)
        }
    }
}
