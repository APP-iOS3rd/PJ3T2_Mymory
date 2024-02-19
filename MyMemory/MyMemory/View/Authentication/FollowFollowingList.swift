//
//  FollowFollowingList.swift
//  MyMemory
//
//  Created by 정정욱 on 2/19/24.
//

import SwiftUI
import Kingfisher

struct FollowFollowingList: View {
    
    @ObservedObject var followerFollowingViewModel : FollowerFollowingViewModel
    @StateObject var otherUserViewModel: OtherUserViewModel = OtherUserViewModel()
    
    @Environment(\.presentationMode) var presentationMode
    @State private var goingUserProfile = false
    @Binding var uid: String
    /*
     @ObservedObject var viewModel: DetailViewModel
     
     var body: some View {
     
     HStack {
     NavigationLink {
     OtherUserProfileView(memoCreator: viewModel.memoCreator ?? User(email: "", name: ""))
     //                    .customNavigationBar(
     //                        centerView: {
     //                            Text(viewModel.memoCreator?.name ?? "")
     //                        },
     //                        leftView: {
     //                            BackButton()
     //                        },
     //                        rightView: {
     //                            EmptyView()
     //                        },
     //                        backgroundColor: Color.bgColor3
     //                    )
     .environmentObject(otherUserViewModel)
     */
    var body: some View {
        
            List {
                ForEach(followerFollowingViewModel.followingUserList.indices, id: \.self) { index in
                    let user = followerFollowingViewModel.followingUserList[index]
                    NavigationLink {
                        OtherUserProfileView(memoCreator:user)
                            .navigationBarHidden(true)
                            .environmentObject(otherUserViewModel)
                    } label: {
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
                                .foregroundColor(.black)
                                .padding(.vertical)
                        }
                    }

                }
                //.onDelete(perform: delete)
                .onMove(perform: move)
            
        }
      
//                .onAppear(perform: {
//            Task { @MainActor in
//                
//                
//                await AuthService.shared.fetchFollowingUserList(with: uid)
//                await AuthService.shared.fetchFollowerUserList(with: uid)
//            }
//        })
        
//        .toolbar {
//            ToolbarItem(placement: .principal) {
//                Text("팔로잉")
//            }
//            ToolbarItem(placement: .navigationBarLeading) {
//                
//                Button(action: {
//                    presentationMode.wrappedValue.dismiss()
//                }) {
//                    HStack {
//                        Image(systemName: "chevron.backward")
//                        Text("뒤로")
//                    }
//                }
//                
//                
//            }
//            
//            
//        }
        
    }
       
    func move(indices: IndexSet, newOffset: Int) {
        followerFollowingViewModel.followingUserList.move(fromOffsets: indices, toOffset: newOffset)
    }
    
}
//    mutating func delete(indexSet: IndexSet) {
//        authViewModel.followingUserList.remove(atOffsets: indexSet)
//    }



//#Preview {
//    FollowFollowingList()
//}
