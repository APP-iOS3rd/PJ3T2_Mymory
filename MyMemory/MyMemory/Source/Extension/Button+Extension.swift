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
    
    static var standard2: Pill {
        return Pill(backgroundColor: Color(UIColor.systemGray5), titleColor: .iconColor, setFont: .bold12, paddingVertical: 8, paddingHorzontal: 12)
    }
    
    static var standard3: Pill {
        return Pill(backgroundColor: .clear, titleColor: .textColor, setFont: .bold12, paddingVertical: 8, paddingHorzontal: 12)
    }
    
    static var selected: Pill {
        return Pill(backgroundColor: .accentColor, titleColor: .white, setFont: .bold12, paddingVertical: 8, paddingHorzontal: 12)
    }
    
    
    static var contains: Pill {
        return Pill(backgroundColor: .accentColor, titleColor: .white, setFont: .bold12, paddingVertical: 8, paddingHorzontal: 12)
    }
    static var deepGray: Pill {
        return Pill(backgroundColor: .bgColor4, titleColor: .white, setFont: .bold12, paddingVertical: 8, paddingHorzontal: 12)
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
    var borderColor: Color = .borderColor
    
    static var standard: RoundedRect {
        return RoundedRect(backgroundColor: .white, titleColor: .darkGray, setFont: .bold14)
    }
    static var active: RoundedRect {
        return RoundedRect(backgroundColor: .accentColor, titleColor: .white, setFont: .bold14)
    }
    static var large: RoundedRect {
        return RoundedRect(backgroundColor: .white, titleColor: .darkGray, setFont: .bold16, paddingVertical: 12, paddingHorzontal: 12)
    }
    static var selected: RoundedRect {
        return RoundedRect(backgroundColor: .bgColor3, titleColor: .accentColor, setFont: .bold14)
    }
    static var primary: RoundedRect {
        return RoundedRect(backgroundColor: .accentColor, titleColor: .white, setFont: .bold14, paddingVertical: 10, paddingHorzontal: 12, borderColor: .accentColor)
    }
    static var follow: RoundedRect {
        return RoundedRect(backgroundColor: .accentColor, titleColor: .white, setFont: .bold12, paddingVertical: 8, paddingHorzontal: 10, borderColor: .accentColor)
    }
    static var loginApple: RoundedRect {
        return RoundedRect(backgroundColor: .black, titleColor: .white, setFont: .bold14, paddingVertical: 14, paddingHorzontal: 12, borderColor: .black)
    }
    
    static var loginGoogle: RoundedRect {
        return RoundedRect(backgroundColor: .white, titleColor: .black, setFont: .bold14, paddingVertical: 14, paddingHorzontal: 12, borderColor: .borderColor)
    }
    
    static var loginKakao: RoundedRect {
        return RoundedRect(backgroundColor: .yellow, titleColor: .black, setFont: .bold14, paddingVertical: 14, paddingHorzontal: 12, borderColor: .yellow)
    }
    
    static var loginBtn: RoundedRect {
        return RoundedRect(backgroundColor: .accentColor, titleColor: .textColor, setFont: .bold14, paddingVertical: 14, paddingHorzontal: 12, borderColor: .accentColor)
    }
    static var loginBtnDisabled: RoundedRect {
        return RoundedRect(backgroundColor: .gray, titleColor: .darkGray , setFont: .bold14, paddingVertical: 14, paddingHorzontal: 12, borderColor: .gray)
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

struct ButtonStylePriview: View {
    var body: some View {
        VStack {
            Text("Pill")
                .font(.extraBold28)
            Button("contains", action: {})
                .buttonStyle(Pill.contains)
            Button("deepGray", action: {})
                .buttonStyle(Pill.deepGray)
            Button("lightGray", action: {})
                .buttonStyle(Pill.lightGray)
            Button("secondary", action: {})
                .buttonStyle(Pill.secondary)
            Button("selected", action: {})
                .buttonStyle(Pill.selected)
            Button("standard", action: {})
                .buttonStyle(Pill.standard)
            Button("standard2", action: {})
                .buttonStyle(Pill.standard2)
            Button("standard3", action: {})
                .buttonStyle(Pill.standard3)
            Text("RoundedRect")
                .font(.extraBold28)
            Button("standard", action: {})
                .buttonStyle(RoundedRect.standard)
            Button("active", action: {})
                .buttonStyle(RoundedRect.active)
            Button("large", action: {})
                .buttonStyle(RoundedRect.large)
            Button("selected", action: {})
                .buttonStyle(RoundedRect.selected)
            Button("primary", action: {})
                .buttonStyle(RoundedRect.primary)
            Button("follow", action: {})
                .buttonStyle(RoundedRect.follow)
        }
    }
}
#Preview {
    ButtonStylePriview()
}
