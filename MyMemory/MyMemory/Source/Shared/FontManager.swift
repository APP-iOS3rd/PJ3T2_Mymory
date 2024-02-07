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
        
        DispatchQueue.main.async {
            self.userFontPreference = fontType
          //  self.objectWillChange.send() // 변경 알림 발송
        }
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
            
            // userFontPreference도 함께 업데이트하여 @Published를 통해 변경 사항을 반영합니다.
           DispatchQueue.main.async {
               self.userFontPreference = newValue
           }
        }
    }
    
    // FontType 별로 폰트 크기를 반환하는 메서드
    func fontSize(for type: FontType, baseSize: CGFloat) -> CGFloat {
        switch type {
        case .OwnglyphEuiyeon:
            return baseSize * 1.4 // 일부 FontType은 1.4배로 조정
        case .YeongdeokSea:
            return baseSize * 1.2 // 일부 FontType은 1.2배로 조정
        default:
            return baseSize // 다른 폰트 타입은 기본 크기
        }
    }
    
  
    
}
