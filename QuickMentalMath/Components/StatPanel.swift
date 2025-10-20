//
//  StatPanel.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/3/25.
//

import SwiftUI

struct StatPanel: View {
    
    let imageName: String
    let imageColor: Color
    let value: String
    let altValue: String
    let label: String
    let borderColor: Color
    let progress: Double?
    @State var uiProgress: Double = 0
    @State var showAltValue = false
    
    init(imageName: String, imageColor: Color, value: String, altValue: String, label: String, borderColor: Color, progress: Double?) {
        self.imageName = imageName
        self.imageColor = imageColor
        self.value = value
        self.altValue = altValue
        self.label = label
        self.borderColor = borderColor
        self.progress = progress
        self.uiProgress = uiProgress
        self.showAltValue = showAltValue
    }
    
    init(imageName: String, imageColor: Color, value: String, label: String, borderColor: Color, progress: Double?) {
        self.imageName = imageName
        self.imageColor = imageColor
        self.value = value
        self.altValue = value
        self.label = label
        self.borderColor = borderColor
        self.progress = progress
        self.uiProgress = uiProgress
        self.showAltValue = showAltValue
    }
    
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: imageName)
                .foregroundStyle(imageColor)
                .font(.title2)
                .bold()
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(showAltValue ? altValue : value)")
                        .foregroundStyle(Color("darkPurple"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(1)
                    
                    Text("\(label)")
                        .foregroundStyle(borderColor)
                        .fontWeight(.bold)
                        .font(.headline)
                }
                
                Spacer()
                
                if progress != nil {
                    Circle().stroke(Color("lightGray"), lineWidth: 5)
                        .frame(width: 30)
                        .overlay(
                            Circle()
                                .trim(from: 0.0, to: uiProgress)
                                .stroke(imageColor, lineWidth: 5)
                                .rotationEffect(Angle(degrees: -90))
                        )
                }
            }
        }
        .padding([.horizontal, .top], 15)
        .padding(.bottom, 13)
        .padding(.trailing, 5)
        .frame(maxWidth: .infinity)
        .raisedButton(cornerRadius: 15, backgroundColor: Color("offWhite"), shadowColor: Color.gray.opacity(0.4), shadowOffset: 6, action: {
            showAltValue.toggle()
        })
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
    StatPanel(imageName: "timer", imageColor: Color("pastelPurple"), value: "80%", altValue: "8 / 10", label: "addition", borderColor: Color("pastelPurple"), progress: 0.8)
        .padding(20)
}
