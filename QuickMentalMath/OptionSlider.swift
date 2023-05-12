//
//  OptionSlider.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 5/11/23.
//

import SwiftUI

struct OptionSlider: View {
    
    let items: [String]
    
    var body: some View {
        TabView {
            ForEach(items, id: \.self) { item in
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("bgColor"))
                        .frame(maxWidth: .infinity)
                    Text(item)
                        .foregroundColor(.white)
                        .font(.title2)
                        .bold()
                }
                .padding(.horizontal, 10)
            }
        }
//        .onAppear() {
//            UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.darkGray
//            UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
//
//        }
        .tabViewStyle(PageTabViewStyle())
        .frame(maxWidth: .infinity, maxHeight: 150)
    }
}

struct OptionSlider_Previews: PreviewProvider {
    static var previews: some View {
        OptionSlider(items: ["Addition", "Subtraction", "Multiplication", "Division"])
    }
}



//struct OptionSlider<Content: View, T: Identifiable>: View {
//
//    var content: (T) -> Content
//    var list: [T]
//
//    var spacing: CGFloat
//    var trailingSpace: CGFloat
//    @Binding var index: Int
//
//    init(spacing: CGFloat = 15, trailingSpace: CGFloat = 80, index: Binding<Int>, items: [T], @ViewBuilder content: @escaping (T) -> Content) {
//        self.list = items
//        self.spacing = spacing
//        self.trailingSpace = trailingSpace
//        self._index = index
//        self.content = content
//    }
//
//    @GestureState var offset: CGFloat = 0
//    @State var currentIndex: Int = 0
//
//    var body: some View {
//
//        GeometryReader { proxy in
//
//            let width = proxy.size.width - (trailingSpace - spacing)
//            let adjustmentWidth = (trailingSpace / 2) - spacing
//
//            HStack(spacing: spacing) {
//                ForEach(list) { item in
//                    content(item)
//                        .frame(width: width - trailingSpace)
//                }
//            }
//            .padding(.horizontal, spacing)
//            .offset(x: (CGFloat(currentIndex) * -width) + (currentIndex != 0 ? adjustmentWidth : 0) + offset)
//            .gesture(
//                DragGesture()
//                    .updating($offset, body: { value, out, _ in
//                        out = value.translation.width
//                    })
//                    .onEnded({ value in
//                        let offsetX = value.translation.width
//
//                        let progress = -offsetX / width
//                        let roundIndex = progress.rounded()
//
//                        currentIndex = max(0, min(Int(roundIndex) + currentIndex, list.count - 2))
//
//                        currentIndex = index
//                    })
//                    .onChanged({ value in
//                        let offsetX = value.translation.width
//
//                        let progress = -offsetX / width
//                        let roundIndex = progress.rounded()
//
//                        index = max(0, min(Int(roundIndex) + currentIndex, list.count - 2))
//
//                    })
//            )
//        }
//        .animation(.easeInOut, value: offset == 0)
//
//    }
    
//    var body: some View {
//        TabView {
//            ForEach(options, id: \.self) { item in
//                ZStack() {
//                    Text(item)
//                        .foregroundColor(.black)
//                        .font(.title2)
//                        .bold()
//                        .padding()
//                }
//                .background(Color.red)
//            }
//        }
//        .tabViewStyle(PageTabViewStyle())
//    }
//}


