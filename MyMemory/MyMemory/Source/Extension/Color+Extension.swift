//
//  Color+Extension.swift
//  MyMemory
//
//  Created by 김소혜 on 1/15/24.
//

import SwiftUI
import UIKit

extension Color {
    
    // #을 제거하고 사용해도 됩니다.
    
    // 색상 지정
    static let peach = Color(hex: "#ff8882")
    static let lightPeach = Color(hex: "FFF9F9")
    static let lightBlue = Color(hex:"E5F4F8")
    static let lightGreen = Color(hex: "EBF9E5")
    static let lightGray = Color(hex: "F4F4F4")
    static let backgroundColor = Color(hex: "F5F5F5")
    static let lightGray2 = Color(hex: "252525")
    static let darkGray = Color(hex: "5A5A5A")
    static let deepGray = Color(hex: "2E2E2E")
    static let lightPrimary = Color(hex: "DAD4FF")
    static let lightGrayBackground = Color(hex: "E7E7E7")
    
    static let atomBgColor = Color(hex:"1d1f21")
    static let atomTextColor = Color(hex:"86CDFF")
    // 테마에 따라 Color Change
    static let textGray = Color.adaptive(light: UIColor(Color(hex:"949494")), dark: UIColor(Color(hex:"949494")))
    
    static let textColor = Color.adaptive(light: UIColor(Color.black), dark: UIColor(Color.white)) // 본문컬러
    static let textDarkColor = Color.adaptive(light: UIColor(Color.darkGray), dark: UIColor(Color.white)) // 본문컬러
    static let textDeepColor = Color.adaptive(light: UIColor(Color.deepGray), dark: UIColor(Color.white)) // 본문컬러
    
    static let originColor = Color.adaptive(light: UIColor(Color.white), dark: UIColor(Color.black))
    
    static let borderColor = Color.adaptive(light: UIColor(Color(hex:"CECECE")), dark: UIColor(Color(hex: "555459")))
    static let borderColor2 = Color.adaptive(light: UIColor.systemGray3, dark: UIColor(Color(hex: "555459")))
    
    static let iconColor = Color.adaptive(light: UIColor(Color.darkGray), dark: UIColor(Color.lightGray))
    
    static let bgColor = Color.adaptive(light: UIColor(Color.lightGray), dark: UIColor(Color.lightGray2))
    
    static let bgColor2 = Color.adaptive(light: UIColor(Color.white), dark: UIColor(Color.lightGray))
    
    static let bgColor3 = Color.adaptive(light: UIColor(Color.white), dark: UIColor(Color.deepGray))
    
    static let bgColor4 = Color.adaptive(light: UIColor(Color.darkGray), dark: UIColor(Color.deepGray))
    
    static let cardColor = Color.adaptive(light: UIColor(Color.white), dark: UIColor(Color.black))
    
    static let placeHolder = Color.adaptive(light: UIColor.systemGray3, dark: UIColor.systemGray2)
    
    
 
    
   
}

extension Color {
    
    // 다크, 라이트모드의 컬러를 각각 적용하였습니다.
    static func adaptiveColor(light: Color, dark: Color) -> Color {
       if UITraitCollection.current.userInterfaceStyle == .dark {
           return dark
       } else {
           return light
       }
        // else if 추가조건 == { return duotone }
    }
    
    
    static func adaptive(light: UIColor, dark: UIColor) -> Color {
      return Color(UIColor { traitCollection in
          traitCollection.userInterfaceStyle == .dark ? dark : light
      })
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
