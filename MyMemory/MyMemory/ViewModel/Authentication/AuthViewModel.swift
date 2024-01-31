//
//  AuthViewModel.swift
//  MyMemory
//
//  Created by 김소혜 on 1/22/24.
//

 
import Foundation
import Photos
import PhotosUI
import SwiftUI
import SafariServices
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import AuthenticationServices
import CryptoKit
import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser

class AuthViewModel: ObservableObject {

    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    static let shared = AuthViewModel()
    
    @Published var email: String = ""
    @Published var password : String = ""
    @Published var name: String = ""
    
    @Published var emailValid : Bool = true
    @Published var passwordValid : Bool = true
    
    @Published var agreeAllBoxes: Bool = false
    @Published var overFourteenBox: Bool = false
    @Published var termsOfUseBox: Bool = false
    @Published var privacyPolicyBox: Bool = false
    
    @Published var selectedItem: PhotosPickerItem? = nil
    @Published var imageSelected: Bool = false
    @Published var selectedImageData: Data? = nil
    
    @Published var showPrivacyPolicy = false
    @Published var showTermsOfUse = false
    @Published var privacyPolicyUrlString = "https://www.notion.so/12bd694d0a774d2f9c167eb4e7976876?pvs=4"
    @Published var termsOfUseUrlString = "https://www.naver.com"
    
    @Published var nonce : String = ""
    @Published var appleID : String = ""
    // 현재 개인정보와 이용약관 문서를 정리중입니다. 추후에 완성된 문서의 주소값으로 업데이트 하겠습니다
    
    init() {
        userSession = Auth.auth().currentUser
        UserApi.shared.unlink {(error) in
            if let error = error {
                print(error)
            }
            else {
                print("unlink() success.")
            }
        }
        fetchUser()
    }
    
    func login(withEmail email: String, password: String) -> Bool {
        do {
            try Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    print("디버깅: 로그인실패 \(error.localizedDescription)")
                    return
                }
                guard let user = result?.user else { return }
                self.userSession = user
                
                self.fetchUser()
            }
            
