//
//  TimeSelector.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 5/17/24.
//

import SwiftUI

struct TimeSelector: View {
    
    let buttonRadius: CGFloat = 15
    let shadowOffset: CGFloat = 3
    
    @Binding var timeIndex: Int
    
    let metrics: GeometryProxy
        
    var body: some View {
        VStack(spacing: metrics.size.height < 736 ? 12 : 15) {
            Button(action: {}, label: {
                Text("1 min")
                    .foregroundStyle(timeIndex == 0 ? .white : Color("darkPurple"))
            })
            .padding(.vertical, metrics.size.height < 736 ? 8 : 10)
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity)
            .raisedButton(cornerRadius: buttonRadius, backgroundColor: timeIndex == 0 ? Color("darkPurple") : Color("offWhite"), shadowColor: timeIndex == 0 ? Color("darkerPurple") :  Color.gray.opacity(0.2), shadowOffset: shadowOffset, action: {
                timeIndex = 0
            })
            
            Divider()
            
            Button(action: {}, label: {
                Text("2 min")
                    .foregroundStyle(timeIndex == 1 ? .white : Color("darkPurple"))
            })
            .padding(.vertical, metrics.size.height < 736 ? 8 : 10)
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity)
            .raisedButton(cornerRadius: buttonRadius, backgroundColor: timeIndex == 1 ? Color("darkPurple") : Color("offWhite"), shadowColor: timeIndex == 1 ? Color("darkerPurple") :  Color.gray.opacity(0.2), shadowOffset: shadowOffset, action: {
                timeIndex = 1
            })
            
            Divider()
            
            Button(action: {}, label: {
                Text("3 min")
                    .foregroundStyle(timeIndex == 2 ? .white : Color("darkPurple"))
            })
            .padding(.vertical, metrics.size.height < 736 ? 8 : 10)
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity)
            .raisedButton(cornerRadius: buttonRadius, backgroundColor: timeIndex == 2 ? Color("darkPurple") : Color("offWhite"), shadowColor: timeIndex == 2 ? Color("darkerPurple") :  Color.gray.opacity(0.2), shadowOffset: shadowOffset, action: {
                timeIndex = 2
            })
            
            Divider()
            
            Button(action: {}, label: {
                Text("no limit")
                    .foregroundStyle(timeIndex == 3 ? .white : Color("darkPurple"))
            })
            .padding(.vertical, metrics.size.height < 736 ? 8 : 10)
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity)
            .raisedButton(cornerRadius: buttonRadius, backgroundColor: timeIndex == 3 ? Color("darkPurple") : Color("offWhite"), shadowColor: timeIndex == 3 ? Color("darkerPurple") :  Color.gray.opacity(0.2), shadowOffset: shadowOffset, action: {
                timeIndex = 3
            })
            
            Divider()
            
            Text("time limit")
                .font(metrics.size.height < 736 && metrics.size.width < 390 ? .subheadline : .headline)
                .fontWeight(.heavy)
                .foregroundColor(Color("lightPurple"))
        }
        .font(metrics.size.height < 736 ? .subheadline : .headline)
        .bold()
        .padding(metrics.size.height < 736 && metrics.size.width < 390 ? 12 : 15)
        .background(.white)
        .roundedCorner(20, corners: .allCorners)
        .clipped()
        .shadow(radius: 2)

    }
}
