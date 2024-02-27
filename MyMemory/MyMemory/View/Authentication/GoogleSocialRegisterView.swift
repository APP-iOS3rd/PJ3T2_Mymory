//  GoogleSocialRegisterView.swift
//  MyMemory
//
//  Created by hyunseo on 2/8/24.
//

import SwiftUI

import SwiftUI
import Photos
import PhotosUI
import AuthenticationServices
import FirebaseAuth

struct GoogleSocialRegisterView: View {
    
    @EnvironmentObject var viewModel : AuthViewModel
    @Binding var googleCredential: AuthCredential?
    @Binding var isActive: Bool
    @State private var isNewUser: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
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
                            }
                            else {
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
                                Text("이름")
                                    .font(.system(size: 15))
                                TextField("이름을 입력해주세요", text: $viewModel.name)
                                Divider()
                                    .padding(.vertical, -5)
                            }
                            .padding()
                            
                            VStack(alignment: .leading) {
                                HStack{
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
                                HStack{
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
                                HStack{
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
                                            //.padding(.trailing, 20)
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
                                          //  .padding(.trailing, 20)
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
                            if viewModel.checkIfCanSocialRegister() {
                                Task {
                                    print("구글 유저 입니다")
                                    if let alertTitle = await self.viewModel.loginWithGoogle(credential: googleCredential!) {
                                        print(alertTitle)
                                    }
                                }
                                self.isNewUser = true
                                print("Register Completed")
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
                        .alert("회원 가입이 완료되었어요.", isPresented: $isNewUser) {
                            Button("확인", role: .cancel) {
                                self.isActive = true
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                    //                .fullScreenCover(isPresented: $isItActive) {
                    //                    MainTabView()
                    //                }
                    
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
                BackButton()
            },
            rightView: {
                EmptyView()
            },
            backgroundColor: .bgColor3
        )
        .environmentObject(viewModel)
        
    }
}

//
//#Preview {
//    GoogleSocialRegisterView()
//}
 
