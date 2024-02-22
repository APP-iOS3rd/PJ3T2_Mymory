//
//  MoveUserProfileViewModel.swift
//  MyMemory
//
//  Created by 김태훈 on 2/22/24.
//

import Foundation
import Combine
import SwiftUI

final class MoveUserProfileViewModel: ObservableObject {
    
    @Published var userProfile: Profile? = nil
    init(userId: String) {
        self.fetchUserProfile(with: userId)
    }
    func fetchUserProfile(with id: String) {
        Task { @MainActor in
            self.userProfile = await AuthService.shared.memoCreatorfetchProfile(uid: id)
            print(userProfile?.name)
        }
    }
    func fetchFollowAndUnfollowOtherUser(otherUser: User) {
        Task { @MainActor in
            if self.userProfile?.isFollowing == true {
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
                fetchUserProfile(with: otherUserID)
                print("좋아요 반영, \(otherUserID)")
            } else {
                print("좋아요 반영 실패")
            }
        }
    }
    
}
