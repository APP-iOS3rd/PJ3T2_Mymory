//
//  LoginView.swift
//  MyMemory
//
//  Created by 김소혜 on 1/4/24.
//

import SwiftUI
import FirebaseAuth
import AuthenticationServices

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
    @State private var notCorrectLogin: Bool = false
    @EnvironmentObject var viewModel: AuthViewModel 
//    @ObservedObject var viewRouter: ViewRouter = ViewRouter()
 
    
    @Environment(\.presentationMode) var presentationMode
    // 확인용 임시 아이디 + 패스워드
//    private var correctEmail: String = "12345@naver.com"
//    private var correctPassword: String = "12345"
    
    
    var body: some View {
        
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
                }
                    .buttonStyle(LoginButton())
            } else {
                Button {
                    
                    self.isActive = true
                  
                    if viewModel.login(withEmail: email, password: password) {
                        print("로그인 성공")
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        print("로그인 실패")
                    }
              
                } label: {
                    Text("로그인")
                        .font(.regular18)
                }
                .buttonStyle(LoginButton(backgroundColor: Color.indigo))
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
                        backgroundColor: .white
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
                SignInWithAppleButton(
                    onRequest: { request in
                        print("working")
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
                            self.viewModel.authenticate(credential: credential)
                            self.isActive = true
                            presentationMode.wrappedValue.dismiss()
                        case .failure(let error):
                            print(error.localizedDescription)
                            print("error")
                        }
                    }
                )
                .frame(width : 350, height:50)
                .cornerRadius(10)
                Button {
                    
                } label: {
                    HStack {
                        Image("kakao")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 20)
                        Text("Kakao로 계속하기")
                            .font(.regular16)
                    }
                }
                .buttonStyle(SocialLoginButton(labelColor: Color.black ,backgroundColor: Color.yellow))
            }//: SNS 로그인
            .padding(.vertical, 20)
        }//: VSTACK
   
        .padding()
        .fullScreenCover(isPresented: $isActive) {
            MainTabView()
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
            backgroundColor: .white
        )
    }
    
    
//    private func checkLogin(isEmail: String, isPassword: String) {
//        if isEmail != correctEmail || isPassword != correctPassword {
//            notCorrectLogin = true
//        }
//    }
    
}

#Preview {
    LoginView()
}
