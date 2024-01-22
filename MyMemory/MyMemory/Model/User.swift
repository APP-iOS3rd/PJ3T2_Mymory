//
//  User.swift
//  MyMemory
//
//  Created by 김소혜 on 1/22/24.
//

import FirebaseFirestore
import Firebase

struct User: Identifiable, Decodable {
    let email: String
    @DocumentID var id: String?
    let name: String
    var profilePicture: String?
    var isCurrentUser: Bool { return RegisterViewModel.shared.userSession?.uid == id }
}
