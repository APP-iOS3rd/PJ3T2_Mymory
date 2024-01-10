//
//  RegisterView.swift
//  MyMemory
//
//  Created by hyunseo on 1/8/24.
//

import SwiftUI

struct RegisterView: View {
//    @ObservedObject var viewModel: LoginViewModel = LoginViewModel()
    @State var email : String = ""
    @State var password : String = ""
    @State var name : String = ""
    @State var emailValid : Bool = true
    @State var passwordValid : Bool = true
    @State var rule1 : Bool = false
    @State var rule2 : Bool = false
    @State var rule3 : Bool = false
    @State var rule4 : Bool = false
    var body: some View {
        NavigationView {
            ScrollView {
                VStack() {
                    Spacer()
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width:180, height: 180)
                        .foregroundStyle(Color.gray)
                        .onTapGesture {
                            print("hello world")
                        }
                    Spacer()
                    Spacer()
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            Text("이메일")
                                .font(.system(size: 15))
                            TextField("example@example.com", text: $email)
                                .overlay(
                                        Image(systemName: "multiply.circle.fill")
                                            .position(x:350, y:10)
                                            .foregroundStyle(Color.gray)
                                            .onTapGesture {
                                                self.email = ""
                                            }
                                )
                            
                            Divider()
                                .padding(.vertical, -5)
                            HStack {
                                Text(checkEmail(email: email) ? "사용 가능한 이메일입니다!" : "사용할수 없는 이메일입니다")
                                    .font(.system(size: 15))
                                    .foregroundStyle(email == "" ? Color.white : (checkEmail(email: email) ? Color.green : Color.red))
                            }
                        }
                        .padding()
                        
                        VStack(alignment: .leading) {
                            Text("비밀번호")
                                .font(.system(size: 15))
                            TextField("특수문자와 숫자/대문자를 포함한 8글자", text: $password)
                                .overlay(
                                        Image(systemName: "multiply.circle.fill")
                                            .position(x:350, y:10)
                                            .foregroundStyle(Color.gray)
                                            .onTapGesture {
                                                password = ""
                                            }
                                )
                            Divider()
                                .padding(.vertical, -5)
                            Text(passwordValid ? "사용 가능한 비밀번호입니다" : "특수문자,숫자,대문자를 포함한 8글자 이상으로 설정하세요!")
                                .font(.system(size: 15))
                                .foregroundStyle(password == "" ? Color.white : (passwordValid ? Color.green : Color.red))
                        }
                        .padding()
                        
                        VStack(alignment: .leading) {
                            Text("이름")
                                .font(.system(size: 15))
                            TextField("이름을 입력해주세요", text: $name)
                                .overlay(
                                        Image(systemName: "multiply.circle.fill")
                                            .position(x:350, y:10)
                                            .foregroundStyle(Color.gray)
                                            .onTapGesture {
                                                self.name = ""
                                            }
                                )
                            Divider()
                                .padding(.vertical, -5)
                        }
                        .padding()
                        VStack(alignment: .leading) {
                                        HStack{
                                            Image(systemName: rule1 ? "checkmark.square" : "square")
                                                .onTapGesture {
                                                    rule1.toggle()
                                                    if rule1 == true {
                                                        rule2 = true
                                                        rule3 = true
                                                        rule4 = true
                                                    } else {
                                                        rule2 = false
                                                        rule3 = false
                                                        rule4 = false
                                                    }
                                                    
                                                }
                                            HStack(alignment: .bottom){
                                                    Text("약관 전체동의")
                                                        .bold()
                                                        .font(.system(size: 18))
                                                    Text("선택항목에 대한 동의 포함")
                                                        .font(.system(size: 13))
                                                        .foregroundStyle(Color.gray)
                                            }
                                        }
                            Spacer()
                            Spacer()
                                        HStack{
                                            Image(systemName: rule2 ? "checkmark.square" : "square")
                                                .onTapGesture {
                                                    rule2.toggle()
                                                }
                                            Text("만 14세 이상입니다")
                                            Text("(필수)")
                                                .font(.system(size: 10))
                                        }
                                            .font(.system(size: 13))
                            Spacer()
                            Spacer()
                                        HStack{
                                            Image(systemName: rule3 ? "checkmark.square" : "square")
                                                .onTapGesture {
                                                    rule3.toggle()
                                                }
                                            Text("이용약관")
                                            Text("(필수)")
                                                .font(.system(size: 10))
                                        }
                                            .font(.system(size: 13))
                            
                            Spacer()
                            Spacer()
                                        HStack{
                                            Image(systemName: rule4 ? "checkmark.square" : "square")
                                                .onTapGesture {
                                                    rule4.toggle()
                                                }
                                                Text("개인정보수집 및 개인동의")
                                                Text("(필수)")
                                                .font(.system(size: 10))
                                        }
                                        .font(.system(size: 13))
                                    }
                        .overlay(
                                Rectangle()
                                    .stroke(Color.gray)
                                    .frame(width: 360, height: 150)
                                    .position(x: 180, y: 60)
                        )
//                                )
//                        }
                        .padding()
                    }
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Button(action: {
    
                    }, label: {
                        Text("회원가입")
                    })
                    .frame(width: 360, height: 50)
                    .background(Color.accentColor)
                    .cornerRadius(12)
                    .foregroundStyle(Color.white)
                }
                    .navigationBarTitle("회원가입")
            }
        }
    }
}

func checkEmail(email: String) -> Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
    return  NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
}

#Preview {
    RegisterView()
}
