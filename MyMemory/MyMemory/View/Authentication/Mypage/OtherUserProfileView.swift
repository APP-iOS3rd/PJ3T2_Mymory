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
    @State var isFollow: Bool = false
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
        .onAppear {
            authViewModel.FollowCheck(followUser: memoCreator) { didFollow in
                print("didFollow \(didFollow)")
                isFollow = didFollow ?? false
            }
        }
        
        if isFollow == false {
            Button {
                authViewModel.UserFollow(followUser: memoCreator) { err in
                    guard err == nil else {
                        return
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "location.fill")
                    Text("Follow")
                }
            }
            .buttonStyle(RoundedRect.primary)
            
        } else {
            Button {
                authViewModel.UnUserFollow(followUser: memoCreator) { err in
                    guard err == nil else {
                        return
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "location.fill")
                    Text("UnFollow")
                }
            }
            .buttonStyle(RoundedRect.primary)
            
        }

     
    }
       
    
}
