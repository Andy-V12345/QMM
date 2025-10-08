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
    
    @Binding var timeLimit: TimeLimit
    
    @EnvironmentObject var device: DeviceModel
    
    let isTimeTrial: Bool
            
    var body: some View {
        VStack(spacing: device.valueByDevice(small: 12, normal: 15, ipad: 20)) {
            Button(action: {}, label: {
                Text("1 min")
                    .foregroundStyle(timeLimit == .ONE_MIN ? .white : Color("darkPurple"))
            })
            .padding(.vertical, device.valueByDevice(small: 8, normal: 10, ipad: 15))
            .frame(maxWidth: .infinity)
            .raisedButton(cornerRadius: buttonRadius, backgroundColor: timeLimit == .ONE_MIN ? Color("darkPurple") : Color("offWhite"), shadowColor: timeLimit == .ONE_MIN ? Color("darkerPurple") :  Color.gray.opacity(0.2), shadowOffset: shadowOffset, action: {
                timeLimit = .ONE_MIN
            })
            
            Divider()
            
            Button(action: {}, label: {
                Text("2 min")
                    .foregroundStyle(timeLimit == .TWO_MIN ? .white : Color("darkPurple"))
                    .opacity(isTimeTrial ? 0.5 : 1)

            })
            .padding(.vertical, device.valueByDevice(small: 8, normal: 10, ipad: 15))
            .frame(maxWidth: .infinity)
            .raisedButton(cornerRadius: buttonRadius, backgroundColor: timeLimit == .TWO_MIN ? Color("darkPurple") : Color("offWhite"), shadowColor: timeLimit == .TWO_MIN ? Color("darkerPurple") :  Color.gray.opacity(0.2), shadowOffset: shadowOffset, action: {
                timeLimit = .TWO_MIN
            })
            .allowsHitTesting(!isTimeTrial)
            
            Divider()
            
            Button(action: {}, label: {
                Text("3 min")
                    .foregroundStyle(timeLimit == .THREE_MIN ? .white : Color("darkPurple"))
                    .opacity(isTimeTrial ? 0.5 : 1)
            })
            .padding(.vertical, device.valueByDevice(small: 8, normal: 10, ipad: 15))
            .frame(maxWidth: .infinity)
            .raisedButton(cornerRadius: buttonRadius, backgroundColor: timeLimit == .THREE_MIN ? Color("darkPurple") : Color("offWhite"), shadowColor: timeLimit == .THREE_MIN ? Color("darkerPurple") :  Color.gray.opacity(0.2), shadowOffset: shadowOffset, action: {
                timeLimit = .THREE_MIN
            })
            .allowsHitTesting(!isTimeTrial)
            
            Divider()
            
            Button(action: {}, label: {
                Text("no limit")
                    .foregroundStyle(timeLimit == .NO_LIMIT ? .white : Color("darkPurple"))
                    .opacity(isTimeTrial ? 0.5 : 1)
            })
            .padding(.vertical, device.valueByDevice(small: 8, normal: 10, ipad: 15))
            .frame(maxWidth: .infinity)
            .raisedButton(cornerRadius: buttonRadius, backgroundColor: timeLimit == .NO_LIMIT ? Color("darkPurple") : Color("offWhite"), shadowColor: timeLimit == .NO_LIMIT ? Color("darkerPurple") :  Color.gray.opacity(0.2), shadowOffset: shadowOffset, action: {
                timeLimit = .NO_LIMIT
            })
            .allowsHitTesting(!isTimeTrial)
            
            Divider()
            
            Text("time limit")
                .fontWeight(.heavy)
                .foregroundColor(Color("lightPurple"))
        }
        .font(device.valueByDevice(small: .subheadline, normal: .headline, ipad: .title2))
        .bold()
        .padding(device.valueByDevice(small: 12, normal: 15, ipad: 20))
        .background(.white)
        .roundedCorner(20, corners: .allCorners)
        .clipped()
        .shadow(color: Color("lighterPurple"), radius: 3)

    }
}
