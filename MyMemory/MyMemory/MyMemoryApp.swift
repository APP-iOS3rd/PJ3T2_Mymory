//
//  MyMemoryApp.swift
//  MyMemory
//
//  Created by 김태훈 on 1/2/24.
//

import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct MyMemoryApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State var initialIdx = 1

    var body: some Scene {
        WindowGroup {
            if #available(iOS 17.0, *) {
                MainTabView(selectedIndex: $initialIdx)
            } else {
                // Fallback on earlier versions
            }
        }
    }
}
 

 
