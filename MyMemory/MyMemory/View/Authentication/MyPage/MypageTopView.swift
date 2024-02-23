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
//    @EnvironmentObject var viewModel: MypageViewModel
    @State var profile: Profile? = nil
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
                        
                        // Tabbar 5번째 칸이 변경된다면 다시 추가
//                        NavigationLink {
//                            
//                            SettingView (user: $authViewModel.currentUser,
//                                         isCurrentUserLoginState: $authViewModel.isCurrentUserLoginState // 💁
//                            )
//                            .customNavigationBar(
//                                centerView: {
//                                    Text("설정")
//                                        .font(.semibold16)
//                                        .foregroundStyle(Color.textColor)
//                                },
//                                leftView: {
//                                    BackButton()
//                                },
//                                rightView: {
//                                    EmptyView()
//                                },
//                                backgroundColor: Color.bgColor3
//                            )
//                            
//                  
//                            
//                        } label: {
//                            Image(systemName: "gearshape")
//                                .font(.system(size: 24))
//                                .foregroundStyle(Color.iconColor)
//                        }
                        
                        
                    }
                    
                    
                    
                }
                
            }
            .padding(.horizontal)
            if let uid = AuthService.shared.currentUser?.id {
                UserStatusCell(uid: uid, memoCreator: $profile)
            }
        }
        .onAppear {
            Task { // 로그인 안하면 실행 x
                if let currentUser = authViewModel.currentUser {
                    await authViewModel.followAndFollowingCount(user: currentUser)
                    self.profile = await authViewModel.memoCreatorfetchProfile(uid: currentUser.id!)
                }
            }
//            viewModel.fetchUserProfile()
        }
    }
}
