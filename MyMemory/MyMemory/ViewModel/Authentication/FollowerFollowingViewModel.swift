//
//  FollowerFollowingViewModel.swift
//  MyMemory
//
//  Created by 정정욱 on 2/19/24.
//

import SwiftUI

class FollowerFollowingViewModel: ObservableObject {
    
    @Published var followerUserList: [User] = []
    @Published var followingUserList: [User] = []
    
    init() {}
    
    
    func fetchFollowingUserList(with id: String) async -> Void {
        
        do {
            let document = try await COLLECTION_USER_Following.document(id).getDocument()
            
            if document.exists {
                var userList: [User] = []
                
                for (documentID, userData) in document.data() ?? [:] {
                    // 문서 ID 값을 이용하여 users 컬렉션에서 해당 사용자의 데이터 가져오기
                    let userDocument = try await COLLECTION_USERS.document(documentID)
                        
                        
                        .getDocument()
                        
                    
                    if let userData = userDocument.data() {
                        // User 객체 생성 및 데이터 매핑
                        let user = User(
                            email: userData["email"] as! String,
                            id: userData["id"] as! String,
                            name: userData["name"] as? String ?? "",
                            profilePicture: userData["profilePicture"] as? String
                            // 필요한 다른 속성들을 추가로 매핑
                        )
                        
                        userList.append(user)
                    }
                }
                
                // 메인 스레드에서 UI 업데이트
                DispatchQueue.main.async {
                    self.followingUserList = userList
                }
            }
        } catch {
            print("에러 발생: \(error)")
        }
    }
    
    func fetchFollowerUserList(with id: String) async -> Void {
        //guard let userID = user.id else { return }
        
        do {
            let document = try await COLLECTION_USER_Followers.document(id).getDocument()
            
            if document.exists {
                var userList: [User] = []
                
                for (documentID, userData) in document.data() ?? [:] {
                    // 문서 ID 값을 이용하여 users 컬렉션에서 해당 사용자의 데이터 가져오기
                    let userDocument = try await COLLECTION_USERS.document(documentID).getDocument()
                    
                    if let userData = userDocument.data() {
                        // User 객체 생성 및 데이터 매핑
                        let user = User(
                            email: userData["email"] as! String,
                            id: userData["id"] as! String,
                            name: userData["name"] as? String ?? "",
                            profilePicture: userData["profilePicture"] as? String
                            // 필요한 다른 속성들을 추가로 매핑
                        )
                        
                        userList.append(user)
                    }
                }
                
                // 메인 스레드에서 UI 업데이트
                DispatchQueue.main.async {
                    self.followerUserList = userList
                }
            }
        } catch {
            print("에러 발생: \(error)")
        }
    }

}
