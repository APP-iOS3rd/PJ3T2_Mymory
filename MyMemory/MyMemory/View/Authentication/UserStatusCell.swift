//  UserStatusCell.swift
//  MyMemory
//
//  Created by 김소혜 on 2/5/24.
//

import SwiftUI

struct UserStatusCell: View {
    
    @ObservedObject var authViewModel: AuthService = .shared
    @StateObject var followerFollowingViewModel: FollowerFollowingViewModel = FollowerFollowingViewModel()
    @State var uid: String
    @State var memoCount: Int?
    @State private var isFollowFollowingListActive = false
    var body: some View {
        HStack {
            VStack {
                Text("\(memoCount ?? 0)")
                    .font(.bold16)
                Text("메모")
                    .font(.light14)
            }
            .frame(maxWidth: .infinity)
            Divider()
            
            
            
            NavigationLink(destination: FollowFollowingList(followerFollowingViewModel: followerFollowingViewModel, uid: $uid, choiceTab: 0)) {
                VStack {
                    Text("\(authViewModel.followerCount)")
                        .font(.bold16)
                    Text("팔로워")
                        .font(.light14)
                }
                .frame(maxWidth: .infinity)
            }
            .environmentObject(followerFollowingViewModel)
            
            
            Divider()

            NavigationLink(destination: FollowFollowingList(followerFollowingViewModel: followerFollowingViewModel, uid: $uid, choiceTab: 1)) {
                VStack {
                    Text("\(authViewModel.followingCount)")
                        .font(.bold16)
                    Text("팔로잉")
                        .font(.light14)
                }
                .frame(maxWidth: .infinity)
                .padding(.leading, 10)
            }
            .environmentObject(followerFollowingViewModel)
            
            
            
        }
        .onAppear(perform: {
            Task { @MainActor in
                 
                self.memoCount = await AuthService.shared.fetchUserMemoCount(with: uid)
                
                await followerFollowingViewModel.fetchFollowingUserList(with: uid)
                await followerFollowingViewModel.fetchFollowerUserList(with: uid)
            }
        })
        .frame(maxWidth: .infinity)
        .padding(.vertical,18)
    }
}

//#Preview {
//    UserStatusCell()
//}
