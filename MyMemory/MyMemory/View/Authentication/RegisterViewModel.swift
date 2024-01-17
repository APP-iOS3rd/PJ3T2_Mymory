//
//  RegisterViewModel.swift
//  MyMemory
//
//  Created by hyunseo on 1/15/24.
//

import Foundation
import Photos
import PhotosUI
import SwiftUI
import SafariServices

class RegisterViewModel: ObservableObject {

    @Published var email : String = ""
    @Published var password : String = ""
    @Published var name : String = ""
    
    @Published var emailValid : Bool = true
    @Published var passwordValid : Bool = true
    
    @Published var agreeAllBoxes : Bool = false
    @Published var overFourteenBox : Bool = false
    @Published var termsOfUseBox : Bool = false
    @Published var privacyPolicyBox : Bool = false
    
    @Published var selectedItem: PhotosPickerItem? = nil
    @Published var imageSelected : Bool = false
    
    @Published var showPrivacyPolicy = false
    @Published var showTermsOfUse = false
    @Published var privacyPolicyUrlString = "https://www.google.com"
    @Published var termsOfUseUrlString = "https://www.naver.com"
    // 현재 개인정보와 이용약관 문서를 정리중입니다. 추후에 완성된 문서의 주소값으로 업데이트 하겠습니다
    
    
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
        if checkPassword(password: password) == true && checkPassword(password: password) == true && name != "" && checkIfAllBoxsesAreChecked() == true {
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
}
