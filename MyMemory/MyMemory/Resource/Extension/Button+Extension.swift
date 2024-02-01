//
//  Button+Extension.swift
//  MyMemory
//
//  Created by 김소혜 on 1/15/24.
//

import Foundation
import SwiftUI


// Pill(알약형태)
// 다음과 같이 사용해주세요. .buttonStyle(Pill.standard)
struct Pill: ButtonStyle {
    let backgroundColor: Color
    let titleColor: Color
    let setFont: Font
    var paddingVertical: CGFloat = 12
    var paddingHorzontal: CGFloat = 16
    
    static var standard: Pill {
        return Pill(backgroundColor: .accentColor, titleColor: .white, setFont: .bold16)
    }
 
    static var lightGray: Pill {
        return Pill(backgroundColor: .lightGray, titleColor: .darkGray, setFont: .bold12, paddingVertical: 8, paddingHorzontal: 12)
    }
    static var selected: Pill {
        return Pill(backgroundColor: .accentColor, titleColor: .white, setFont: .bold12, paddingVertical: 8, paddingHorzontal: 12)
    }
    static var contains: Pill {
        return Pill(backgroundColor: .accentColor, titleColor: .white, setFont: .bold12, paddingVertical: 8, paddingHorzontal: 12)
    }
    static var deepGray: Pill {
        return Pill(backgroundColor: .deepGray, titleColor: .white, setFont: .bold12, paddingVertical: 8, paddingHorzontal: 12)
    }
    static var secondary: Pill {
        return Pill(backgroundColor: .deepGray, titleColor: .white, setFont: .bold14)
    }
    

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(setFont)
            .padding(.horizontal, paddingHorzontal)
            .padding(.vertical, paddingVertical)
            .background(backgroundColor)
            .foregroundColor(titleColor)
            .clipShape(Capsule())
    }
}


struct RoundedRect: ButtonStyle {
    let backgroundColor: Color
    let titleColor: Color
    let setFont: Font
    var paddingVertical: CGFloat = 12
    var paddingHorzontal: CGFloat = 16
    let cornerRadius: CGFloat = 10
    var borderColor: Color = Color(UIColor.systemGray4)
    
    static var standard: RoundedRect {
        return RoundedRect(backgroundColor: .white, titleColor: .darkGray, setFont: .bold14)
    }
    
    static var large: RoundedRect {
        return RoundedRect(backgroundColor: .white, titleColor: .darkGray, setFont: .bold16, paddingVertical: 12, paddingHorzontal: 12)
    }
    static var selected: RoundedRect {
        return RoundedRect(backgroundColor: .lightPeach, titleColor: .peach, setFont: .bold14)
    }
    static var primary: RoundedRect {
        return RoundedRect(backgroundColor: .accentColor, titleColor: .white, setFont: .bold14, paddingVertical: 10, paddingHorzontal: 12, borderColor: .accentColor)
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(setFont)
            .padding(.horizontal, paddingHorzontal)
            .padding(.vertical, paddingVertical)
            .foregroundColor(titleColor)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(borderColor)
            )
    }
}

