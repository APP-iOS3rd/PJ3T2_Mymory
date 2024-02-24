//
//  SettingViewModel.swift
//  MyMemory
//
//  Created by 이명섭 on 1/16/24.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import UserNotifications

class SettingViewModel: ObservableObject {
    @Published var version: String = "1.0.0"
    @Published var isCurrentUserLoginState: Bool = false
    @Published var isShowingLogoutAlert = false
    @Published var isShowingWithdrawalAlert = false
    @Published var isAblePushNotification: Bool = false
    
    let db = Firestore.firestore()
    
    init() {
        DispatchQueue.main.async {
            self.version = self.fetchCurrentAppVersion()
        }
        self.isCurrentUserLoginState = fetchCurrentUserLoginState()
        Task {
            await self.changeToggleState()
        }
    }
    
    func fetchCurrentAppVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        return version
    }
    
    func fetchCurrentUserLoginState() -> Bool {
        if let _ = Auth.auth().currentUser {
            print("로그인 TRUE")
            return true
        }
        print("로그인 FALSE")
        return false
    }
    
    func fetchUserLogout(completion: () -> Void) {
        if self.isCurrentUserLoginState {
            do {
                try Auth.auth().signOut()

                completion()
                UserDefaults.standard.removeObject(forKey: "userId")
                print("로그아웃")
            } catch {
                print("ERROR: 로그아웃 에러 \(error.localizedDescription)")
            }
        } else {
            print("로그인 상태가 아님")
        }
    }
    
    func fetchUserWithdrawal(uid: String, completion: @escaping () -> Void) {
        if let user = Auth.auth().currentUser {
            user.delete { error in
                if let error = error {
                    print("ERROR: 회원탈퇴 \(error.localizedDescription)")
                } else {
                    Task {
                        do {
                            try await self.db.collection("user").document(uid).delete()
                            print("delete success")
                            UserDefaults.standard.removeObject(forKey: "userId")

                        } catch {
                            print("delete error: \(error)")
                        }
                    }
                    completion()
                    print("회원탈퇴 성공")
                }
            }
        } else {
            print("로그인 상태가 아님")
        }
    }
    
    func checkNotificationPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        switch settings.authorizationStatus {
            case .authorized: return true
            case .provisional: return true
            case .ephemeral: return true
            default: return false
        }
    }
    
    func changeToggleState() async {
        self.isAblePushNotification = await self.checkNotificationPermission()
    }
    
    func moveToNotificationSetting() {
        if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    func moveToOpenSourceLicenseMenu() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
