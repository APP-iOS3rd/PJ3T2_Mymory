//
//  Fonts+Extensions.swift
//  MyMemory
//
//  Created by 김태훈 on 1/2/24.
//

import Foundation
import SwiftUI
extension Font {
    
    // Black
    static let black20: Font = .custom(FontType.Black.rawValue, size: 20)
    // ExtraBold
    static let extraBold28: Font = .custom(FontType.ExtraBold.rawValue, size: 28)
    static let extraBold12: Font = .custom(FontType.ExtraBold.rawValue, size: 12)
    // Bold
    static let bold12: Font = .custom(FontType.Bold.rawValue, size: 12)
    static let bold14: Font = .custom(FontType.Bold.rawValue, size: 14)
    static let bold16: Font = .custom(FontType.Bold.rawValue, size: 16)
    static let bold18: Font = .custom(FontType.Bold.rawValue, size: 18)
    static let bold20: Font = .custom(FontType.Bold.rawValue, size: 20)
    static let bold22: Font = .custom(FontType.Bold.rawValue, size: 22)
    static let bold24: Font = .custom(FontType.Bold.rawValue, size: 24)
    static let bold28: Font = .custom(FontType.Bold.rawValue, size: 28)
    static let bold34: Font = .custom(FontType.Bold.rawValue, size: 34)
    
    // SemiBold
    static let semibold11: Font = .custom(FontType.SemiBold.rawValue, size: 11)
    static let semibold12: Font = .custom(FontType.SemiBold.rawValue, size: 12)
    static let semibold14: Font = .custom(FontType.SemiBold.rawValue, size: 14)
    static let semibold16: Font = .custom(FontType.SemiBold.rawValue, size: 16)
    static let semibold17: Font = .custom(FontType.SemiBold.rawValue, size: 17)
    static let semibold20: Font = .custom(FontType.SemiBold.rawValue, size: 20)
    static let semibold22: Font = .custom(FontType.SemiBold.rawValue, size: 22)
    static let semibold24: Font = .custom(FontType.SemiBold.rawValue, size: 24)
    
    // Medium
    static let medium12: Font = .custom(FontType.Medium.rawValue, size: 12)
    static let medium14: Font = .custom(FontType.Medium.rawValue, size: 14)
    static let medium16: Font = .custom(FontType.Medium.rawValue, size: 16)
    static let medium18: Font = .custom(FontType.Medium.rawValue, size: 18)
    
    // Regular
    static let regular11: Font = .custom(FontType.Regular.rawValue, size: 11)
    static let regular12: Font = .custom(FontType.Regular.rawValue, size: 12)
    static let regular14: Font = .custom(FontType.Regular.rawValue, size: 14)
    static let regular16: Font = .custom(FontType.Regular.rawValue, size: 16)
    static let regular18: Font = .custom(FontType.Regular.rawValue, size: 18)
    static let regular24: Font = .custom(FontType.Regular.rawValue, size: 24)
    
    // Light
    static let light10: Font = .custom(FontType.Light.rawValue, size: 10)
    static let light14: Font = .custom(FontType.Light.rawValue, size: 14)
    static let light18: Font = .custom(FontType.Light.rawValue, size: 14)

    // Thin
    static let thin32: Font = .custom(FontType.Thin.rawValue, size: 32)
     
    static func appFont(for type : FontType, size: CGFloat) -> Font? {
        self.custom(type.rawValue, size: size)
    }
    
    
    // 사용자의 메인 텍스트 폰트를 반환하는 메서드
    static func userMainTextFont(fontType: FontType, baseSize: CGFloat = 16) -> Font {
        let adjustedSize = FontManager.shared.fontSize(for: fontType, baseSize: baseSize)
        return .custom(fontType.rawValue, size: adjustedSize)
    }

}

enum FontType: String, CaseIterable, Codable {
    // Pretendard
    case Black = "Pretendard-Black"
    case ExtraBold = "Pretendard-ExtraBold"
    case Bold = "Pretendard-Bold"
    case SemiBold = "Pretendard-SemiBold"
    case Medium = "Pretendard-Medium"
    case Regular = "Pretendard-Regular"
    case Light = "Pretendard-Light"
    case ExtraLight = "Pretendard-ExtraLight"
    case Thin = "Pretendard-Thin"
    
    // 추가 폰트
    case OwnglyphEuiyeon = "OwnglyphEuiyeonChae"
    case NeoDunggeunmo = "NeoDunggeunmo-Regular"
    case YeongdeokSea = "Yeongdeok Sea"
}
