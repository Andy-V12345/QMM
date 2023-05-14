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
    
    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.headline)
                .bold()
                .foregroundColor(Color("textColor"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10)
            
            OptionSlider(items: items)
        }
    }
}

struct OptionsGroup_Previews: PreviewProvider {
    static var previews: some View {
        OptionsGroup(title: "Mode", items: ["Addition", "Subtraction", "Multiplication", "Division"])
    }
}
