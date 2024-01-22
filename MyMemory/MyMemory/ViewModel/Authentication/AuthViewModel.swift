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
    @Published var privacyPolicyUrlString = "https://www.google.com"
    @Published var termsOfUseUrlString = "https://www.naver.com"
    // 현재 개인정보와 이용약관 문서를 정리중입니다. 추후에 완성된 문서의 주소값으로 업데이트 하겠습니다
    
    init() {
        userSession = Auth.auth().currentUser
        fetchUser()
    }
    
    func login(withEmail email: String, password: String){
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("디버깅: 로그인실패 \(error.localizedDescription)")
                return
            }
            guard let user = result?.user else { return }
            self.userSession = user
            
            self.fetchUser()
        }
    }
    
    func signout() {
        self.userSession = nil
        try? Auth.auth().signOut()
        
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
    
    
    func fetchUser() {
        guard let uid = userSession?.uid else { return }
        print("디버깅 중: uid \(uid)")
        COLLECTION_USERS.document(uid).getDocument { snapshot, _ in
            guard let user = try? snapshot?.data(as: User.self) else { return }
            
            self.currentUser = user
            print(user)
        }
    }
}