            return true
        } catch {
            return false
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
    
    func userCreate() {
        
        var image: UIImage?
        if selectedImageData != nil {
            image = UIImage(data: selectedImageData!)
        }
 
        Auth.auth().createUser(withEmail: self.email, password: self.password) { result, error in
                
                if let error = error {
                    print("Error : Failed to create newuser because of \(error)")
                    return
                } else {
                    guard let user = result?.user else { return }
                    guard let image = image else {
                        
                        let data = [
                            "id" : user.uid,
                            "name": self.name,
                            "email": self.email,
                            "profilePicture": ""
                        ]
                        COLLECTION_USERS.document(user.uid).setData(data) { _ in
                            self.userSession = user
                            self.fetchUser()
                        }
                        print("계정생성 성공")
                        return
                    }
                    ImageUploader.uploadImage(image: image, type: .profile) { imageUrl in
                    
                        
                        let data = [
                            "id" : user.uid,
                            "name": self.name,
                            "email": self.email,
                            "profilePicture": imageUrl
                        ]
                        COLLECTION_USERS.document(user.uid).setData(data) { _ in
                            self.userSession = user
                            self.fetchUser()
                        }
                        print("계정생성 성공")
                    }
                }
            }
    }
    
    struct SafariView: UIViewControllerRepresentable {

        let url: URL

        func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
            return SFSafariViewController(url: url)
        }

        func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {

        }
    }
     
    func checkPassword(password: String) -> Bool {
        let passwordRegEx = "^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#?$%^&*()_+=-]).{7,50}$"
        return NSPredicate(format:"SELF MATCHES %@", passwordRegEx).evaluate(with: password)
        
    }
    
    func checkEmail(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return  NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    func checkIfCanRegister() -> Bool {
        if checkPassword(password: password) == true && checkPassword(password: password) == true && name != "" && checkIfAllBoxsesAreChecked() == true  {
            return true
        } else {
            return false
        }
    }
    
    func checkIfAllBoxsesAreChecked() -> Bool {
        if overFourteenBox == false || termsOfUseBox == false || privacyPolicyBox == false {
            return false
        } else {
            return true
        }
    }
    
    func checkAllBoxes() {
        overFourteenBox = true
        termsOfUseBox = true
        privacyPolicyBox = true
    }
    
    func uncheckAllBoxes() {
        overFourteenBox = false
        termsOfUseBox = false
        privacyPolicyBox = false
    }
    
    /// 메모 작성자의 정보를 가져오는 함수 입니다
    /// - Parameters:
    ///   - uid : Memo Model 안에 있는 작성자 uid를 입력 받습니다.
    /// - Returns: 해당 uid를 가지고 작성자 정보를 표시해주기 위해 User Model을 반환합니다.
    func MemoCreatorfetchUser(uid: String, completion: @escaping (User?) -> Void) {
        print("현재 메모 작성자: uid \(uid)")
        
        COLLECTION_USERS.document(uid).getDocument { [weak self] snapshot, error in
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
    
    // 팔로우, 언팔로우
       
       func UserFollow(followUser: User , completion: @escaping (Error?) -> Void) {
           guard let uid = Auth.auth().currentUser?.uid else {
               completion(NSError(domain: "Auth Error", code: 401, userInfo: nil))
               return
           }
           
               COLLECTION_USER_Following.document(uid).setData([String(followUser.id ?? "") : "followUserUid"], merge: true)
               COLLECTION_USER_Followers.document(followUser.id ?? "").setData([uid : "followingUserUid"], merge: true)
       }
       
       func UnUserFollow(followUser: User , completion: @escaping (Error?) -> Void) {
           guard let uid = Auth.auth().currentUser?.uid else {
               completion(NSError(domain: "Auth Error", code: 401, userInfo: nil))
               return
           }

           
               COLLECTION_USER_Following.document(uid).updateData([String(followUser.id ?? "") : FieldValue.delete()])
               COLLECTION_USER_Followers.document(followUser.id ?? "").updateData([uid : FieldValue.delete()])
       }
       
       // 팔로우 유져인지 확인하는 함수
       
       func FollowCheck(followUser: User , completion: @escaping (Bool?) -> Void){
           guard let uid = Auth.auth().currentUser?.uid else {
               completion(false)
               return
           }
           
           let followUserID = followUser.id ?? ""
           
           let userFollowRef = COLLECTION_USER_Following.document(uid)
           userFollowRef.getDocument { (document, error) in
               if let error = error {
                   print("사용자 팔로우 문서를 가져오는 중 오류가 발생했습니다: \(error.localizedDescription)")
                   completion(false)
                   return
               }
               
               if let document = document, document.exists, let dataArray = document.data() as? [String: String] {
                 
                   if dataArray.keys.contains(followUserID) {
                       completion(true)
                   } else {
                       completion(false)
                   }
               } else {
                   completion(false)
               }
           }
       }
       
       
       /// 좋아요 개수를 표시하는 함수
       /// - Parameters:
       ///   - memo : 해당 메모의 좋아요 총 개수를 표시하는 함수
       /// - Returns: 좋아요 받은 총 개수
   //    func likeMemoCount(memo: Memo) async -> Int {
   //        let memoID = memo.id ?? ""
   //        var likeCount = 0
   //
   //        do {
   //            let document = try await COLLECTION_MEMO_LIKES.document(memoID).getDocument()
   //
   //            if document.exists {
   //                let fieldCount = document.data()?.count ?? 0
   //                likeCount = fieldCount
   //            }
   //        } catch {
   //            print("에러 발생: \(error)")
   //        }
   //
   //        print(likeCount)
   //        return likeCount
   //    }
       
       
       
       
       
       /// 현재 로그인한 사용자가 보여지는 메모에 좋아요(like)했는지 확인하는 기능을 구현한 함수입니다
       /// - Parameters:
       ///   - memo : 사용자가 좋아요 누른 메모가 맞는지 확인 할 메모
       /// - Returns: 좋아요 누른 여부 ture,false(해당 값을 메모의 didLike에 넣어서 MemoCell의 UI를 표시)
   //    func checkLikedMemo(_ memo: Memo, completion: @escaping (Bool) -> Void) {
   //        guard let uid = Auth.auth().currentUser?.uid else {
   //            completion(false)
   //            return
   //        }
   //
   //        let memoID = memo.id ?? ""
   //
   //        let userLikesRef = COLLECTION_USER_LIKES.document(uid)
   //        userLikesRef.getDocument { (document, error) in
   //            if let error = error {
   //                print("사용자 좋아요 문서를 가져오는 중 오류가 발생했습니다: \(error.localizedDescription)")
   //                completion(false)
   //                return
   //            }
   //
   //            if let document = document, document.exists, let dataArray = document.data() as? [String: String] {
   //                print("데이터 \(dataArray)")
   //                print("메모 ID \(memoID)")
   //                if dataArray.keys.contains(memoID) {
   //                    completion(true)
   //                } else {
   //                    completion(false)
   //                }
   //            } else {
   //                completion(false)
   //            }
   //        }
   //    }

       
    
    func fetchUser() {
        guard let uid = userSession?.uid else { return }
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
        
        print("현재 로그인 상태: uid \(uid)")
        
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
    func authenticate(credential: ASAuthorizationAppleIDCredential) {
        //getting token
        guard let token = credential.identityToken else {
            print("error with firebase")
            return
        }
        
        guard let tokenString = String(data: token, encoding: .utf8) else {
            print("error with token")
            return
        }
        
        let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce: nonce)
        Auth.auth().signIn(with: firebaseCredential) { [weak self] result, err in
            guard let self = self else {return}
            if let err = err {
                print(err.localizedDescription)
            }
            if self.name != "" && self.email != "" {
                let data = [
                    "id" : result!.user.uid,
                    "name": self.name,
                    "email": self.email,
                    "profilePicture": ""
                ]
                COLLECTION_USERS.document(result!.user.uid).setData(data) { _ in
                    self.userSession = result!.user
                    self.fetchUser()
                }
            }
            self.userSession = result!.user
            self.fetchUser()
            print("로그인 완료")
        }
    }
    
    func fetchAppleUser() {
        guard let uid = userSession?.uid else { return }
        print("현재 로그인 상태: uid \(uid)")
        COLLECTION_USERS.document(uid).getDocument { [weak self] snapshot, _ in
            guard let user = try? snapshot?.data(as: User.self) else { return }
            
            self?.currentUser = user
            UserDefaults.standard.set(user.id, forKey: "userId")
          //  print(user)
        }
    }
    
    func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      var randomBytes = [UInt8](repeating: 0, count: length)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }

      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

      let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
      }

      return String(nonce)
    }
    
    func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
}
