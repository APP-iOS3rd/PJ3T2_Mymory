//
//  OtherUserTopView.swift
//  MyMemory
//
//  Created by 정정욱 on 1/30/24.
//


import SwiftUI
import Kingfisher
// 마이페이지 최상단의 프로필 및 닉네임 등을 표시하는 View입니다.

enum SortedFollow: String, CaseIterable, Identifiable {
    case unfollow = "팔로우 취소"
    case block = "차단하기"
    case report = "신고하기"
    
    var id: SortedFollow { self }
}

struct OtherUserTopView: View {
    @Binding var memoCreator: Profile?
    @StateObject var authViewModel : AuthService = .shared
    @State var isFollow: Bool = false
    @State var isShowingOption:Bool = false
    
    var body: some View {
        VStack {
            HStack {
                if let imageUrl = memoCreator?.profilePicture, let url = URL(string: imageUrl) {
                    KFImage(url)
                        .resizable()
                        .scaledToFill()
                        .clipped()
                        .clipShape(.circle)
                        .frame(width: 60, height: 60)
                } else {
                    Circle()
                        .frame(width: 60, height: 60)
                        .foregroundStyle(Color(hex: "d9d9d9"))
                }
                
                Text(memoCreator?.name ?? "김메모")
                    .font(.semibold20)
                    .foregroundStyle(Color.textColor)
                    .padding(.leading, 10)
                
                
                Spacer()
                if !(memoCreator?.isCurrentUser  == true){
                    if memoCreator?.isFollowing == false {
                        Button {
                            Task {
                                if let user = memoCreator?.toUser {
                                    
                                    await authViewModel.userFollow(followUser: user) { err in
                                        guard err == nil else {
                                            memoCreator?.isFollowing = false

                                            return
                                        }
                                    }
                                    await authViewModel.followAndFollowingCount(user: user)
                                    memoCreator?.isFollowing = true
                                    memoCreator?.followerCount += 1

                                }
                            }
                        } label: {
                            HStack {
                                Text("팔로우")
                            }
                        }
                        .buttonStyle(RoundedRect.follow)
                        
                    } else {
                        Button {
                            isShowingOption.toggle()
                        } label: {
                            HStack {
                                Text("팔로잉")
                                Image(systemName: "chevron.down")
                            }
                            .foregroundColor(.white)
                        }
                        .buttonStyle(RoundedRect.follow)
                        .confirmationDialog("", isPresented: $isShowingOption) {
                            ForEach(SortedFollow.allCases, id: \.id) { type in
                                Button(type.rawValue) {
                                    if type.rawValue == "팔로우 취소" {
                                        Task {
                                            if let user = memoCreator?.toUser {
                                                await authViewModel.userUnFollow(followUser: user) { err in
                                                    memoCreator?.isFollowing = true

                                                    guard err == nil else {
                                                        return
                                                    }
                                                }
                                                memoCreator?.isFollowing = false
                                                memoCreator?.followerCount -= 1
                                                await authViewModel.followAndFollowingCount(user: user)
                                            }
                                        }
                                    }
                                }
                                
                            }
                            
                        }
                    }
                }
            }
            .padding(.horizontal)
            if let uid = memoCreator?.id {
                UserStatusCell(uid: uid, memoCount: memoCreator?.memoCount,memoCreator: $memoCreator)
            }
        }
        .onAppear {
            Task {
                if let user = memoCreator?.toUser {
                    
                    await authViewModel.followCheck(followUser: user) { didFollow in
                        print("didFollow \(didFollow)")
                        isFollow = didFollow ?? false
                    }
                    await authViewModel.followAndFollowingCount(user: user)
                    // 이제 counts를 사용할 수 있습니다.
                }
            }
        }
    }
}
