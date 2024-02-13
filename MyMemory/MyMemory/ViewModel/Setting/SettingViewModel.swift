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

class SettingViewModel: ObservableObject {
    @Published var version: String = "1.0.0"
    @Published var isCurrentUserLoginState: Bool = false
    @Published var isShowingLogoutAlert = false
    @Published var isShowingWithdrawalAlert = false
    
    let db = Firestore.firestore()
    
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
    
    /// 사용자의 모든 기록을 지우는 메서드
    /// - Parameters:
    ///   - uid : 모든 기록을 삭제할 현재 사용자 uid 값
    /// - Returns: 없음
    func removeUserAllData(uid: String) {
        /*
           Memos - 사용자가 작성한 메모 지우기
           Memo-likes - 사용자가 작성한 메모 좋아요, 기록 지우기
           User-likes - 사용자가 좋아요. 누른 기록 지우기
           User-Following - 사용자가 팔로잉하는 목록 지우기
           User-Followers - 사용자를 팔로우하는 목록 지우기
           users - 사용자 지우기
           Authentication - 사용자 인증 기록 지우기
         
         */
        
        self.removeMemoData(uid: uid)
        self.removeUserLikes(uid: uid)
        self.removeUserFollowingAndFollowData(uid: uid)
        self.removeUser(uid: uid)
        
        // Authentication 계정 삭제
        if let currentUser = Auth.auth().currentUser {
            currentUser.delete { error in
                if let error = error {
                    print("사용자 삭제 실패: \(error.localizedDescription)")
                } else {
                    print("사용자 삭제 성공")
                }
            }
        } else {
            print("현재 로그인된 사용자가 없습니다.")
        }
        self.fetchUserLogout {
           
        }
      
    }

    /// 사용자가 작성한 메모, 좋아요 누른 메모 기록 지우기
    /// - Parameters:
    ///   - uid : 모든 기록을 삭제할 현재 사용자 uid 값
    /// - Returns: 없음
    /*
     동작 원리
       1. 내 메모 지우기전 Storage에 저장된 메모 이미지 지우기
       2. 매모 삭제
       3. 내 메모 좋아요 기록 지우기
       4. 내가 다른 메모에 누른 좋아요 기룩 지우기
     */
    func removeMemoData(uid: String) {

        // Memos 컬렉션에서 문서를 가져와서 조건을 확인하고 삭제
        COLLECTION_MEMOS.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }

