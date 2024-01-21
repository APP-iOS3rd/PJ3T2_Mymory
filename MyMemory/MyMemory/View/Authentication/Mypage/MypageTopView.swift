//
//  MypageTopView.swift
//  MyMemory
//
//  Created by 이명섭 on 1/18/24.
//

import SwiftUI
// 마이페이지 최상단의 프로필 및 닉네임 등을 표시하는 View입니다.
struct MypageTopView: View {
    @EnvironmentObject var viewModel: MypageViewModel
    
    var body: some View {
        HStack {
            if viewModel.isCurrentUserLoginState {
                NavigationLink {
                    ProfileEditView(
                        existingProfileImage: viewModel.userInfo?.profilePicture,
                        uid: viewModel.userInfo?.id ?? ""
                    )
                } label: {
                    if let imageUrl = viewModel.userInfo?.profilePicture, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .clipped()
                                .clipShape(.circle)
                        } placeholder: {
                            ProgressView()
                        }.frame(width: 76, height: 76)
                    } else {
                        Circle()
                            .frame(width: 76, height: 76)
                            .foregroundStyle(Color(hex: "d9d9d9"))
                    }
                    
                    Text(viewModel.userInfo?.name ?? "")
                        .font(.semibold20)
                        .padding(.leading, 10)
                }
                .buttonStyle(.plain)
            } else {
                NavigationLink {
                    LoginView()
                } label: {
                    Text("로그인이 필요합니다.")
                        .font(.semibold20)
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
            
            NavigationLink {
                SettingView(isCurrentUserLoginState: $viewModel.isCurrentUserLoginState)
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 24))
                    .foregroundStyle(.black)
            }
        }
        .padding(.top, 30)
        
    }
}
