//  AuthService.swift
//  MyMemory
//
//  Created by 김태훈 on 2/5/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import KakaoSDKAuth
import KakaoSDKUser
import Combine
final class AuthService: ObservableObject {
    static let shared = AuthService()
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var isCurrentUserLoginState: Bool
    @Published var followerCount: Int = 0
    @Published var followingCount: Int = 0
    @Published var isFollow: Bool = false
 
    
    let storage = Storage.storage()
    
    init() {
        if let session = Auth.auth().currentUser {
            self.userSession = session
            self.isCurrentUserLoginState = true
        } else {
            self.isCurrentUserLoginState = false
            self.userSession = nil
            self.fetchUser { user in
                self.currentUser = user
                self.isCurrentUserLoginState = true
            }
        }
        UserApi.shared.unlink {(error) in
            if let error = error {
                print(error)
            }
            else {
                print("unlink() success.")
            }
        }
    }
    func signout() -> Bool{
        self.userSession = nil
        do {
            try Auth.auth().signOut()
            self.fetchUser()
            return true
        } catch {
            return false
        }
    }
    func checkUser(userID: String) async -> Bool {
        do {
            let querySnapshot = try await Firestore.firestore().collection("users")
                .whereField("id", isEqualTo: userID).getDocuments()
            if querySnapshot.isEmpty {
                return true
            } else {
                return false
            }
        } catch {
            return true
        }
    }
    func fetchUser() {
        guard let uid = userSession?.uid else {
            UserDefaults.standard.removeObject(forKey: "userId")
            return }
        print("현재 로그인 상태: uid \(uid)")
        COLLECTION_USERS.document(uid).getDocument { [weak self] snapshot, _ in
            guard let user = try? snapshot?.data(as: User.self) else { return }
            self?.currentUser = user
            UserDefaults.standard.set(user.id, forKey: "userId")
            // print(user)
        }
    }
    
