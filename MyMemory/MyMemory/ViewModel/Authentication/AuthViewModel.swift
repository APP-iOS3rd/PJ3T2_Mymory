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

    @Published var email: String = ""
    @Published var password : String = ""
    @Published var name: String = ""
    @Published var secondPassword: String = ""
    
    @Published var emailValid : Bool = true
    @Published var passwordValid : Bool = true
    
    @Published var agreeAllBoxes: Bool = false
    @Published var overFourteenBox: Bool = false
    @Published var termsOfUseBox: Bool = false
    @Published var privacyPolicyBox: Bool = false
    
    @Published var selectedItem: PhotosPickerItem? = nil
    @Published var imageSelected: Bool = false
    @Published var selectedImageData: Data? = nil
    @Published var isActivce : Bool = false

    
    @Published var showPrivacyPolicy = false
    @Published var showTermsOfUse = false
    @Published var privacyPolicyUrlString = "https://www.notion.so/12bd694d0a774d2f9c167eb4e7976876?pvs=4"
    @Published var termsOfUseUrlString = "https://www.lucky-sycamore-c73.notion.site/af168c49a93b4fa48830d5bc0512dcb5"
    
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
    }
    
    func login(withEmail email: String, password: String) async -> String? {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            AuthService.shared.userSession = result.user
            AuthService.shared.fetchUser()
            return nil
        } catch {
            let errorMessage = self.emailLoginErrorHandler(error: error as NSError)
            return errorMessage
        }
    }
    
    func loginWithGoogle(credential: AuthCredential) async -> String? {
        var image: UIImage?
        if selectedImageData != nil {
            image = UIImage(data: selectedImageData!)
        }
        
        do {
            let result = try await Auth.auth().signIn(with: credential)
            let newUserCheck = await checkUser(userID: result.user.uid)
            if newUserCheck {
                guard let image = image else {
                    let data = [
                        "id" : result.user.uid,
                        "name": self.name,
                        "email": result.user.email,
                        "profilePicture": ""
                    ]
                    try await COLLECTION_USERS.document(result.user.uid).setData(data as [String: Any])
                        AuthService.shared.userSession = result.user
                        AuthService.shared.fetchUser()
                        return ("계정생성 성공")
                }
                ImageUploader.uploadImage(image: image, type: .profile) { imageUrl in
                    let data = [
                        "id" : result.user.uid,
                        "name": self.name,
                        "email": result.user.email,
                        "profilePicture": imageUrl
                    ]
                    COLLECTION_USERS.document(result.user.uid).setData(data as [String: Any])
                        AuthService.shared.userSession = result.user
                        AuthService.shared.fetchUser()
                        print("계정생성 성공")
                }
            } else {
                AuthService.shared.userSession = result.user
                AuthService.shared.fetchUser()
            }
            return nil
        } catch {
            return ("구글 로그인 실패")
        }
    }
    
    func getUserID(credential: ASAuthorizationAppleIDCredential)async -> String?{
        do {
            guard let token = credential.identityToken else {
                print("error with firebase")
                return "error"
            }
            
            guard let tokenString = String(data: token, encoding: .utf8) else {
                print("error with token")
                return "error"
            }
            
            let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce: nonce)
            let signInResult = try await Auth.auth().signIn(with: firebaseCredential)
            AuthService.shared.userSession = signInResult.user
            AuthService.shared.fetchUser()
        } catch {
            return "fail"
        }
        return "success"
    }
    
    func checkUserEmail(email: String) async -> Bool {
        do {
            print("해당유저 이메일 : \(email)")
            if email == "emailnotfound" {
                return false
            }
            let querySnapshot = try await Firestore.firestore().collection("users")
                .whereField("email", isEqualTo: email).getDocuments()
            if querySnapshot.isEmpty {
                return true
            } else {
                return false
            }
        } catch {
            return true
        }
    }
    
    func checkUser(credential: ASAuthorizationAppleIDCredential) async -> Bool {
        let _ = await getUserID(credential: credential)
        do {
            let querySnapshot = try await Firestore.firestore().collection("users")
                .whereField("id", isEqualTo: AuthService.shared.currentUser?.id ?? "no value").getDocuments()
            if querySnapshot.isEmpty {
                return true
            } else {
                return false
            }
        } catch {
            return true
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
                        AuthService.shared.userSession = user
                        AuthService.shared.fetchUser()
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
                        AuthService.shared.userSession = user
                        AuthService.shared.fetchUser()
                    }
                    print("계정생성 성공")
                }
            }
        }
    }
    
    func reauthenticate(credential: ASAuthorizationAppleIDCredential) {
        var image: UIImage?
        if selectedImageData != nil {
            image = UIImage(data: selectedImageData!)
        }
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
                guard let image = image else {
                    
                    let data = [
                        "id" : result!.user.uid,
                        "name": self.name,
                        "email": result?.user.email ?? "no email",
                        "profilePicture": ""
                    ]
                    COLLECTION_USERS.document(result!.user.uid).setData(data) { _ in
                        AuthService.shared.userSession = result!.user
                        AuthService.shared.fetchUser()
                    }
                    print("계정생성 성공")
                    return
                }
                ImageUploader.uploadImage(image: image, type: .profile) { imageUrl in
                    let data = [
                        "id" : result!.user.uid,
                        "name": self.name,
                        "email": result?.user.email ?? "no email",
                        "profilePicture": imageUrl
                    ]
                    COLLECTION_USERS.document(result!.user.uid).setData(data) { _ in
                        AuthService.shared.userSession = result!.user
                        AuthService.shared.fetchUser()
                    }
                    print("계정생성 성공")
                }
            UserDefaults.standard.set(result!.user.uid, forKey: "userId")
            print("로그인 완료")
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
    
    func checkSecondPassword(secondPassword: String) -> Bool {
        if self.password == secondPassword {
            return true
        }
        return false
    }
    
    func checkEmail(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return  NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    func checkIfCanRegister() -> Bool {
        let isValidPassword = checkPassword(password: password)
        let isNameNotEmpty = name != ""
        let isBoxsesAreChecked = checkIfAllBoxsesAreChecked()
        let isSecondPasswordMatch = checkSecondPassword(secondPassword: secondPassword)
        let isValidEmail = checkEmail(email: email)
        if isValidPassword && isValidEmail && isNameNotEmpty && isBoxsesAreChecked && isSecondPasswordMatch && isValidEmail {
            return true
        } else {
            return false
        }
    }
    
    func checkIfCanSocialRegister() -> Bool {
        let isNameNotEmpty = name != ""
        let isBoxsesAreChecked = checkIfAllBoxsesAreChecked()
        if isNameNotEmpty && isBoxsesAreChecked {
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
    
    func fetchCurrentUserLoginState() -> Bool {
        if let _ = Auth.auth().currentUser {
            return true
        }
        return false
    }
    func authenticate(credential: ASAuthorizationAppleIDCredential) {
        var image: UIImage?
        if selectedImageData != nil {
            image = UIImage(data: selectedImageData!)
        }
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
                guard let image = image else {
                    
                    let data = [
                        "id" : result!.user.uid,
                        "name": self.name,
                        "email": self.email,
                        "profilePicture": ""
                    ]
                    COLLECTION_USERS.document(result!.user.uid).setData(data) { _ in
                        AuthService.shared.userSession = result!.user
                        AuthService.shared.fetchUser()
                    }
                    print("계정생성 성공")
                    return
                }
                ImageUploader.uploadImage(image: image, type: .profile) { imageUrl in
                    let data = [
                        "id" : result!.user.uid,
                        "name": self.name,
                        "email": self.email,
                        "profilePicture": imageUrl
                    ]
                    COLLECTION_USERS.document(result!.user.uid).setData(data) { _ in
                        AuthService.shared.userSession = result!.user
                        AuthService.shared.fetchUser()
                    }
                    print("계정생성 성공")
                }
            }
            AuthService.shared.userSession = result!.user
            AuthService.shared.fetchUser()
            UserDefaults.standard.set(result!.user.uid, forKey: "userId")
            print("로그인 완료")
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
