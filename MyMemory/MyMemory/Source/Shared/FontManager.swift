//
//  FontManager.swift
//  MyMemory
//
//  Created by 김소혜 on 2/6/24.
//

import Foundation
import SwiftUI
import Combine

// MARK: Font를 UserDefault에 저장하는 싱글톤입니다.

final class FontManager: ObservableObject {
    
    static let shared = FontManager()
    @Published var userFontPreference: FontType?
 
    init() {
        self.userFontPreference = loadFontPreference()
    }
    
    func saveFontPreference(fontType: FontType) {
        UserDefaults.standard.set(fontType.rawValue, forKey: "selectedFontType")
    }
    
    func loadFontPreference() -> FontType {
        guard let fontTypeString = UserDefaults.standard.string(forKey: "selectedFontType"),
              let fontType = FontType(rawValue: fontTypeString) else {
            // 기본 폰트 타입 반환
            return .Regular
        }
        return fontType
    }
    
    var fontPreference: FontType {
        get {
            guard let fontTypeString = UserDefaults.standard.string(forKey: "selectedFontType"),
                  let fontType = FontType(rawValue: fontTypeString) else {
                return .Regular // 기본값으로 Regular 반환
            }
            return fontType
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "selectedFontType")
        }
    }
    
    // FontType 별로 폰트 크기를 반환하는 메서드
    func fontSize(for type: FontType, baseSize: CGFloat) -> CGFloat {
        switch type {
        case .OwnglyphEuiyeon, .YeongdeokSea:
            return baseSize * 1.4 // 일부 FontType은 1.4배로 조정
        default:
            return baseSize // 다른 폰트 타입은 기본 크기
        }
    }
    
  
    
}
