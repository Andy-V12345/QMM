//
//  DeviceModel.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/1/25.
//

import SwiftUI

enum DeviceType {
    case SMALL_PHONE, NORMAL_PHONE, IPAD
}

class DeviceModel: ObservableObject {
    var type: DeviceType?
    var screen: GeometryProxy?
    
    init() {}
    
    init(screen: GeometryProxy) {
        self.setScreen(screen: screen)
    }
        
    func setScreen(screen: GeometryProxy) {
        self.screen = screen
        
        if screen.size.width > 500 {
            self.type = .IPAD
        }
        else if screen.size.width <= 375 {
            self.type = .SMALL_PHONE
        }
        else {
            self.type = .NORMAL_PHONE
        }
    }
    
    func valueByDevice<T>(small: T, normal: T, ipad: T) -> T {
        switch self.type! {
        case .SMALL_PHONE:
            return small
        case .NORMAL_PHONE:
            return normal
        case .IPAD:
            return ipad
        }
    }
}
