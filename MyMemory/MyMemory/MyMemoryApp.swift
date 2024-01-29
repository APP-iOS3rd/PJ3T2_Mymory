//
//  MyMemoryApp.swift
//  MyMemory
//
//  Created by 김태훈 on 1/2/24.
//

import SwiftUI
import FirebaseCore
import KakaoSDKAuth
import KakaoSDKCommon

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
            return AuthController.handleOpenUrl(url: url)
        }
        return false
    }
}

@main
struct MyMemoryApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  
    init() {
        
    }
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(AuthViewModel.shared)
        }
        
    }
}



