//
//  SettingViewModel.swift
//  MyMemory
//
//  Created by 이명섭 on 1/16/24.
//

import Foundation
import FirebaseAuth

class SettingViewModel: ObservableObject {
    @Published var version: String = ""
    @Published var isCurrentUserLoginState: Bool = false
    @Published var isShowingLogoutAlert = false
    @Published var isShowingWithdrawalAlert = false
    
    init() {
        self.version = fetchCurrentAppVersion()
        self.isCurrentUserLoginState = fetchCurrentUserLoginState()
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
                self.isCurrentUserLoginState = false
                completion()
                print("로그아웃")
            } catch {
                print("ERROR: 로그아웃 에러 \(error.localizedDescription)")
            }
        } else {
            print("로그인 상태가 아님")
        }
    }
    
    func fetchUserWithdrawal(completion: @escaping () -> Void) {
        if let user = Auth.auth().currentUser {
            user.delete { error in
                if let error = error {
                    print("ERROR: 회원탈퇴 \(error.localizedDescription)")
                } else {
                    self.isCurrentUserLoginState = false
                    completion()
                    print("회원탈퇴 성공")
                }
            }
        } else {
            print("로그인 상태가 아님")
        }
    }
}
