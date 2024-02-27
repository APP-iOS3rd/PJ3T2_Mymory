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
    @Published var currentFont: FontType?
    
    var fontList = FontType.allCases
    
    init() {
    }
    
    func setFont(fontData: FontType) -> FontType {
        return fontData
    }
  
    func getFont(fontData: FontType) -> FontType {
        return fontData
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

    // 현재 선택된 폰트마가 주어진 폰트와 같은지 확인하는 메서드
     func isFontSelected(_ font: FontType) -> Bool {
         return currentFont == font
     }
    
}