    func fetchUser(completion: @escaping (User?) -> Void) {
        guard let uid = userSession?.uid else {
            completion(nil)
            return
        }
        print("AuthService : 현재 로그인 상태: uid \(uid)")
        
        COLLECTION_USERS.document(uid).getDocument { snapshot, error in
            guard let snapshot = snapshot, snapshot.exists else {
                completion(nil)
                return
            }
            
            do {
                if let user = try? snapshot.data(as: User.self) {
                    UserDefaults.standard.set(user.id, forKey: "userId")
                    completion(user)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    
    /// 사용자의 메모 개수, 사진 개수를 가져오는 메서드 입니다.
    /// - Parameters:
    ///   - uid : 메모 개수, 사진 개수를 가져올 사용자의 uid
    /// - Returns: (Int, Int) : 메모 개수, 사진 개수
    func countUserData(uid: String) async -> (Int, Int) {
        var memoCount = 0
        var imageCount = 0
        
        do {
            let snapshot = try await COLLECTION_MEMOS.whereField("userUid", isEqualTo: uid).getDocuments()
            let documents = snapshot.documents
            
            if documents.isEmpty {
                print("documents.isEmpty \(documents.count)")
            }
            
            memoCount = documents.count
            
            print("Number of documents: \(documents.count)")
            
            var totalImageUUIDCount = 0
            for document in documents {
                if let memoImageUUIDs = document["memoImageUUIDs"] as? [String] {
                    totalImageUUIDCount += memoImageUUIDs.count
                }
            }
            
            imageCount = totalImageUUIDCount
        } catch {
            print("Memo 이미지 UUID 개수를 계산하는 중에 오류가 발생했습니다: \(error)")
        }
        
        return (memoCount, imageCount)
    }

    
    /// 메모 작성자의 정보를 가져오는 함수 입니다
    /// - Parameters:
    ///   - uid : Memo Model 안에 있는 작성자 uid를 입력 받습니다.
    /// - Returns: 해당 uid를 가지고 작성자 정보를 표시해주기 위해 User Model을 반환합니다.
    func memoCreatorfetchUser(uid: String, completion: @escaping (User?) -> Void) {
        print("현재 메모 작성자: uid \(uid)")
        
        COLLECTION_USERS.document(uid).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let memoCreator = try? snapshot?.data(as: User.self) else {
                completion(nil)
                return
            }
            
            completion(memoCreator)
        }
    }
    /// 메모 작성자의 정보를 가져오는 함수 입니다
    /// - Parameters:
    ///   - uid : Memo Model 안에 있는 작성자 uid를 입력 받습니다.
    /// - Returns: 해당 uid를 가지고 작성자 정보를 표시해주기 위해 User Model을 반환합니다.
    func memoCreatorfetchProfile(uid: String) async -> Profile?  {
        do {
            let document = try await COLLECTION_USERS.document(uid).getDocument()
            if document.exists {
                guard let memoCreator = try? document.data(as: User.self) else {
                    return nil
                }
                var profile: Profile = memoCreator.toProfile
                if let id = profile.id {
                    profile.memoCount = await self.fetchUserMemoCount(with: id)
                    profile.followerCount = await self.fetchUserFollowerCount(with: id)
                    profile.followingCount = await self.fetchUserFollowingCount(with: id)
                    profile.pinCount = await self.pinnedCount()
                    profile.isFollowing = await self.followCheck(with: id)
                }
                return profile
            } else {return nil}
        } catch {
            return nil
        }
    }
    /// 메모 작성자의 프로필 이미지 URL를 가져오는 함수 입니다
    /// - Parameters:
    ///   - uid : Memo Model 안에 있는 작성자 uid를 입력 받습니다.
    /// - Returns: 해당 uid를 가지고 작성자 정보를 표시해주기 위해 User Model의 profilePicture값을 반환합니다.
    func getProfileImg(uid: String) async -> String {
        do {
            let profile = await memoCreatorfetchProfile(uid: uid)
            return profile?.profilePicture ?? ""
        } catch {
            print("An error occurred: \(error)")
            return ""
        }
    }
    
    /// 메모 작성자의 정보를 가져오는 함수 입니다
    /// - Parameters:
    ///   - uid : Memo Model 안에 있는 작성자 uid를 입력 받습니다.
    /// - Returns: 해당 uid를 가지고 작성자 정보를 표시해주기 위해 User Model을 반환합니다.
    func memoCreatorfetchProfiles(memos: [Memo]) async -> [Profile]  {
        var profileList: [Profile] = []
        for id in memos.map({$0.userUid}) {
            if let profile = await memoCreatorfetchProfile(uid: id) {
                profileList.append(profile)
            }
        }
        return profileList
    }
    func fetchUserFollowerCount(with id: String) async -> Int {
        do {
            let document = try await COLLECTION_USER_Followers.document(id).getDocument()
            
            if document.exists {
                let fieldCount = document.data()?.count ?? 0
                return fieldCount
            } else { return 0 }
        } catch {
            print("에러 발생: \(error)")
            return 0
        }
    }
    func fetchUserFollowingCount(with id: String) async -> Int {
        do {
            let document = try await COLLECTION_USER_Following.document(id).getDocument()
            
            if document.exists {
                let fieldCount = document.data()?.count ?? 0
                return fieldCount
            } else { return 0 }
        } catch {
            print("에러 발생: \(error)")
            return 0
        }
    }
    func fetchUserMemoCount(with id: String) async -> Int {
        do {
            let documents = try await COLLECTION_MEMOS.whereField("userUid", isEqualTo: id).getDocuments()
            return documents.documents.count
        } catch {
            print("에러 발생: \(error)")
            return 0
        }
    }
    func followerCheck(uid: String) async -> Int {
        var count = 0
        do {
            let document = try await COLLECTION_USER_Followers.document(uid).getDocument()
            
            if document.exists {
                count = document.data()?.count ?? 0
            }
            return count
        } catch {
            return 0
        }
    }
    func followingCheck(uid: String) async -> Int {
        var count = 0
        do {
            let document = try await COLLECTION_USER_Following.document(uid).getDocument()
            
            if document.exists {
                count = document.data()?.count ?? 0
            }
            return count
        } catch {
            return 0
        }
    }
    /// 팔로우, 팔로잉을 카운트 하는 함수
    /// - Parameters:
    ///   - user : following, follower 숫자를 알고 싶은 사용자를 넣어줍니다.
    /// - Returns: 반환 값은 따로 없으며 카운트된 숫자를 @Published로
    ///            View에 연결하여 각각의 사용자의 following, follower 숫자를 바로바로 표시할 수 있습니다.
    func followAndFollowingCount(user: User) async -> Void {
        guard let userID = user.id else { return }
        // 메인 스레드에서 UI 업데이트
        DispatchQueue.main.async {
            self.followingCount = 0
            self.followerCount = 0
        }
        
        do {
            let document = try await COLLECTION_USER_Following.document(userID).getDocument()
            
            if document.exists {
                let fieldCount = document.data()?.count ?? 0
                // 메인 스레드에서 UI 업데이트
                DispatchQueue.main.async {
                    self.followingCount = fieldCount
                }
                
            }
        } catch {
            print("에러 발생: \(error)")
        }
        
        do {
            let document = try await COLLECTION_USER_Followers.document(userID).getDocument()
            
            if document.exists {
                let fieldCount = document.data()?.count ?? 0
                DispatchQueue.main.async {
                    self.followerCount = fieldCount
                }
            }
        } catch {
            print("에러 발생: \(error)")
        }
    }
    /// 앱을 나갔다 들어와도, 재부팅 해도 내가 팔로우한 사용자를 체크 할 수 있는 메서드입니다.
    /// - Parameters:
    ///   - followUser : 팔로우한 사용자인지 확인할 사용자 객체를 넣어주면 됩니다.
    /// - Returns: 팔로우 했었다면 true 을 팔로우 하지 않았다면 false를 반환하여 View 쪽에서 팔로우 버튼의 UI를 변경합니다.
    func followCheck(followUser: User , completion: @escaping (Bool?) -> Void){
        guard let uid = Auth.auth().currentUser?.uid else {
            DispatchQueue.main.async {
                self.isFollow = false
            }
            return
        }
        
        guard let followUserID = followUser.id else {
            completion(nil)
            return
        }
        
        let userFollowRef = COLLECTION_USER_Following.document(uid)
        userFollowRef.getDocument { (document, error) in
            if let error = error {
                print("사용자 팔로우 문서를 가져오는 중 오류가 발생했습니다: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isFollow = false
                }
                return
            }
            
            if let document = document, document.exists, let dataArray = document.data() as? [String: String] {
                
                if dataArray.keys.contains(followUserID) {
                    DispatchQueue.main.async {
                        self.isFollow = true
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isFollow = false
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.isFollow = false
                }
            }
            
        }
    }
    /// 앱을 나갔다 들어와도, 재부팅 해도 내가 팔로우한 사용자를 체크 할 수 있는 메서드입니다.
    /// - Parameters:
    ///   - id : UUID
    /// - Returns: 팔로우 했었다면 true 을 팔로우 하지 않았다면 false를 반환하여 View 쪽에서 팔로우 버튼의 UI를 변경합니다.
    func followCheck(with id: String , completion: @escaping (Bool?) -> Void){
        guard let uid = Auth.auth().currentUser?.uid else {
            DispatchQueue.main.async {
                self.isFollow = false
            }
            return
        }
        let followUserID = id
        
        let userFollowRef = COLLECTION_USER_Following.document(uid)
        userFollowRef.getDocument { (document, error) in
            if let error = error {
                print("사용자 팔로우 문서를 가져오는 중 오류가 발생했습니다: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isFollow = false
                    completion(false)
                }
                return
            }
            
            if let document = document, document.exists, let dataArray = document.data() as? [String: String] {
                
                if dataArray.keys.contains(followUserID) {
                    DispatchQueue.main.async {
                        self.isFollow = true
                        completion(true)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isFollow = false
                        completion(false)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.isFollow = false
                    completion(false)
                    
                }
            }
            
        }
    }
    func followCheck(with id: String) async -> Bool{
        guard let uid = Auth.auth().currentUser?.uid else {
            DispatchQueue.main.async {
                self.isFollow = false
            }
            return false
        }
        let followUserID = id
        
        do {
            let userFollowRef = try await COLLECTION_USER_Following.document(uid).getDocument()
            if userFollowRef.exists {
                if let dataArray = userFollowRef.data() as? [String: String] {
                    return dataArray.keys.contains(followUserID)
                }
                return false
            } else {return false}
        } catch {
            return false
        }
    }
    /// 사용자를 팔로우 하는 함수입니다.
    /// - Parameters:
    ///   - followUser : 팔로우할 사용자를 넣어주면 됩니다.
    /// - Returns: 에러를 반환 합니다.
    func userFollow(followUser: User , completion: @escaping (Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "Auth Error", code: 401, userInfo: nil))
            return
        }
        guard let fid = followUser.id else {
            completion(NSError(domain: "Wrong User", code: 400, userInfo: nil))
            return
        }
        COLLECTION_USER_Following.document(uid).setData([String(fid) : "followUserUid"], merge: true)
        COLLECTION_USER_Followers.document(fid).setData([uid : "followingUserUid"], merge: true)
        
        DispatchQueue.main.async {
            self.isFollow = true
        }
        
    }
    func userFollow(followUser: Profile , completion: @escaping (Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "Auth Error", code: 401, userInfo: nil))
            return
        }
        guard let fid = followUser.id else {
            completion(NSError(domain: "Wrong User", code: 400, userInfo: nil))
            return
        }
        COLLECTION_USER_Following.document(uid).setData([String(fid) : "followUserUid"], merge: true)
        COLLECTION_USER_Followers.document(fid).setData([uid : "followingUserUid"], merge: true)
        
        DispatchQueue.main.async {
            self.isFollow = true
        }
        
    }
    
    /// 사용자를 언팔로우 하는 함수입니다.
    /// - Parameters:
    ///   - followUser : 언팔로우할 사용자를 넣어주면 됩니다.
    /// - Returns: 에러를 반환 합니다.
    func userUnFollow(followUser: User , completion: @escaping (Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "Auth Error", code: 401, userInfo: nil))
            return
        }
        
