//
//  DeviceModel.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/1/25.
//

import SwiftUI

enum DeviceType {
    case SMALL, NORMAL, LARGE
}

class DeviceModel: ObservableObject {
    @Published var type: DeviceType = .NORMAL
}
