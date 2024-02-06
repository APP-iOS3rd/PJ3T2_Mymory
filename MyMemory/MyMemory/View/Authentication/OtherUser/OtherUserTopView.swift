//
//  OtherUserProfileView.swift
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
    @Binding var memoCreator: User
    @ObservedObject var viewModel: OtherUserViewModel
    @ObservedObject var authViewModel : AuthViewModel = .shared
    @State var isFollow: Bool = false
    @State var isShowingOption:Bool = false
    
    var body: some View {
        VStack {
            HStack {
                
                if let imageUrl = memoCreator.profilePicture, let url = URL(string: imageUrl) {
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
                
                Text(memoCreator.name ?? "김메모")
                    .font(.semibold20)
                    .foregroundStyle(Color.textColor)
                    .padding(.leading, 10)
                
                
                Spacer()
                if authViewModel.isFollow == false {
                    Button {
                        Task {
                            await authViewModel.userFollow(followUser: memoCreator) { err in
                                guard err == nil else {
                                    return
                                }
                            }
                            await authViewModel.followAndFollowingCount(user: memoCreator)
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
                        
                        .foregroundColor(.accentColor)
                        // .fixedSize(horizontal: true, vertical: false)
                    }
                    .buttonStyle(RoundedRect.follow)
                    .confirmationDialog("", isPresented: $isShowingOption) {
                        ForEach(SortedFollow.allCases, id: \.id) { type in
                            Button(type.rawValue) {
                                if type.rawValue == "팔로우 취소" {
                                    Task {
                                        await authViewModel.userUnFollow(followUser: memoCreator) { err in
                                            guard err == nil else {
                                                return
                                            }
                                        }
                                        await authViewModel.followAndFollowingCount(user: memoCreator)
                                    }
                                }
                                
                                
                            }
                            
                        }
                        
                    }
                }
                
                
                
            }
            
            
            UserStatusCell()
        }
        .onAppear {
            Task {
                await authViewModel.followCheck(followUser: memoCreator) { didFollow in
                    print("didFollow \(didFollow)")
                    isFollow = didFollow ?? false
                }
                
                await authViewModel.followAndFollowingCount(user: memoCreator)
                // 이제 counts를 사용할 수 있습니다.
            }
        }
        
        
        
        
    }
    
    
}
