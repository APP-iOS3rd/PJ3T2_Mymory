//
//  User.swift
//  MyMemory
//
//  Created by 김소혜 on 1/22/24.
//

import FirebaseFirestore
import Firebase

// viewModel
struct User: Identifiable, Decodable {
    let email: String
    @DocumentID var id: String?
    let name: String
    var profilePicture: String?
    
    var isCurrentUser: Bool {
        return AuthService.shared.userSession?.uid == id
    }
    var toProfile: Profile {
        return Profile(email: self.email,
                       id: self.id,
                       name: self.name,
                       followerCount: 0,
                       memoCount: 0,
                       isFollowing: false)
    }
}
struct Profile: Identifiable, Decodable {
    let email: String
    @DocumentID var id: String?
    let name: String
    var profilePicture: String?
    var followerCount: Int
    var memoCount: Int
    var isFollowing: Bool
    var isCurrentUser: Bool {
        return AuthService.shared.userSession?.uid == id

    }
}
