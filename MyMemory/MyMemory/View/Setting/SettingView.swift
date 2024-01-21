//
//  SettingView.swift
//  MyMemory
//
//  Created by 이명섭 on 1/7/24.
//

import SwiftUI

struct SettingView: View {
    @StateObject var settingViewModel: SettingViewModel = .init()
    @Binding var userInfo: UserInfo?
    @Binding var isCurrentUserLoginState: Bool
    
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
                            }.foregroundStyle(.black)
                            
                            Divider()
                        }
                    }.padding(.horizontal, 9)
                }
            }
            
            if settingViewModel.isCurrentUserLoginState {
                VStack(alignment: .trailing) {
                    Button {
                        settingViewModel.fetchUserLogout {
                            isCurrentUserLoginState = false
                            settingViewModel.isShowingLogoutAlert = true
                        }
                    } label: {
                        Text("로그아웃")
                            .foregroundStyle(.white)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .background(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .alert("로그아웃 되었습니다.", isPresented: $settingViewModel.isShowingLogoutAlert) {
                        Button("확인", role: .cancel) {
                            
                        }
                    }
                    
                    NavigationLink {
                        WithdrawalView(
                            isCurrentUserLoginState: $isCurrentUserLoginState,
                            userInfo: $userInfo
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
//        .navigationBarBackButtonHidden(true)
//        .toolbar {
//            ToolbarItem(placement: .topBarLeading) {
//                BackButton()
//                    .foregroundStyle(Color.black)
//            }
//            
//            ToolbarItem(placement: .principal) {
//                Text("내 정보")
//                    .font(.semibold16)
//            }
//        }
    }
}
