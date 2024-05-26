//
//  OptionSlider.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 5/11/23.
//

import SwiftUI

struct OptionSlider: View {
    
    let items: [String]
    @State var color: Color?
    @State var borderRadius: CGFloat?
    let isSmall: Bool?
    
    @Binding var selectedIndex: Int
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            ForEach(items, id: \.self) { item in
                let tabId = items.firstIndex(of: item)
                ZStack {
                    RoundedRectangle(cornerRadius: borderRadius ?? 10)
                        .fill(color ?? Color("bgColor"))
                        .frame(maxWidth: .infinity)
                    Text(item)
                        .foregroundColor(.white)
                        .font(isSmall! ? .title3 : .title2)
                        .bold()
                    if tabId! < items.count-1 {
                        HStack {
                            Spacer()
                            Image(systemName: "chevron.right")
                                .padding(.horizontal, 20)
                                .foregroundColor(.white)
                                .font(.headline)
                                .bold()
                                .onTapGesture {
                                    selectedIndex += 1
                                }
                        }
                    }
                    
                    if tabId! > 0 {
                        HStack {
                            Image(systemName: "chevron.left")
                                .padding(.horizontal, 20)
                                .foregroundColor(.white)
                                .font(.title2)
                                .bold()
                                .onTapGesture {
                                    selectedIndex -= 1
                                }
                            Spacer()
                        }
                    }
                }
                .tag(tabId!)
                .padding(.horizontal, 3)
                

                
            }
        }
        .onAppear {
            if selectedIndex >= items.count {
                selectedIndex = items.count - 1
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(maxWidth: .infinity)
        .animation(.easeInOut(duration: 0.5), value: selectedIndex)
        .transition(.slide)
    }
}

//struct OptionSlider_Previews: PreviewProvider {
//    static var previews: some View {
//        OptionSlider(items: ["Addition", "Subtraction", "Multiplication", "Division"])
//            .frame(height: 200)
//    }
//}




