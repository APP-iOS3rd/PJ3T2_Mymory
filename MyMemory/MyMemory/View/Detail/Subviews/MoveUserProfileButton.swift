//
//  MoveUserProfileButton.swift
//  MyMemory
//
//  Created by 정정욱 on 1/29/24.
//

import SwiftUI
import Kingfisher

struct MoveUserProfileButton: View {

    @ObservedObject var viewModel: DetailViewModel
    @ObservedObject var otherUserViewModel: OtherUserViewModel = .init()
    @Binding var presentLoginAlert: Bool
    
    var body: some View {
        HStack {
            NavigationLink {
                OtherUserProfileView(memoCreator: viewModel.memoCreator ?? User(email: "", name: ""))
                    .environmentObject(otherUserViewModel)
                
            } label: {
                if let imageUrl = viewModel.memoCreator?.profilePicture, let url = URL(string: imageUrl) {
                    KFImage(url)
                        .resizable()
                        .scaledToFill()
                        .foregroundStyle(.white)
                        .clipped()
                        .clipShape(.circle)
                        .frame(width: 46, height: 46)
                } else {
                    Circle()
                        .frame(width: 46, height: 46)
                        .foregroundStyle(Color.darkGray)
                }
                
            
                VStack(alignment: .leading) {
                    Text(viewModel.memoCreator?.name ?? "")
                        .foregroundStyle(Color.textColor)
                        .font(.bold18)
                }
            }
//            .border(width: 1, edges: [.top], color: Color.bgColor)
            
            Spacer()
            
            if AuthService.shared.currentUser?.id != viewModel.memoCreator?.id {
                Button {
                    if AuthService.shared.currentUser == nil {
                        self.presentLoginAlert = true
                    } else if let otherUser = viewModel.memoCreator {
                        self.viewModel.fetchFollowAndUnfollowOtherUser(otherUser: otherUser)
                    }
                } label: {
                    Text(viewModel.isFollowingUser ? "팔로잉" : "팔로우")
                        .foregroundStyle(viewModel.isFollowingUser ? Color.textColor : Color.white)
                        .font(.regular14)
                        .frame(minWidth: 85)
                        .frame(height: 30)
                }
                .background(viewModel.isFollowingUser ? Color(uiColor: UIColor.systemGray3) : Color.accentColor)
                .cornerRadius(5, corners: .allCorners)
            }
        }
        .onAppear {
            if let otherUser = viewModel.memoCreator {
                Task {
                    AuthService.shared.followCheck(followUser: otherUser, completion: { value in
                        if let follwValue = value {
                            self.viewModel.isFollowingUser = follwValue
                        }
                    })
                }
            }
        }
    }
}

