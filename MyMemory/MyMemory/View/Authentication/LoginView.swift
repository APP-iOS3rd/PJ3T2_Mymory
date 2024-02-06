//
//  LoginView.swift
//  MyMemory
//
//  Created by 김소혜 on 1/4/24.
//

import SwiftUI
import FirebaseAuth
import AuthenticationServices
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import GoogleSignIn
import GoogleSignInSwift
import FirebaseCore

struct LoginView: View {
    
    // 엔터 >> 자동으로 다음 텍스트필드로 이동
    enum Field {
        case email
        case password
    }
    
    @FocusState private var focusedField: Field?
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isActive: Bool = false
    @State private var isNewUser: Bool = false
    @State private var isShowingLoginErrorAlert: Bool = false
    @State private var loginErrorAlertTitle = ""
    @State private var notCorrectLogin: Bool = false
    @State var appleCredential: ASAuthorizationAppleIDCredential?
    
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
        NavigationStack {
            VStack {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding(.vertical, 50)
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("이메일")
                            .foregroundStyle(.gray)
                            .font(.regular14)
                        
                        TextField("", text: $email)
                            .textFieldStyle(UnderLineTextfieldStyle())
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)// 대문자x
                            .focused($focusedField, equals: .email)
                            .textContentType(.emailAddress)
                        
                    }
                    
                    VStack(alignment: .leading) {
                        Text("비밀번호")
                            .foregroundStyle(.gray)
                            .font(.regular14)
                        
                        SecureField("", text: $password)
                            .textFieldStyle(UnderLineTextfieldStyle())
                            .textInputAutocapitalization(.never)
                            .focused($focusedField, equals: .password)
                            .textContentType(.password)
                        
                    }
                } //:VSTACK - TextField
                .onSubmit {
                    switch focusedField {
                    case .email:
                        focusedField = .password
                    default:
                        print("Done")
                    }
                }
                // 텍스트필드에 clear버튼 활성화
                .onAppear {
                    UITextField.appearance().clearButtonMode = .whileEditing
                }
                
                if self.email.isEmpty || self.password.isEmpty {
                    Button {
                        
                    } label: {
                        Text("로그인")
                            .font(.regular18)
                            .frame(maxWidth: .infinity)
                        
                    }
                    .buttonStyle(RoundedRect.loginBtnDisabled)
                    
                } else {
                    Button {
                        Task {
                            if let alertTitle = await self.viewModel.login(withEmail: email, password: password) {
                                self.loginErrorAlertTitle = alertTitle
                                self.isShowingLoginErrorAlert = true
                            } else {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    } label: {
                        Text("로그인")
                            .font(.regular18)
                            .frame(maxWidth: .infinity)
                            
                    }
                    .buttonStyle(RoundedRect.loginBtn)
                   // .buttonStyle(LoginButton(backgroundColor: Color.indigo))
                    .alert(loginErrorAlertTitle, isPresented: $isShowingLoginErrorAlert) {
                        Button("확인", role: .cancel) {}
                    }
                }
                
                NavigationLink {
                    RegisterView()
                        .customNavigationBar(
                            centerView: {
                                Text("회원가입")
                            },
                            leftView: {
                                EmptyView()
                            },
                            rightView: {
                                CloseButton()
                            },
                            backgroundColor: .bgColor
                        )
                } label: {
                    Text("내모리가 처음이시라면 - 회원가입")
                        .underline()
                        .foregroundStyle(.gray)
                        .font(.regular14)
                }
                
                Spacer()
                
                // MARK: - 소셜 로그인 버튼
                VStack {
                    
                    Button {
                        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
                        
                        let config = GIDConfiguration(clientID: clientID)
                        
                        GIDSignIn.sharedInstance.configuration = config
                        guard let check = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {return}
                        GIDSignIn.sharedInstance.signIn(withPresenting: check) { signResult, error in
                            if let error = error {
                                print("구글 로그인 에러입니다\(error)")
                                return
                            } else {
                                guard let user = signResult?.user,
                                      let idToken = user.idToken else { return }
                                
                                let accessToken = user.accessToken
                                
                                let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
                                Task {
                                    if let alertTitle = await self.viewModel.loginWithGoogle(credential: credential) {
                                        print(alertTitle)
                                        return
                                    } else {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                                
                            }
                        }
                    } label: {
                        HStack {
                            Image("googleLogo")
                                .frame(width: 24, height: 24)
                            
                            Text("Google로 계속하기")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(RoundedRect.loginGoogle)
                    
                    SignInWithAppleButton(
                        onRequest: { request in
                            viewModel.nonce = viewModel.randomNonceString()
                            request.requestedScopes = [.fullName, .email]
                            request.nonce = viewModel.sha256(viewModel.nonce)
                        },
                        onCompletion: { result in
                            switch result {
                            case .success(let authResults):
                                print("Apple Login Successful")
                                guard let credential = authResults.credential as? ASAuthorizationAppleIDCredential else {
                                    print("error with firebase")
                                    return
                                }
                                switch authResults.credential {
                                case let appleIDCredential as ASAuthorizationAppleIDCredential:
                                    let fullName = appleIDCredential.fullName
                                    self.viewModel.name = (fullName?.familyName ?? "") + (fullName?.givenName ?? "")
                                    self.viewModel.email = appleIDCredential.email ?? "emailnotfound"
                                default:
                                    break
                                }
                                Task {
                                    self.appleCredential = credential
                                    let isCheckNewUser = await viewModel.checkUserEmail(email: viewModel.email)
                                    if isCheckNewUser {
                                        self.isNewUser = true
                                        print("나오지마라 나오지마라")
                                    } else {
                                        self.viewModel.authenticate(credential: credential)
                                        self.isActive = true
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            case .failure(let error):
                                print(error.localizedDescription)
                                print("error")
                            }
                        }
                    )
                    .buttonStyle(RoundedRect.loginApple)
                  
                    .frame(height: 50)
    
                    
              
                    Button {
                        if (UserApi.isKakaoTalkLoginAvailable()) {
                            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                                if let error = error {
                                    print("카카오로그인 에러입니다. \(error)")
                                    return
                                } else {
                                    UserApi.shared.me { User, Error in
                                        if let name = User?.kakaoAccount?.profile?.nickname {
                                            print("제 닉네임은 \(name) 입니다")
                                        }
                                        
                                        print("카카카오 결과입니다")
                                        
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Image("kakao")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 20)
                            Text("Kakao로 계속하기")
                                .font(.regular16)
                        }
                        .frame(maxWidth: .infinity)
                        
                      

                    }
                    .buttonStyle(RoundedRect.loginKakao)
                    .frame(height: 50)
            
                    } //: SNS 로그인
                   // .padding(.vertical, 20)
            } //: VSTACK
            
            .padding()
            .fullScreenCover(isPresented: $isActive) {
                MainTabView()
            }
            .fullScreenCover(isPresented: $isNewUser) {
                SocialRegisterView(appleCredential: $appleCredential)
            }
            .customNavigationBar(
                centerView: {
                    Text("")
                },
                leftView: {
                    EmptyView()
                },
                rightView: {
                    CloseButton()
                },
                backgroundColor: .bgColor3
            )
        }
    }
}

#Preview {
    LoginView()
}
