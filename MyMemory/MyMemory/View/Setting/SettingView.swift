//
//  SettingView.swift
//  MyMemory
//
//  Created by 이명섭 on 1/7/24.
//

import SwiftUI
import UserNotifications

struct SettingView: View {
    @StateObject var settingViewModel: SettingViewModel = .init()
    @StateObject var themeViewModel: ThemeViewModel = .init()
    @StateObject var authViewModel: AuthService = .shared
    @Binding var user: User?
    @Binding var isCurrentUserLoginState: Bool
  
   // @Environment(\.presentationMode) var presentationMode
    @Binding var selected: Int // 나중에 SettingView가 안으로 들어간다면 제거해주세요...
    
    var body: some View {
        ScrollView() {
            VStack(alignment: .leading) {
                VStack(spacing: 36) {
                    VStack(alignment: .leading, spacing: 22) {
                        Group {
                            Text("일반")
                                .font(.regular12)
                                .opacity(0.3)
                            //  SettingMenuCell(name: "로그인 정보", page: "loginInfo")
                            Toggle("알림", isOn: $settingViewModel.isAblePushNotification)
                                .disabled(true)
                                .padding(.trailing, 3)
                                .font(.medium14)
                                .foregroundStyle(Color.textColor)
                                .onTapGesture {
                                    settingViewModel.moveToNotificationSetting()
                                }
                                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                                    Task {
                                        await settingViewModel.changeToggleState()
                                    }
                                }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 22) {
                        Group {
                            Text("앱 정보")
                                .font(.regular12)
                                .opacity(0.3)
                            SettingMenuCell(name: "개인정보 처리방침", page: "termsOfPrivacy")
                            SettingMenuCell(name: "이용약관", page: "termsOfUse")
                            HStack(alignment: .center) {
                                Text("오픈소스 라이센스")
                                    .font(.medium14)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 17))
                                    .opacity(0.3)
                            }
                            .contentShape(Rectangle())
                            .foregroundStyle(Color.textColor)
                            .onTapGesture {
                                self.settingViewModel.moveToOpenSourceLicenseMenu()
                            }
                            
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
                
                
                if authViewModel.currentUser != nil {
                    
                    if isCurrentUserLoginState {
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
                                        authViewModel.currentUser = nil
                                        // tab 0으로 이동
                                        //   selected = 0
                                        // authViewModel.currentUser = nil
                                        // presentationMode.wrappedValue.dismiss()
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
               
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 34)
        .onChange(of: authViewModel.currentUser) { currentUser in
               if currentUser == nil {
               
                   selected = 0
               }
           }
       
    }
}
