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
    @Published var locationsHandler = LocationsHandler.shared
    
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
    func fetchFollowState(userId: String) async {
        self.isFollowingUser = await AuthService.shared.followCheck(with: userId)
    }
    
    func fetchFollowAndUnfollowOtherUser(otherUser: User) {
        Task { @MainActor in 
            if self.isFollowingUser {
                AuthService.shared.userUnFollow(followUser: otherUser) { error in
                    if let error = error {
                        print(error.localizedDescription)
                        print("언팔로잉 에러")
                    } else {
                        print("언팔로잉")
                    }
                }
            } else {
                AuthService.shared.userFollow(followUser: otherUser) { error in
                    if let error = error {
                        print(error)
                        print("팔로잉 에러")
                    } else {
                        print("팔로잉")
                    }
                }
            }
            
            if let otherUserID = otherUser.id {
                self.isFollowingUser = await AuthService.shared.followCheck(with: otherUserID)
                print("좋아요 반영, \(otherUserID)")
            } else {
                print("좋아요 반영 실패")
            }
        }
    }
}
