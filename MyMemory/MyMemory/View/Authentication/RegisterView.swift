//
//  RegisterView.swift
//  MyMemory
//
//  Created by hyunseo on 1/8/24.
//

import SwiftUI
import Photos
import PhotosUI

struct RegisterView: View {
   
    enum Field {
        case email
        case password
        case secondpassword
        case name
    }
    @FocusState private var focusedField: Field?
    
    @EnvironmentObject var viewModel : AuthViewModel
    @State private var isActive: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.bgColor3
                
                ScrollView {
                    VStack() {
                        Spacer()
                        PhotosPicker(
                            selection: $viewModel.selectedItem,
                            matching: .images
                        ){
                            if viewModel.imageSelected == false {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width:180, height: 180)
                                    .foregroundStyle(Color.gray)
                            } else {
                                if let imageData = viewModel.selectedImageData,
                                   let uiImage = UIImage(data: viewModel.selectedImageData!) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .clipShape(Circle())
                                        .frame(width: 180, height: 180)
                                }
                            }
                        }
                        
                        Spacer(minLength: 16)
                        VStack(alignment: .leading) {
                            VStack(alignment: .leading) {
                                Text("이메일")
                                    .font(.system(size: 15))
                                TextField("example@example.com", text: $viewModel.email)
                                    .keyboardType(.emailAddress)
                                    .focused($focusedField, equals: .email)
                                
                                Divider()
                                    .padding(.vertical, -5)
                                HStack {
                                    Text(viewModel.checkEmail(email: viewModel.email) ? "사용 가능한 이메일입니다!" : "사용할수 없는 이메일입니다")
                                        .font(.system(size: 15))
                                        .foregroundStyle(viewModel.email == "" ? Color.white : (viewModel.checkEmail(email: viewModel.email) ? Color.green : Color.red))
                                }
                            }
                            .padding()
                            
                            VStack(alignment: .leading) {
                                Text("비밀번호")
                                    .font(.system(size: 15))
                                SecureField("특수문자와 숫자/대문자를 포함한 8글자", text: $viewModel.password)
                                    .focused($focusedField, equals: .password)
                                Divider()
                                    .padding(.vertical, -5)
                                Text(viewModel.checkPassword(password: viewModel.password) ? "사용 가능한 비밀번호입니다" : "특수문자,숫자,대문자를 포함한 8글자 이상으로 설정하세요!")
                                    .font(.system(size: 15))
                                    .foregroundStyle(viewModel.password == "" ? Color.white : (viewModel.checkPassword(password: viewModel.password) ? Color.green : Color.red))
                            }
                            .padding()
                            
                            VStack(alignment: .leading) {
                                Text("비밀번호 확인")
                                    .font(.system(size: 15))
                                SecureField("비밀번호를 다시 입력해주세요", text: $viewModel.secondPassword)
                                    .focused($focusedField, equals: .secondpassword)
                                Divider()
                                    .padding(.vertical, -5)
                                Text(viewModel.checkSecondPassword(secondPassword: viewModel.secondPassword) ? "" : "비밀번호가 일치하지않습니다")
                                    .font(.system(size: 15))
                                    .foregroundStyle(viewModel.checkSecondPassword(secondPassword: viewModel.secondPassword) ? Color.green : Color.red)
                            }
                            .padding()
                            
                            VStack(alignment: .leading) {
                                Text("이름")
                                    .font(.system(size: 15))
                                TextField("이름을 입력해주세요", text: $viewModel.name)
                                    .focused($focusedField, equals: .name)
                                Divider()
                                    .padding(.vertical, -5)
                            }
                            .padding()
                            
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: viewModel.agreeAllBoxes ? "checkmark.square" : "square")
                                        .onTapGesture {
                                            viewModel.agreeAllBoxes.toggle()
                                            if viewModel.agreeAllBoxes == true {
                                                viewModel.checkAllBoxes()
                                            } else {
                                                viewModel.uncheckAllBoxes()
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
                                
                                Spacer(minLength: 16)
                                HStack {
                                    Image(systemName: viewModel.overFourteenBox ? "checkmark.square" : "square")
                                        .onTapGesture {
                                            viewModel.overFourteenBox.toggle()
                                        }
                                    Text("만 14세 이상입니다")
                                    Text("(필수)")
                                        .font(.system(size: 10))
                                }
                                .font(.system(size: 13))
                                
                                Spacer(minLength: 16)
                                HStack {
                                    Image(systemName: viewModel.termsOfUseBox ? "checkmark.square" : "square")
                                        .onTapGesture {
                                            viewModel.termsOfUseBox.toggle()
                                        }
                                    Text("이용약관")
                                    Text("(필수)")
                                        .font(.system(size: 10))
                                    Spacer()
                                    Button(action: {
                                        viewModel.showPrivacyPolicy = true
                                    }) {
                                        Image(systemName: "chevron.forward")
                                            .foregroundStyle(Color.gray)
                                            .font(.system(size: 15))
                                            .padding(.trailing, 20)
                                    }
                                    .sheet(isPresented: $viewModel.showPrivacyPolicy) {
                                        RegisterViewModel.SafariView(url:URL(string: viewModel.privacyPolicyUrlString)!)
                                            .ignoresSafeArea()

                                    }
                                }
                                .font(.system(size: 13))
                                Spacer(minLength: 16)
                                    HStack{
                                        Image(systemName: viewModel.privacyPolicyBox ? "checkmark.square" : "square")
                                            .onTapGesture {
                                                viewModel.privacyPolicyBox.toggle()
                                            }
                                            Text("개인정보수집 및 개인동의")
                                            Text("(필수)")
                                            .font(.system(size: 10))
                                        Spacer()
                                        Button(action: {
                                            viewModel.showTermsOfUse = true
                                        }) {
                                            Image(systemName: "chevron.forward")
                                                .foregroundStyle(Color.gray)
                                                .font(.system(size: 15))
                                                .padding(.trailing, 20)
                                        }
                                        .sheet(isPresented: $viewModel.showTermsOfUse) {
                                            RegisterViewModel.SafariView(url:URL(string: viewModel.termsOfUseUrlString)!)
                                                .ignoresSafeArea()
                                        }
                                    }
                                    .font(.system(size: 13))
                                }
                                .padding(12)
                                
                                .background(
                                    Rectangle()
                                        .stroke(Color.borderColor)
                                )
                                .padding()
                        }
                        Spacer(minLength: 32)
                        Button(action: {
                            if viewModel.checkIfCanRegister() {
                                viewModel.userCreate()
                                print("Register Completed")
                                self.isActive = true
                            } else {
                                print("Register failed")
                            }
                        }, label: {
                            Text("회원가입")
                        })
                        .frame(width: 360, height: 50)
                        .background(Color.accentColor)
                        .cornerRadius(12)
                        .foregroundStyle(Color.white)
                    }
                    .onSubmit {
                        switch focusedField {
                        case .email:
                            focusedField = .password
                        case .password:
                            focusedField = .secondpassword
                        case .secondpassword:
                            focusedField = .name
                        default:
                            print("Done")
                        }
                    }
                    .fullScreenCover(isPresented: $isActive) {
                        MainTabView()
                    }
                        
                }
            }
        }
        .onAppear {
            UITextField.appearance().clearButtonMode = .whileEditing
        }
        .onChange(of: viewModel.selectedItem) {newItem in
            viewModel.imageSelected = true
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    viewModel.selectedImageData = data
                }
            }
        }
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
            backgroundColor: .bgColor3
        )
        .environmentObject(viewModel)
    }
}

//#Preview {
//    RegisterView()
//}

