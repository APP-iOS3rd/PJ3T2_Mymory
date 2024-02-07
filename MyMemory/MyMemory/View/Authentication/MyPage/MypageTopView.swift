//
//  MypageTopView.swift
//  MyMemory
//
//  Created by 정정욱 on 1/30/24.
//

import SwiftUI
import Kingfisher


// 마이페이지 최상단의 프로필 및 닉네임 등을 표시하는 View입니다.
struct MypageTopView: View {
    @ObservedObject var authViewModel : AuthService = .shared
    
    var body: some View {
        VStack {
            HStack {
                
                if authViewModel.currentUser != nil && UserDefaults.standard.string(forKey: "userId") != nil {
                    HStack(alignment: .center){
                        NavigationLink {
                            ProfileEditView(
                                existingProfileImage:
                                    authViewModel.currentUser?.profilePicture,
                                uid: authViewModel.currentUser?.id ?? ""
                            )
                        } label: {
                            if let imageUrl = authViewModel.currentUser?.profilePicture, let url = URL(string: imageUrl) {
                                KFImage(url)
                                    .resizable()
                                    .scaledToFill()
                                    .clipped()
                                    .clipShape(.circle)
                                    .frame(width: 76, height: 76)
                            } else {
                                Circle()
                                    .frame(width: 76, height: 76)
                                    .foregroundStyle(Color(hex: "d9d9d9"))
                            }
                            
                            Text(authViewModel.currentUser?.name ?? "김메모")
                                .font(.semibold20)
                                .foregroundStyle(Color.textColor)
                                .padding(.leading, 10)
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        NavigationLink {
                            
                            SettingView (user: $authViewModel.currentUser,
                                         isCurrentUserLoginState: $authViewModel.isCurrentUserLoginState // 💁
                            )
                            
                            .customNavigationBar(
                                centerView: {
                                    Text("내 정보")
                                },
                                leftView: {
                                    EmptyView()
                                },
                                rightView: {
                                    CloseButton()
                                },
                                backgroundColor: Color.bgColor
                            )
                            
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.system(size: 24))
                                .foregroundStyle(Color.iconColor)
                        }
                        
                        
                    }
                    
                    
                    
                }
                
            }
            
            UserStatusCell()
        }
        .onAppear {
            Task { // 로그인 안하면 실행 x
                if let currentUser = authViewModel.currentUser {
                    await authViewModel.followAndFollowingCount(user: currentUser)
                }
                
            }
        }
    }
}
