//
//  OptionsGroup.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 5/12/23.
//

import SwiftUI

struct OptionsGroup: View {
    
    var title: String
    var items: [String]
    @Binding var selectedID: Int
    
    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.title3)
                .bold()
                .foregroundColor(Color("textColor"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10)
            
            OptionSlider(items: items, selectedIndex: $selectedID)
        }
    }
}

