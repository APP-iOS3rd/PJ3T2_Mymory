//
//  OtherUserProfileView.swift
//  MyMemory
//
//  Created by 정정욱 on 1/30/24.
//


import SwiftUI
import Kingfisher
// 마이페이지 최상단의 프로필 및 닉네임 등을 표시하는 View입니다.
struct OtherUserProfileView: View {
    @Binding var memoCreator: User 
    @ObservedObject var viewModel: MypageViewModel
    @ObservedObject var authViewModel : AuthViewModel = .shared
    
    var body: some View {
        HStack {
            
            if let imageUrl = memoCreator.profilePicture, let url = URL(string: imageUrl) {
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
            
            Text(memoCreator.name ?? "김메모")
                .font(.semibold20)
                .foregroundStyle(Color.textColor)
                .padding(.leading, 10)
            
            VStack{
                Text("357")
                Text("팔로워")
            }
            .padding(.leading, 10)
            VStack{
                Text("445")
                Text("팔로잉")
            }
            .padding(.leading, 10)
        }
        .buttonStyle(.plain)
        
        
        
        
        //        NavigationLink {
        //
        //            SettingView (user: $viewModel.user,
        //                         isCurrentUserLoginState: $viewModel.isCurrentUserLoginState
        //            )
        //
        //            .customNavigationBar(
        //                centerView: {
        //                    Text("내 정보")
        //                },
        //                leftView: {
        //                    EmptyView()
        //                },
        //                rightView: {
        //                    CloseButton()
        //                },
        //                backgroundColor: .white
        //            )
        //
        //        } label: {
        //            Image(systemName: "gearshape")
        //                .font(.system(size: 24))
        //                .foregroundStyle(.black)
        //        }
        
        // 다른 사용자가 볼때는 팔로잉, 팔로우로 보이게
    }
        
    
}

