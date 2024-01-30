//
//  Color+Extension.swift
//  MyMemory
//
//  Created by 김소혜 on 1/15/24.
//

import SwiftUI

extension Color {
    
    // #을 제거하고 사용해도 됩니다.
    
    // 색상 지정
    static let peach = Color(hex: "#ff8882")
    static let lightPeach = Color(hex: "FFF9F9")
    static let lightBlue = Color(hex:"E5F4F8")
    static let lightGreen = Color(hex: "EBF9E5")
    static let lightGray = Color(hex: "F4F4F4")
    static let darkGray = Color(hex: "5A5A5A")
    static let deepGray = Color(hex: "2E2E2E")
    static let lightPrimary = Color(hex: "DAD4FF")
    static let lightGrayBackground = Color(hex: "E7E7E7")
    
    // 테마에 따라 Color Change
    static let textGray = adaptiveColor(light: Color(hex:"949494"), dark: Color(hex:"949494"))
    static let textColor = adaptiveColor(light: Color(hex:"000000"), dark: Color(hex:"000000")) // 본문컬러
    static let borderColor = adaptiveColor(light: .lightGray, dark: .lightGray)
    static let iconColor = adaptiveColor(light: .darkGray, dark: .deepGray)
    static let bgColor = adaptiveColor(light: .lightGray, dark: Color(hex:"252525"))
}

extension Color {
    
    // 현재 다크, 라이트모드의 컬러를 각각 적용하였습니다.
    // 추후 테마 변경시에도, 해당 코드에 조건을 추가해서 색상들을 일괄적으로 변경할 수 있습니다.
    static func adaptiveColor(light: Color, dark: Color) -> Color {
       if UITraitCollection.current.userInterfaceStyle == .dark {
           return dark
       } else {
           return light
       }
        // else if 추가조건 == { return duotone }
    }
       
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
