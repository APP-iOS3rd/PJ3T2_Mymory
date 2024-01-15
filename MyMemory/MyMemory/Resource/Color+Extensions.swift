//
//  Color+Extensions.swift
//  MyMemory
//
//  Created by 이명섭 on 1/15/24.
//

import Foundation
import SwiftUI

// MARK: hex코드를 RGB로 변환하는 extension. ex) Color(hexString: "FFFFFF")
extension Color {
    init(hexString: String, opacity: Double = 1.0) {
        let hex: Int = Int(hexString, radix: 16)!
        let red = Double((hex >> 16) & 0xff) / 255
        let green = Double((hex >> 8) & 0xff) / 255
        let blue = Double((hex >> 0) & 0xff) / 255
        
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