        guard let fid = followUser.id else {
            completion(NSError(domain: "Wrong User", code: 400, userInfo: nil))
            return
        }
        COLLECTION_USER_Following.document(uid).updateData([String(fid) : FieldValue.delete()])
        COLLECTION_USER_Followers.document(fid).updateData([uid : FieldValue.delete()])
        
        DispatchQueue.main.async {
            self.isFollow = false
        }
    }
    func userUnFollow(followUser: Profile , completion: @escaping (Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "Auth Error", code: 401, userInfo: nil))
            return
        }
        
        guard let fid = followUser.id else {
            completion(NSError(domain: "Wrong User", code: 400, userInfo: nil))
            return
        }
        COLLECTION_USER_Following.document(uid).updateData([String(fid) : FieldValue.delete()])
        COLLECTION_USER_Followers.document(fid).updateData([uid : FieldValue.delete()])
        
        DispatchQueue.main.async {
            self.isFollow = false
        }
    }
    func pinnedCount() async -> Int {
        guard let user = self.currentUser else { return 0}
        
        var count = 0
        do {
            let document = try await COLLECTION_MEMOS
                .whereField("userUid", isEqualTo: user.id)
                .getDocuments()
            count = document.documents.filter{doc in
                doc["isPinned"] as? Bool ?? false
            }.count
        } catch {
            return 0
        }
        return count
    }
    func pinMyMemo(with memo: Memo) async {
        guard let memoID = memo.id else {return}
        do {
            try await COLLECTION_MEMOS.document(memoID).updateData(["isPinned": memo.isPinned])
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// 사용자의 프로필사진을 제거하는 메서드입니다.
    /// - Parameters:
    ///     - uid: 사용자의 UID값입니다.
    /// - Returns: 삭제에 성공하거나, 삭제할 프로필 사진이 없는 경우 .success(true)값을 반환하고, 삭제에 실패할 경우 .failure(.deleteUserProfileImage)를 반환합니다.
    func removeUserProfileImage(uid: String) async -> Result<Bool, ProfileEditErrorType> {
        let userRef = COLLECTION_USERS.document(uid)
        let storageRef = storage.reference()
        var deleteImageURL: String?
        
        do {
            let user = try await userRef.getDocument()
            if user.exists {
                deleteImageURL = user["profilePicture"] as? String
            }
            
            if let deleteImage = deleteImageURL, !deleteImage.isEmpty {
                let deleteImageRef = storageRef.child("profile_images/\(deleteImage.getProfileImageUID())")
                do {
                    try await deleteImageRef.delete()
                    return .success(true)
                } catch {
                    return .failure(.deleteUserProfileImage)
                }
            }
            // 삭제할 이미지가 없는 경우(프로필 사진을 설정하지 않았던 경우)
            return .success(true)
        } catch {
            return .failure(.deleteUserProfileImage)
        }
    }
}