            // Memos 컬렉션의 각 문서에 대해 조건 확인 후 삭제
            for document in documents {
                // 문서의 데이터 가져오기
                let data = document.data()

                // 데이터 중 userUid 필드와 주어진 uid가 일치하는지 확인
                if let userUid = data["userUid"] as? String, userUid == uid {
                    // 일치하는 경우 해당 문서 삭제
                    let memoID = document.documentID
                    if let memoImageUUIDs = data["memoImageUUIDs"] as? [String] {
                        // 메모 이미지 UUIDs를 deleteImage 함수에 전달하여 이미지 삭제
                        MemoService.shared.deleteImage(deleteMemoImageUUIDS: memoImageUUIDs)
                    }

                    COLLECTION_MEMOS.document(memoID).delete { error in
                        if let error = error {
                            print("Error removing Memo document: \(error)")
                        } else {
                            print("Memo document successfully removed!")

                            // Memo-likes 컬렉션에서도 해당 Memo에 대한 문서 삭제
                            self.removeMemoLikes(memoID: memoID)
                        }
                    }
                }
            }
        }
        
        
        // 내가 다른 메모에 누른 좋아요 기룩 삭제
        COLLECTION_MEMO_LIKES.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting Memo Likes documents: \(error)")
                return
            }
            
            guard let memoLikesDocuments = snapshot?.documents else {
                print("No Memo Likes documents found")
                return
            }
            
            
            // 별도 분리 필요 위에는 메모 삭제할때이고 사용자 uid 값으로 파악하고 지워야함
            // Memo Likes 컬렉션의 각 문서에서 memoID 필드 삭제 또는 문서 삭제
            for memoLikesDocument in memoLikesDocuments {
                let documentData = memoLikesDocument.data()
                
                // 마지막 필드인 경우 문서 삭제
                print("documentData : \(documentData)")
                print("uid : \(uid)")
                
                if documentData.count == 1 && documentData.contains(where: { $0.key == uid }) {
                    memoLikesDocument.reference.delete { error in
                        if let error = error {
                            print("Error deleting Memo Likes document: \(error)")
                        } else {
                            print("Memo Likes document successfully deleted!")
                        }
                    }
                } else {
                    // 마지막 필드가 아닌 경우 memoID 필드 삭제
                    var updatedData = documentData
                    updatedData.removeValue(forKey: uid)
                    
                    memoLikesDocument.reference.updateData(updatedData) { error in
                        if let error = error {
                            print("Error removing field from Memo Likes document: \(error)")
                        } else {
                            print("Field successfully removed from Memo Likes document!")
                        }
                    }
                }
            }
        }
        
    }


    /// 사용자가 작성한 메모의 받은 좋아요 기록을 삭제하는 메서드
    /// - Parameters:
    ///   - memoID  : 삭제할 사용자가 작성한 메모의 ID
    /// - Returns: 없음
    func removeMemoLikes(memoID: String) {
        
        COLLECTION_MEMO_LIKES.document(memoID).delete { error in
            if let error = error {
                print("Error removing Memo-likes document: \(error)")
            } else {
                print("Memo-likes document successfully removed!")
            }
        }
    }

    

    /// 사용자가 누른 메모 기록을 삭제하는 메서드
    /// - Parameters:
    ///   - uid  : 삭제할 사용자가 누른 메모 기록
    /// - Returns: 없음
    func removeUserLikes(uid: String) {
        // User-likes 컬렉션에서 uid가 일치하는 문서 삭제
        COLLECTION_USER_LIKES.document(uid).delete { error in
            if let error = error {
                print("Error removing Memo-likes document: \(error)")
            } else {
                print("Memo-likes document successfully removed!")
            }
        }
        
    }

    
    

    /// 사용자가 팔로잉한 사용자를 팔로우한 사람들의 데이터를 삭제하는 메서드
    /// - Parameters:
    ///   - uid : 팔로우, 팔로잉 기록을 삭제할 uid
    /// - Returns: 없음
    func removeUserFollowingAndFollowData(uid: String) {
        // User-Following 컬렉션에서 uid가 일치하는 문서 삭제
        COLLECTION_USER_Following.document(uid).delete { error in
            if let error = error {
                print("Error removing Memo-likes document: \(error)")
            } else {
                print("Memo-likes document successfully removed!")
            }
        }
        
        
        
        // User-Followers 컬렉션에서 uid가 일치하는 문서의 필드 삭제 또는 문서 삭제 (필드가 하나 밖에 없다면 필드만 삭제 할 수 없음)
        COLLECTION_USER_Followers.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting Followers documents: \(error)")
                return
            }
            
            guard let followersDocuments = snapshot?.documents else {
                print("No Followers documents found")
                return
            }
            
            // User-Followers 컬렉션의 각 문서에서 uid 필드 삭제 또는 문서 삭제
            for followersDocument in followersDocuments {
                let documentData = followersDocument.data()
                
                // 마지막 필드인 경우 문서 삭제
                if documentData.count == 1 && documentData.contains(where: { $0.key == uid }) {
                    followersDocument.reference.delete { error in
                        if let error = error {
                            print("Error deleting Followers document: \(error)")
                        } else {
                            print("Followers document successfully deleted!")
                        }
                    }
                } else {
                    // 마지막 필드가 아닌 경우 uid 필드 삭제
                    var updatedData = documentData
                    updatedData.removeValue(forKey: uid)
                    
                    followersDocument.reference.updateData(updatedData) { error in
                        if let error = error {
                            print("Error removing field from Followers document: \(error)")
                        } else {
                            print("Field successfully removed from Followers document!")
                        }
                    }
                }
            }
        }
    }


    /// 사용자 삭제 메서드
    /// - Parameters:
    ///   - uid : users 컬렉션에서 사용자 삭제를 위한 메서드
    /// - Returns: 없음 
    func removeUser(uid: String) {
        // users 컬렉션에서 uid와 일치하는 문서를 찾아 삭제
        
        COLLECTION_USERS.document(uid).delete { error in
            if let error = error {
                print("Error removing Memo-likes document: \(error)")
            } else {
                print("Memo-likes document successfully removed!")
            }
        }
    }
}
