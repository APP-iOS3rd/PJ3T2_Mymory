//
//  LoginView.swift
//  MyMemory
//
//  Created by 김소혜 on 1/4/24.
//

import SwiftUI
import FirebaseAuth


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
    @ObservedObject var viewModel: AuthViewModel = AuthViewModel()
    
    
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
                    viewModel.login(withEmail: email, password: password)
                    

                } label: {
                    Text("로그인")
                        .font(.regular18)
                }
                .buttonStyle(LoginButton(backgroundColor: Color.indigo))
//                    .alert(isPresented: $notCorrectLogin) {
//                        Alert(title: Text("주의\n"), message: Text("이메일, 또는 비밀번호가 일치하지 않습니다."), dismissButton: .default(Text("확인")))
//                    }
            }

            NavigationLink {
                RegisterView(viewModel: viewModel)
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
                Button {
                    
                } label: {
                    HStack {
                        Image(systemName: "apple.logo")
                            .resizable()
                            .frame(width: 18, height: 20)
                        Text("Apple로 계속하기")
                            .font(.regular16)
                    }
                }
                .buttonStyle(SocialLoginButton())
                
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
        .navigationDestination(isPresented: $isActive) {
            MainMapView()
        }
       // .toolbar(.hidden, for: .tabBar)
        .onTapGesture{
            self.endTextEditing()
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
