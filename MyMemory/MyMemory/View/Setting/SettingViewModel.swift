//
//  SettingViewModel.swift
//  MyMemory
//
//  Created by 이명섭 on 1/16/24.
//

import Foundation

class SettingViewModel: ObservableObject {
    static let shared = SettingViewModel()
    @Published var version: String = ""
    
    init() {
        self.version = fetchCurrentAppVersion()
    }
    
    func fetchCurrentAppVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
        
        return version + "." + bundleVersion
    }
}
