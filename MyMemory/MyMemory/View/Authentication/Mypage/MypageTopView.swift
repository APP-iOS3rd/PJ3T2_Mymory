//
//  MypageTopView.swift
//  MyMemory
//
//  Created by 이명섭 on 1/18/24.
//

import SwiftUI
import Kingfisher
// 마이페이지 최상단의 프로필 및 닉네임 등을 표시하는 View입니다.
struct MypageTopView: View {
    
    @ObservedObject var viewModel: MypageViewModel 
    @ObservedObject var authViewModel : AuthViewModel = .shared
    
    var body: some View {
        HStack {
            if authViewModel.currentUser != nil && UserDefaults.standard.string(forKey: "userId") != nil {
                NavigationLink {
                    ProfileEditView(
                        existingProfileImage:
                            viewModel.user?.profilePicture,
                        uid: viewModel.user?.id ?? ""
                    )
                } label: {
                    if let imageUrl = viewModel.user?.profilePicture, let url = URL(string: imageUrl) {
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
                    
                    Text(viewModel.user?.name ?? "김메모")
                        .font(.semibold20)
                        .foregroundStyle(Color.textColor)
                        .padding(.leading, 10)
                }
                .buttonStyle(.plain)
                
                VStack{
                    Text("\(authViewModel.followerCount)")
                    Text("팔로워")
                }
                
                
                VStack{
                    Text("\(authViewModel.followingCount)")
                    Text("팔로잉")
                }
                
                .padding(.leading, 10)
            }
            
            
            else {
                NavigationLink {
                    LoginView()
                        .customNavigationBar(
                            centerView: {
                                Text(" ")
                            },
                            leftView: {
                                EmptyView()
                            },
                            rightView: {
                                CloseButton()
                            },
                            backgroundColor: .white
                        )
                } label: {
                    Text("로그인이 필요합니다.")
                        .font(.semibold20)
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
            
            NavigationLink {
            
                SettingView (user: $viewModel.user,
                    isCurrentUserLoginState: $viewModel.isCurrentUserLoginState
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
                    backgroundColor: .white
                )

            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 24))
                    .foregroundStyle(.black)
            }
            
            // 다른 사용자가 볼때는 팔로잉, 팔로우로 보이게 
        }
        .onAppear {
            Task { // 로그인 안하면 실행 x
                if let currentUser = authViewModel.currentUser {
                    await authViewModel.followAndFollowingCount(user: currentUser)
                }
            }
        }

        .padding(.top, 30)
        
    }
}
