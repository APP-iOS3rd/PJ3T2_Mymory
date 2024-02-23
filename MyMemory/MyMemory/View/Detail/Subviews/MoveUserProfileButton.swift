//
//  MoveUserProfileButton.swift
//  MyMemory
//
//  Created by 정정욱 on 1/29/24.
//

import SwiftUI
import Kingfisher

struct MoveUserProfileButton: View {

    @StateObject var viewModel: MoveUserProfileViewModel
//    @ObservedObject var otherUserViewModel: OtherUserViewModel = .init()
    @ObservedObject var authService: AuthService = .shared
    @Binding var presentLoginAlert: Bool
    @Binding var memo: Memo
    var body: some View {
        HStack {
            NavigationLink {
                OtherUserProfileView(memoCreator: viewModel.userProfile?.toUser ?? User(email: "", name: ""))
//                    .environmentObject(otherUserViewModel)
            } label: {
                if let imageUrl = viewModel.userProfile?.profilePicture, let url = URL(string: imageUrl) {
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
                    Text(viewModel.userProfile?.name ?? "")
//                        .foregroundStyle(Color.textColor)
//                        .font(.bold18)
                        .font(.userMainTextFont(baseSize: 18))

                }
            }
//            .border(width: 1, edges: [.top], color: Color.bgColor)
            
            Spacer()
            
            if AuthService.shared.currentUser?.id != viewModel.userProfile?.id {
                Button {
                    if AuthService.shared.currentUser == nil {
                        self.presentLoginAlert = true
                    } else if let otherUser = viewModel.userProfile?.toUser {
                        self.viewModel.fetchFollowAndUnfollowOtherUser(otherUser: otherUser)
                    }
                } label: {
                    Text(viewModel.userProfile?.isFollowing == true ? "팔로잉" : "팔로우")
                        .foregroundStyle(viewModel.userProfile?.isFollowing == true ? Color.textColor : Color.white)
                        .font(.regular14)
                        .frame(minWidth: 85)
                        .frame(height: 30)
                }
                .background(viewModel.userProfile?.isFollowing == true ? Color(uiColor: UIColor.systemGray3) : Color.accentColor)
                .cornerRadius(5, corners: .allCorners)

                .onAppear {
                    if let otherUserId = self.viewModel.userProfile?.id {
                        Task {
                            viewModel.fetchUserProfile(with:otherUserId)
 
                        }
                    }
                }
            }
        }        
        .onAppear{
            viewModel.fetchUserProfile(with: memo.userUid)
        }

        .padding()
    }
}

