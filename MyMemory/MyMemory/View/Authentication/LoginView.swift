//
//  LoginView.swift
//  MyMemory
//
//  Created by 김소혜 on 1/4/24.
//

import SwiftUI
import FirebaseAuth

// 화면 터치 시 키보드 숨기기
extension View {
    func endTextEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

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
    
    
    private var correctEmail: String = "12345@naver.com"
    private var correctPassword: String = "12345"
    

    
    var body: some View {
        NavigationStack {
        
            VStack {
                
                Text("내모리")
                    .font(.system(size: 50, weight: .black))
                    .foregroundStyle(.indigo)
                    .padding(.top, 100)
                    .padding(.bottom, 50)
                
                VStack(alignment: .leading) {
                    Text("이메일")
                        .foregroundStyle(.gray)
                    
                    TextField("", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)// 대문자x
                        .focused($focusedField, equals: .email)
                        .textContentType(.emailAddress)
                    
                    
                    Text("비밀번호")
                        .foregroundStyle(.gray)
                    
                    SecureField("", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .focused($focusedField, equals: .password)
                        .textContentType(.password)
    
                }//:VSTACK - TextField
                .onSubmit {
                    switch focusedField {
                    case .email:
                        focusedField = .password
                    default:
                        print("Done")
                    }
                }
                
                if self.email.isEmpty || self.password.isEmpty {
                    Button("로그인") { }
                        .padding(.top, 30)
                        .foregroundStyle(.white)
                        .buttonStyle(.borderedProminent)
                        .tint(.gray)
                        .disabled(true)
                } else {
                    Button(action: {
                        checkLogin(isEmail: email, isPassword: password)
                        self.isActive = true
                    }, label: {
                        Text("로그인")
                    })
                    .padding(.top, 30)
                    .buttonStyle(.borderedProminent)
                    .tint(.indigo)
                    .alert(isPresented: $notCorrectLogin) {
                        Alert(title: Text("주의\n"), message: Text("이메일, 또는 비밀번호가 일치하지 않습니다."), dismissButton: .default(Text("확인")))
                    }
                }
    
                NavigationLink {
                    EmptyView()
                } label: {
                    Text("내모리가 처음이라면 - 회원가입")
                        .underline()
                        .foregroundStyle(.gray)
                        .font(.system(size: 17))
                        .padding(.top, 1)
                }

                Button(action: {
                    
                }, label: {
                    Image(systemName: "apple.logo")
                    Text("애플로 로그인 하기")
                })
                .padding()
            }//: VSTACK
            .padding()
            .navigationDestination(isPresented: $isActive) {
                EmptyView()
            }
        }//: Navigation Stack
        .onTapGesture{
            self.endTextEditing()
        }
    }
    
    
    private func checkLogin(isEmail: String, isPassword: String) {
        if isEmail != correctEmail || isPassword != correctPassword {
            notCorrectLogin = true
        }
    }
    
}


#Preview {
    LoginView()
}
