//
//  SettingView.swift
//  MyMemory
//
//  Created by 이명섭 on 1/7/24.
//

import SwiftUI

struct SettingView: View {
    @StateObject var settingViewModel: SettingViewModel = .init()
    @StateObject var authViewModel: AuthService = .shared
    @Binding var user: User?
    @Binding var isCurrentUserLoginState: Bool
    @Environment(\.presentationMode) var presentationMode
  
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView() {
                VStack(spacing: 36) {
                    VStack(alignment: .leading, spacing: 22) {
                        Group {
                            Text("일반")
                                .font(.regular12)
                                .opacity(0.3)
                            SettingMenuCell(name: "로그인 정보")
                            SettingMenuCell(name: "알림")
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 22) {
                        Group {
                            Text("스타일")
                                .font(.regular12)
                                .opacity(0.3)
                            SettingMenuCell(name: "테마", page: "theme")
                            SettingMenuCell(name: "폰트", page: "font")
                        }
                    }
                    
                    
                    VStack(alignment: .leading, spacing: 22) {
                        Group {
                            Text("앱 정보")
                                .font(.regular12)
                                .opacity(0.3)
                            SettingMenuCell(name: "개인정보 처리방침", page: "termsOfPrivacy")
                            SettingMenuCell(name: "이용약관", page: "termsOfUse")
                            SettingMenuCell(name: "오픈소스 라이센스")
                            HStack(alignment: .center) {
                                Text("앱 버전")
                                    .font(.regular14)
                                Spacer()
                                Text(settingViewModel.version)
                                    .opacity(0.6)
                            }
                            .foregroundStyle(Color.textColor)
                        }
                    }
                }
            }
            
            if authViewModel.currentUser != nil {
                VStack(alignment: .trailing, spacing: 56) {
                    Button {
                        settingViewModel.isShowingLogoutAlert = true
                    } label: {
                        Text("로그아웃")
                            .foregroundStyle(.white)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .background(.accent)
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
        .padding(.horizontal, 16)
        .padding(.top, 34)
        .customNavigationBar(
            centerView: {
                Text("내 정보")
            },
            leftView: {
                BackButton()
            },
            rightView: {
                EmptyView()
            },
            backgroundColor: Color.bgColor3
        )
    }
}
