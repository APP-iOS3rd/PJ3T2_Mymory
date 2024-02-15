//
//  ThemeManager.swift
//  MyMemory
//
//  Created by 김소혜 on 2/13/24.
//

import Foundation
import SwiftUI
import Combine

enum ThemeType: String {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
}

final class ThemeManager: ObservableObject {
    
    static let shared = ThemeManager()
    @Published var userThemePreference: ThemeType?
    
    init(){
        self.userThemePreference = loadThemePreference()
    }
    
    func saveThemePreference(themeType: ThemeType) {
        UserDefaults.standard.set(themeType.rawValue, forKey: "selectedThemeType")
        
    }
    
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
    
    
}
