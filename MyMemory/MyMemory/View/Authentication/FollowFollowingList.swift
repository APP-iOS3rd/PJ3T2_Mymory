//
//  FollowFollowingList.swift
//  MyMemory
//
//  Created by 정정욱 on 2/19/24.
//

import SwiftUI
import Kingfisher

struct FollowFollowingList: View {
    
    @ObservedObject var followerFollowingViewModel: FollowerFollowingViewModel
    @StateObject var otherUserViewModel = OtherUserViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var goingUserProfile = false
    @Binding var uid: String
    @State var choiceTab: Int
    
    var body: some View {
        
        List {
            if choiceTab == 0 {
                ForEach(followerFollowingViewModel.followerUserList, id: \.id) { user in
                    NavigationLink {
                        OtherUserProfileView(memoCreator: user)
//                            .padding(.horizontal)
                            .environmentObject(otherUserViewModel)
                    } label: {
                        UserListRow(user: user)
                    }
                }
                .onMove(perform: move)
            } else {
                ForEach(followerFollowingViewModel.followingUserList, id: \.id) { user in
                    NavigationLink {
                        OtherUserProfileView(memoCreator: user)
//                            .padding(.horizontal)
                            .environmentObject(otherUserViewModel)
                    } label: {
                        UserListRow(user: user)
                    }
                }
                .onMove(perform: move)
            }
   
        }
        .navigationTitle(Text(choiceTab == 0 ? "팔로워" : "팔로잉"))
        .onAppear {
            Task {@MainActor in
                await followerFollowingViewModel.fetchFollowingUserList(with: uid)
                await followerFollowingViewModel.fetchFollowerUserList(with: uid)
            }
        }
    }
    
    func move(indices: IndexSet, newOffset: Int) {
        if choiceTab == 0 {
            followerFollowingViewModel.followerUserList.move(fromOffsets: indices, toOffset: newOffset)
        } else {
            followerFollowingViewModel.followingUserList.move(fromOffsets: indices, toOffset: newOffset)
        }
    }
}

struct UserListRow: View {
    let user: User
    
    var body: some View {
        HStack {
            if let imageUrl = user.profilePicture, let url = URL(string: imageUrl) {
                KFImage(url)
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .clipShape(.circle)
                    .frame(width: 45, height: 45)
            } else {
                Circle()
                    .frame(width: 45, height: 45)
                    .foregroundStyle(Color(hex: "d9d9d9"))
            }
            
            Text(user.name)
                .font(.body)
                .foregroundColor(Color.textColor)
                .padding(.vertical)
        }
    }
}


//    mutating func delete(indexSet: IndexSet) {
//        authViewModel.followingUserList.remove(atOffsets: indexSet)
//    }



//#Preview {
//    FollowFollowingList()
//}
