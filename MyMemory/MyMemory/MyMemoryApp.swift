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
import GoogleSignIn
import GoogleSignInSwift

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self

        return true
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
            return AuthController.handleOpenUrl(url: url)
        } else if (GIDSignIn.sharedInstance.handle(url)) {
            return GIDSignIn.sharedInstance.handle(url)
        }

        return false
    }
}
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    /// Notification 수신하는 부분입니다. 이 부분에서는 Memo uuid를 활용해서 다시 하나의 메모만 fetch해서 넘겨줍니다.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let id = response.notification.request.identifier
        do {
            if let memo = try await MemoService.shared.fetchMemo(id: id) {
                print(memo.description)
                PushNotification.shared.memo = memo
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
@main
struct MyMemoryApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        KakaoSDK.initSDK(appKey: Bundle.main.object(forInfoDictionaryKey: "KAKAO_APP_KEY") as! String)
    }
    var body: some Scene {
        WindowGroup {
            MainView()
                .onOpenURL { url in
                    if (AuthApi.isKakaoTalkLoginUrl(url)) {
                        _ = AuthController.handleOpenUrl(url: url)
                    } else if (GIDSignIn.sharedInstance.handle(url)) {
                        GIDSignIn.sharedInstance.handle(url)
                    }
                }
        }
        
    }
}



