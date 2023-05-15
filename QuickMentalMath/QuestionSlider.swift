//
//  TimeSliderView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 5/14/23.
//

import SwiftUI

struct QuestionSlider: View {
    
    @Binding var progress: Double
    
    @State private var rotationAngle = Angle(degrees: 0)
    private var minValue = 0.0
    private var maxValue = 1.0
    
    init(value progress: Binding<Double>, in bounds: ClosedRange<Int> = 0...1) {
        self._progress = progress
        
        self.minValue = Double(bounds.first ?? 0)
        self.maxValue = Double(bounds.last ?? 1)
        self.rotationAngle = Angle(degrees: progressFraction * 360.0)
    }
    
    private var progressFraction: Double {
        return ((progress - minValue) / (maxValue - minValue))
    }
    
    private func changeAngle(location: CGPoint) {
        // Create a Vector for the location (reversing the y-coordinate system on iOS)
        let vector = CGVector(dx: location.x, dy: -location.y)
        
        // Calculate the angle of the vector
        let angleRadians = atan2(vector.dx, vector.dy)
        
        // Convert the angle to a range from 0 to 360 (rather than having negative angles)
        let positiveAngle = angleRadians < 0.0 ? angleRadians + (2.0 * .pi) : angleRadians
        
        // Update slider progress value based on angle
        progress = ((positiveAngle / (2.0 * .pi)) * (maxValue - minValue)) + minValue
        rotationAngle = Angle(radians: positiveAngle)
    }
    
    var body: some View {
        GeometryReader { gr in
            let radius = (min(gr.size.width, gr.size.height) / 2.0) * 0.9
            let sliderWidth = radius * 0.15
            
            VStack(spacing:0) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.65),
                                style: StrokeStyle(lineWidth: sliderWidth))
                        .overlay() {
                            Text("\(progress, specifier: "%.0f")")
                                .font(.system(size: radius * 0.5, weight: .bold, design:.rounded))
                                .foregroundColor(Color.white)
                        }
                    
                    Circle()
                        .trim(from: 0, to: progressFraction)
                        .stroke(Color("bgColor"),
                                style: StrokeStyle(lineWidth: sliderWidth, lineCap: .round)
                        )
                        .rotationEffect(Angle(degrees: -90))
                    Circle()
                        .fill(Color.white)
                        .shadow(radius: (sliderWidth * 0.3))
                        .frame(width: sliderWidth+10, height: sliderWidth+10)
                        .offset(y: -radius)
                        .rotationEffect(rotationAngle)
                        .gesture(
                            DragGesture(minimumDistance: 0.0)
                                .onChanged() { value in
                                    changeAngle(location: value.location)
                                }
                        )
                }
                .frame(width: radius * 2.0, height: radius * 2.0, alignment: .center)
                .padding(radius * 0.1)
            }
            
            .onAppear {
                self.rotationAngle = Angle(degrees: progressFraction * 360.0)
            }
        }
    }
}


