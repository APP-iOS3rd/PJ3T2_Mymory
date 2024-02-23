//
//  User.swift
//  MyMemory
//
//  Created by 김소혜 on 1/22/24.
//

import FirebaseFirestore
import Firebase

// viewModel
struct User: Identifiable, Decodable, Equatable {
    let email: String
    @DocumentID var id: String?
    let name: String
    var profilePicture: String?
    
    var isCurrentUser: Bool {
        return AuthService.shared.userSession?.uid == id
    }
    var toProfile: Profile {
        Task {
            if let id = self.id {
                var followerCount = await AuthService.shared.fetchUserFollowerCount(with: id)
                var memoCount = await AuthService.shared.fetchUserMemoCount(with: id)
                var followingCount = await AuthService.shared.fetchUserFollowingCount(with: id)
                
            }
        }
        return Profile(email: self.email,
                       id: self.id,
                       name: self.name,
                       profilePicture: self.profilePicture,
                       followerCount: 0, followingCount: 0,
                       memoCount: 0, pinCount: 0,
                       isFollowing: false)
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
         // == 연산자를 구현하여 두 User 인스턴스 간의 동등성을 판단
         return lhs.id == rhs.id // 예시로 id를 기준으로 판단
    }
    /*
     User 타입에 Equatable을 채택하고, == 연산자를 구현하여 id 속성을 기준으로 두 인스턴스 간의 동등성을 판단하도록 했습니다. (사용자별 프로필뷰를 넘어갈때 사용하기 위함)
     실제로 사용하는 속성에 따라 적절한 비교를 구현하시면 됩니다.
     */
}
struct Profile: Identifiable, Decodable, Hashable {
    let email: String
    @DocumentID var id: String?
    let name: String
    var profilePicture: String?
    var followerCount: Int
    var followingCount: Int
    var memoCount: Int
    var pinCount: Int
    var isFollowing: Bool
    var isCurrentUser: Bool {
        return AuthService.shared.userSession?.uid == id
    }
    var toUser: User {
        return User(email: self.email,
                    id: self.id,
                    name: self.name,
                    profilePicture: self.profilePicture)
    }
}
enum ProfileEditErrorType: Error {
    case changeUserName
    case uploadUserProfileImage
    case updateProfileImage
    case deleteUserProfileImage
    case invalidImageData
    case imageCompressionFail
}
