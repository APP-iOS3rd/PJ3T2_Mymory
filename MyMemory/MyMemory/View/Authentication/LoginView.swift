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
    @State private var isNewGoogleUser: Bool = false
    @State private var isNewAppleUser: Bool = false
    @State private var isShowingLoginErrorAlert: Bool = false
    @State private var loginErrorAlertTitle = ""
    @State private var notCorrectLogin: Bool = false
    @State var appleCredential: ASAuthorizationAppleIDCredential?
    @State var googleCredential: AuthCredential?
    @State var isAppleUser: Bool = false
    @ObservedObject var viewModel: AuthViewModel = .init()
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
                            .clearButton(text: $email)
                        
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
                            .clearButton(text: $password)
                        
                    }
                } //:VSTACK - TextField
                .onAppear {
                    UIApplication.shared.hideKeyboard()
                }
                .onSubmit {
                    switch focusedField {
                    case .email:
                        focusedField = .password
                    default:
                        print("Done")
                    }
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
                    //                        .alert(loginErrorAlertTitle, isPresented: $isShowingLoginErrorAlert) {
                    //                            Button("확인", role: .cancel) {}
                    //                        }
                }
                
                NavigationLink {
                    RegisterView()
                        .environmentObject(viewModel)
                } label: {
                    Text("내모리가 처음이시라면 - 회원가입")
                        .underline()
                        .foregroundStyle(.gray)
                        .font(.regular14)
                }
                .padding(.vertical, 12)
                
                Spacer()
                
                // MARK: - 소셜 로그인 버튼
                VStack {
                    Button {
                        print("google 1")
                        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
                        print("google 2")
                        let config = GIDConfiguration(clientID: clientID)
                        print("google 3")
                        GIDSignIn.sharedInstance.configuration = config
                        guard let check = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {return}
                        print("google 4")
                        GIDSignIn.sharedInstance.signIn(withPresenting: check) { signResult, error in
                            if let error = error {
                                print("구글 로그인 에러입니다\(error)")
                                return
                            } else {
                                guard let user = signResult?.user,
                                      let idToken = user.idToken else { return }
                                
                                let accessToken = user.accessToken
                                viewModel.email = user.profile?.email ?? "이메일이 없습니다"
                                print("유저 이메일 입니다 \(viewModel.email)")
                                googleCredential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
                                Task {
                                    let isCheckNewUser = await viewModel.checkUserEmail(email: viewModel.email)
                                    if isCheckNewUser {
                                        isNewGoogleUser = true
                                    } else {
                                        print("구글 확인 6")
                                        if let alertTitle = await self.viewModel.loginWithGoogle(credential: googleCredential!) {
                                            print(alertTitle)
                                            presentationMode.wrappedValue.dismiss()
                                            return
                                        } else {
                                            presentationMode.wrappedValue.dismiss()
                                        }
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
                                self.appleCredential = credential
                                switch authResults.credential {
                                case let appleIDCredential as ASAuthorizationAppleIDCredential:
                                    let fullName = appleIDCredential.fullName
                                    self.viewModel.name = (fullName?.familyName ?? "") + (fullName?.givenName ?? "")
                                    self.viewModel.email = appleIDCredential.email ?? "emailnotfound"
                                default:
                                    break
                                }
                                Task {
                                    if await viewModel.checkUser(credential: credential ){
                                                print("새로운 유저 입니다")
                                                AuthService.shared.signout()
                                                self.isNewAppleUser = true
                                            } else {
                                                presentationMode.wrappedValue.dismiss()
                                            }
                                }
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                    )
                    
                    .buttonStyle(RoundedRect.loginApple)
                    
                    .frame(height: 50)
                    
                    
                    /*
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
                     */
                } //: SNS 로그인
                // .padding(.vertical, 20)
            } //: VSTACK
            
            .padding()
            //            .fullScreenCover(isPresented: $isActive) {
            //                MainTabView()
            //            }
            .fullScreenCover(isPresented: $isNewGoogleUser) {
                GoogleSocialRegisterView(googleCredential: $googleCredential, isActive: $isActive)
                    .environmentObject(viewModel)
            }
            .fullScreenCover(isPresented: $isNewAppleUser) {
                SocialRegisterView(appleCredential: $appleCredential, isActive: $isActive)
                    .environmentObject(viewModel)
                
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
            //            .navigationDestination(isPresented: $isNewGoogleUser) {
            //                GoogleSocialRegisterView(googleCredential: $googleCredential)
            //            }
            //            .navigationDestination(isPresented: $isNewAppleUser) {
            //                SocialRegisterView(appleCredential: $appleCredential)
            //            }
            .onChange(of: isActive) { _ in
                if isActive {
                    print("나와라")
                    presentationMode.wrappedValue.dismiss()
                } else {
                    print("나오지 마라")
                }
            }
        }//: NAVISTACK
        .moahAlert(isPresented: $isShowingLoginErrorAlert, moahAlert: {
            MoahAlertView(message: loginErrorAlertTitle, firstBtn: MoahAlertButtonView(type: .CONFIRM, isPresented: $isShowingLoginErrorAlert, action: {}))
        })
    }
}



