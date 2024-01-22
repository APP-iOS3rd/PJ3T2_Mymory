//
//  Color+Extension.swift
//  MyMemory
//
//  Created by 김소혜 on 1/15/24.
//

import Foundation
import SwiftUI

extension Color {
    static let peach = Color(hex: "#ff8882") // #을 제거하고 사용해도 됩니다.
    static let lightPeach = Color(hex: "FFF9F9")
    static let lightBlue = Color(hex:"E5F4F8")
    static let lightGreen = Color(hex: "EBF9E5")
    static let lightGray = Color(hex: "F4F4F4")
    static let darkGray = Color(hex: "5A5A5A")
    static let deepGray = Color(hex: "2E2E2E")
    static let lightPrimary = Color(hex: "DAD4FF")
    static let lightGrayBackground = Color(hex: "E7E7E7")
}
 
extension Color {
  init(hex: String) {
    let scanner = Scanner(string: hex)
    _ = scanner.scanString("#")
    
    var rgb: UInt64 = 0
    scanner.scanHexInt64(&rgb)
    
    let r = Double((rgb >> 16) & 0xFF) / 255.0
    let g = Double((rgb >>  8) & 0xFF) / 255.0
    let b = Double((rgb >>  0) & 0xFF) / 255.0
    self.init(red: r, green: g, blue: b)
  }
}
