//
//  DetailViewModel.swift
//  MyMemory
//
//  Created by 정정욱 on 1/29/24.

import SwiftUI
import _PhotosUI_SwiftUI
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore


class DetailViewModel: ObservableObject {
    
    @Published var user: User?
    @Published var memoCreator: User?
    @Published var isCurrentUserLoginState = false
    @Published var isFollowingUser = false
    
    //  let db = Firestore.firestore()
    let memoService = MemoService.shared
    
    @Published var currentLocation: CLLocation?  = nil
    var locationsHandler = LocationsHandler.shared
    
    init() {
        // fetchUserState()
        user = AuthService.shared.currentUser // 현 로그인 사용자 가져오기
        AuthService.shared.fetchUser() // 사용자 정보 가져오기
    }
    
    func fetchMemoCreator(uid: String) {
        
        AuthService.shared.memoCreatorfetchUser(uid: uid) { user in
            if let user = user {
                // 성공적으로 유저 정보를 받아온 경우
                self.memoCreator = user
                print("User: \(user)")
            } else {
                // 실패한 경우 또는 에러가 발생한 경우
                
                
                print("Failed to fetch user. Unknown error.")
                
            }
        }
        
        
    }
    
    func fetchUserState() {
        guard let _ = UserDefaults.standard.string(forKey: "userId") else { return }
    }
    
    func fetchCurrentUserLoginState() -> Bool {
        if let _ = Auth.auth().currentUser {
            return true
        }
        return false
    }
    
    func fetchFollowAndUnfollowOtherUser(otherUser: User) {
        Task { @MainActor in 
            if isFollowingUser {
                AuthService.shared.userUnFollow(followUser: otherUser) { error in
                    if let error = error {
                        print(error)
                    }
                }
            } else {
                AuthService.shared.userFollow(followUser: otherUser) { error in
                    if let error = error {
                        print(error)
                    }
                }
            }
            
            if let userID = otherUser.id {
                self.isFollowingUser = await AuthService.shared.checkUser(userID: userID)
            } else {
                print("좋아요 반영 실패")
            }
        }
    }
}
