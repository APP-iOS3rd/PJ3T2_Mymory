//
//  SettingView.swift
//  MyMemory
//
//  Created by 이명섭 on 1/7/24.
//

import SwiftUI

struct SettingView: View {
    @StateObject var settingViewModel: SettingViewModel = .init()
    @StateObject var authViewModel: AuthViewModel = .shared
    @Binding var user: User?
    @Binding var isCurrentUserLoginState: Bool
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView() {
                VStack(alignment: .leading){
                    Text("일반")
                        .font(.semibold14)
                        .padding(.top, 36)
                        .padding(.bottom, 32)
                    
                    VStack(spacing: 12) {
                        Group {
                            SettingMenuCell(name: "로그인 정보")
                            Divider()
                                .padding(.bottom, 20)
                            SettingMenuCell(name: "알림")
                            Divider()
                        }
                    }.padding(.horizontal, 9)
                    
                    Text("앱 정보")
                        .font(.semibold14)
                        .padding(.bottom, 32)
                        .padding(.top, 19)
                    
                    VStack(spacing: 12) {
                        Group {
                            SettingMenuCell(name: "개인정보 처리방침")
                            Divider()
                                .padding(.bottom, 20)
                            SettingMenuCell(name: "오픈소스 라이센스")
                            Divider()
                                .padding(.bottom, 20)
                            HStack(alignment: .center) {
                                Text("앱 버전")
                                    .font(.regular18)
                                Spacer()
                                Text(settingViewModel.version)
                                    .foregroundStyle(Color(UIColor.systemGray))
                            }
                            .foregroundStyle(Color.textColor)
                            
                            Divider()
                        }
                    }.padding(.horizontal, 9)
                }
            }
            
            if authViewModel.currentUser != nil {
                VStack(alignment: .trailing) {
                    Button {
                        settingViewModel.isShowingLogoutAlert = true
                    } label: {
                        Text("로그아웃")
                            .foregroundStyle(.white)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .background(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .alert("로그아웃 하시겠습니까?", 
                           isPresented: $settingViewModel.isShowingLogoutAlert) {
                        
                        Button("로그아웃", role: .destructive) {
                                                   
                            if authViewModel.signout() {
                            
                                print("로그아웃 성공")
                                UserDefaults.standard.removeObject(forKey: "userId")
                                presentationMode.wrappedValue.dismiss()
                            } else {
                                print("로그아웃 실패")
                            }
                        }
                        
                        Button("뒤로가기", role: .cancel) {}
                    }
                    
                    NavigationLink {
                       
                        WithdrawalView(
                            isCurrentUserLoginState: $isCurrentUserLoginState,
                            user: $user
                        )
                        .environmentObject(settingViewModel)
                        
                    } label: {
                        Text("회원 탈퇴하기")
                            .underline()
                            .foregroundStyle(Color(UIColor.systemGray))
                    }
                }
            }
        }
        .padding(.horizontal, 12)
 
    }
}
