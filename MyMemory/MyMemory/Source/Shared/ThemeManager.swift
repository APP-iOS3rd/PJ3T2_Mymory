//
//  ThemeManager.swift
//  MyMemory
//
//  Created by 김소혜 on 2/13/24.
//

import Foundation
import SwiftUI
import Combine

enum ThemeType: String, CaseIterable, Codable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    case atom = "Atom"
    case sea = "Sea"
    case earth = "Earth"
    case nord = "Nord"
    case box = "Box"
    // 각 테마 유형별로 속성 정의
    var isSelected: Bool {
        // 여기서 현재 선택된 테마와 비교하여 반환할 수 있음
        // 예: UserDefaults 등을 사용하여 현재 선택된 테마 저장 및 비교
//        if ThemeManager.shared.userThemePreference   {
//           return true
//        }
        return false
    }
      
    var isPremium: Bool {
          // 테마별 프리미엄 여부 설정
          switch self {
          case .system:
              return false
          case .light:
              return false
          case .dark:
              return false
          default:
              return true
          }
    }
      
    var textColor: Color {
          // 테마별 텍스트 색상 설정
          switch self {
          case .system:
              return Color.textColor // 기본 색상이나 시스템 색상 사용
          case .light:
              return Color.black
          case .dark:
              return Color.white
          case .atom:
              return Color.atomTextColor
          case .sea:
              return Color(hex:"00EFB0")
          case .earth:
              return Color(hex: "FF8441")
          case .nord:
              return Color(hex: "5C85A5")
          case .box:
              return Color(hex:"3D3836")
          }
      }
      
    var bgColor: Color {
        // 테마별 배경 색상 설정
        switch self {
        case .system:
            return Color.bgColor // 기본 색상이나 시스템 색상 사용
        case .light:
            return Color.white
        case .dark:
            return Color.black
        case .atom:
            return Color.atomBgColor
        case .sea:
            return Color(hex: "1B2630")
        case .earth:
            return Color(hex: "24242F")
        case .nord:
            return Color(hex: "272E39")
        case .box:
            return Color(hex:"FAF5D4")
        }
    }
    
    var borderColor: Color {
        switch self {
        case .system:
            return Color(hex:"E9E9E9")
        case .light:
            return Color(hex:"E9E9E9")
        case .sea:
            return Color(hex:"6CB8FC")
        case .earth:
            return Color(hex: "AAAACD")
        case .nord:
            return Color(hex: "60BACA")
        case .box:
            return Color(hex:"D7A452")
        default:
            return Color.lightGray
        }
    }
   
    // 필요에 따라 더 많은 속성이나 메소드를 추가할 수 있음
    
}

final class ThemeManager: ObservableObject {
    
    static let shared = ThemeManager()
    @Published var userThemePreference: ThemeType?
    @Published var currentTheme: ThemeType?
    
    var themeList = ThemeType.allCases
    var systemThemeList:[ThemeType] = [.system, .light,.dark]
    
    init(){
        self.userThemePreference = loadThemePreference()
    }
    
    // currentTheme에 ThemeType임시저장하여 넘겨주기 위해
    func setTheme(themeType: ThemeType) -> ThemeType {
        
        return themeType
    }
    
    func getTheme(themeData: ThemeType) -> ThemeType {
        return themeData
    }
    
    // UserDefault에 저장되는 경우고
    func saveThemePreference(themeType: ThemeType) {
        UserDefaults.standard.set(themeType.rawValue, forKey: "selectedThemeType")
     
    }
    
    func changeDarkmode(){
        
    }
    
//
    func loadThemePreference() -> ThemeType {
        guard let themeTypeString = UserDefaults.standard.string(forKey: "selectedThemeType"),
              let themeType = ThemeType(rawValue: themeTypeString) else {
            return .system
        }
        return themeType
    }
    
    var themePreference: ThemeType {
        get {
            guard let themeTypeString = UserDefaults.standard.string(forKey: "selectedThemeType"),
                  let themeType = ThemeType(rawValue: themeTypeString) else {
                return .system // 기본값으로 Regular 반환
            }
            return themeType
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "selectedThemeType")
            
            // userFontPreference도 함께 업데이트하여 @Published를 통해 변경 사항을 반영합니다.
           DispatchQueue.main.async {
               self.userThemePreference = newValue
           }
        }
    }
//    
    func changeTheme(to selectedTheme:ThemeType) {
        // UserDefaults를 사용하여 선택된 테마 저장
        saveThemePreference(themeType: selectedTheme)
       //  선택된 테마를 @Published 프로퍼티에 반영하여 UI 업데이트 트리거
        userThemePreference = selectedTheme
    }
    
    // 현재 선택된 테마가 주어진 테마와 같은지 확인하는 메서드
     func isThemeSelected(_ theme: ThemeType) -> Bool {
         return currentTheme == theme
     }
    
}
