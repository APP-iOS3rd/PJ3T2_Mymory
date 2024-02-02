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
import GoogleSignIn
import GoogleSignInSwift
import FirebaseCore

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
    
    // 팔로우, 팔로잉 파악을 위한
    @Published var isFollow: Bool = false
    @Published var followerCount: Int = 0
    @Published var followingCount: Int = 0
    
    init() {
        userSession = Auth.auth().currentUser
        signout()
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
    
    func login(withEmail email: String, password: String) async -> String? {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            self.fetchUser()
            return nil
        } catch {
            let errorMessage = self.emailLoginErrorHandler(error: error as NSError)
            return errorMessage
        }
    }
    
    func loginWithGoogle(credential: AuthCredential) async -> String? {
        do {
            let result = try await Auth.auth().signIn(with: credential)
            let newUserCheck = await checkUser(userID: result.user.uid)
            if newUserCheck {
                let data = [
                    "id" : result.user.uid,
                    "name": result.user.displayName,
                    "email": result.user.email,
                    "profilePicture": ""
                ]
                COLLECTION_USERS.document(result.user.uid).setData(data) { _ in
                    self.userSession = result.user
                    self.fetchUser()
                }
                print("계정생성 성공")
            } else {
                self.userSession = result.user
                self.fetchUser()
            }
            return nil
        } catch {
            return ("구글 로그인 실패")
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
    func memoCreatorfetchUser(uid: String, completion: @escaping (User?) -> Void) {
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
    
    
    /// 사용자를 팔로우 하는 함수입니다.
    /// - Parameters:
    ///   - followUser : 팔로우할 사용자를 넣어주면 됩니다.
    /// - Returns: 에러를 반환 합니다.
    func userFollow(followUser: User , completion: @escaping (Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "Auth Error", code: 401, userInfo: nil))
            return
        }
        
        COLLECTION_USER_Following.document(uid).setData([String(followUser.id ?? "") : "followUserUid"], merge: true)
        COLLECTION_USER_Followers.document(followUser.id ?? "").setData([uid : "followingUserUid"], merge: true)
        
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
        
        
        COLLECTION_USER_Following.document(uid).updateData([String(followUser.id ?? "") : FieldValue.delete()])
        COLLECTION_USER_Followers.document(followUser.id ?? "").updateData([uid : FieldValue.delete()])
        
        DispatchQueue.main.async {
            self.isFollow = false
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
        
        let followUserID = followUser.id ?? ""
        
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
    
    
    // 팔로우, 팔로잉을 카운트 하는 함수
    // - Parameters:
    //   - user : following, follower 숫자를 알고 싶은 사용자를 넣어줍니다.
    // - Returns: 반환 값은 따로 없으며 카운트된 숫자를 @Published로
    //            View에 연결하여 각각의 사용자의 following, follower 숫자를 바로바로 표시할 수 있습니다.
    func followAndFollowingCount(user: User) async -> Void {
        let userID = user.id ?? ""
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
    
    /// Firebase Auth를 활용한 로그인 중 발생하는 에러들에 대한 핸들러입니다.
    /// 참고: https://firebase.google.com/docs/reference/ios/firebaseauth/api/reference/Enums/FIRAuthErrorCode
    ///      https://firebase.google.com/docs/auth/ios/errors
    /// - Parameters:
    ///     - error: Auth.auth().signIn(withEmail: ..) 메서드 사용시 발생하는
    /// - Returns: alert에 띄워줄 내용들을 반환합니다.
    func emailLoginErrorHandler(error: NSError) -> String {
        print(error.code)
        switch error.code {
        case 17020 :
            return "네트워크 에러입니다. 네트워크 상태를 확인해주세요."
        case 17010 :
            return "비정상적인 요청입니다. 잠시 후 다시 시도해주세요."
        case 17008 :
            return "이메일 형식이 알맞지 않습니다."
        case 17009 :
            return "비밀번호가 일치하지 않습니다."
            // 기존의 17009번 에러가 비밀번호 불일치이지만, 현재 테스트 시 비밀번호 불일치 시 17004번 에러가 반환되므로 임시로 비밀번호 에러로 사용하겠습니다.
        case 17004 :
            return "비밀번호가 일치하지 않습니다."
        default:
            return "에러입니다. 잠시 후 다시 시도해주세요."
        }
    }
    
}
