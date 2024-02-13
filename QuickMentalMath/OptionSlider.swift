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
                        .font(isSmall! ? .title2 : .title)
                        .bold()
                    if tabId! < items.count-1 {
                        Image(systemName: "chevron.right")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.horizontal, 30)
                            .foregroundColor(.white)
                            .font(.title2)
                            .bold()
                            .onTapGesture {
                                selectedIndex += 1
                            }
                    }
                    
                    if tabId! > 0 {
                        Image(systemName: "chevron.left")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 30)
                            .foregroundColor(.white)
                            .font(.title2)
                            .bold()
                            .onTapGesture {
                                selectedIndex -= 1
                            }
                    }
                }
                .tag(tabId!)
                .padding(.horizontal, 10)
                

                
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




