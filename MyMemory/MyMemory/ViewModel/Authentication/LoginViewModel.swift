//
//  LoginViewModel.swift
//  MyMemory
//
//  Created by 김성엽 on 1/15/24.
//

import SwiftUI
import AuthenticationServices

// MARK: - 커스텀 텍스트필드
struct UnderLineTextfieldStyle: TextFieldStyle {
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        
        VStack {
            // 텍스트필드
            configuration
                .frame(width: 350)
                
            
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.gray)
        }
    }
}



// MARK: - 커스텀 버튼
struct LoginButton: ButtonStyle {
    var labelColor = Color.white
    var backgroundColor = Color.gray

    
  
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
          .padding()
      .foregroundColor(labelColor)
      .background(
        RoundedRectangle(cornerRadius: 10)
            .fill(backgroundColor)
            .frame(width: 350, height: 50)
      )
  }
}


struct SocialLoginButton: ButtonStyle {
    var labelColor = Color.white
    var backgroundColor = Color.black

    
  
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
          .padding()
      .foregroundColor(labelColor)
      .background(
        RoundedRectangle(cornerRadius: 12)
            .fill(backgroundColor)
            .frame(width: 350, height: 50)
      )
  }
}

//struct AppleSigninButton : View{
//    
//    @State var currentNounce: String?
//    @ObservedObject var appleLoginData: AuthViewModel = AuthViewModel()
//    
//    var body: some View{
//        
//        SignInWithAppleButton(
//            onRequest: { request in
//                print("working")
//                appleLoginData.nonce = appleLoginData.randomNonceString()
//                request.requestedScopes = [.fullName, .email]
//                request.nonce = appleLoginData.sha256(appleLoginData.nonce)
//            },
//            onCompletion: { result in
//                switch result {
//                case .success(let authResults):
//                    print("Apple Login Successful")
//                    guard let credential = authResults.credential as? ASAuthorizationAppleIDCredential else {
//                        print("error with firebase")
//                        return
//                    }
//                    switch authResults.credential {
//                        case let appleIDCredential as ASAuthorizationAppleIDCredential:
//                        let fullName = appleIDCredential.fullName
//                        self.appleLoginData.name = (fullName?.familyName ?? "") + (fullName?.givenName ?? "")
//                        self.appleLoginData.email = appleIDCredential.email ?? "emailnotfound"
//                    default:
//                        break
//                    }
//                    self.appleLoginData.authenticate(credential: credential)
//                case .failure(let error):
//                    print(error.localizedDescription)
//                    print("error")
//                }
//            }
//        )
//        .frame(width : 350, height:50)
//        .cornerRadius(10)
//    }
//}
