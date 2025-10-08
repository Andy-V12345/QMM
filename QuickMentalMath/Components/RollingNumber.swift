//
//  RollingNumber.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/2/25.
//

import SwiftUI

struct RollingNumber: View {
    @Binding var number: String
    var color: Color?
    var font: Font?
    var digitWidth: CGFloat?
    var digitHeight: CGFloat?
    @State private var offset: [CGFloat] = []
    @State private var hasAppeared = false
    
    var body: some View {
        HStack(spacing: 0) {
            let digits = Array(number)
            ForEach(Array(digits.enumerated()), id: \.offset) { index, char in
                SingleDigit(
                    char: char,
                    offset: offset[safe: index] ?? 0,
                    color: color ?? Color.black,
                    font: font ?? Font.largeTitle.bold(),
                    digitWidth: digitWidth ?? 25,
                    digitHeight: digitHeight ?? 70
                )
            }
        }
        .onAppear {
            if !hasAppeared {
                setInitialOffsets()
                hasAppeared = true
            }
        }
        .onChange(of: number, perform: { newValue in
            withAnimation(.linear(duration: 0.2)) {
                setOffsets()
            }
        })
    }
    
    func setOffsets() {
        withAnimation(.easeInOut(duration: 0.2)) {
            offset = number.map { char -> CGFloat in
                if let digit = Int(String(char)) {
                    return CGFloat(digit) * (digitHeight ?? 70)
                }
                else {
                    return 0
                }
            }
        }
    }
    
    func setInitialOffsets() {
        offset = number.map {_ in CGFloat((digitHeight ?? 70) * 10)}
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            setOffsets()
        }
    }
}

struct SingleDigit: View {
    var char: Character
    var offset: CGFloat = 0
    var color: Color
    var font: Font
    var digitWidth: CGFloat
    var digitHeight: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ForEach(0..<10) { number in
                    if char.isNumber {
                        Text("\(number)")
                            .font(font)
                            .foregroundStyle(color)
                            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                            .dynamicTypeSize(.large)
                    }
                    else {
                        Text("\(char)")
                            .font(font)
                            .foregroundStyle(color)
                            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                            .dynamicTypeSize(.large)
                    }
                }
            }
            .offset(y: -offset)
        }
        .frame(width: digitWidth, height: digitHeight, alignment: .center)
        .clipped()
    }
}

//#Preview {
//    RollingNumber(number: "29", color: Color("lightPurple"), font: Font.largeTitle.bold())
//}
