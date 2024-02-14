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
                
                Spacer()
                NavigationLink {
                    OtherUserProfileView( memoCreator: viewModel.memoCreator ?? User(email: "", name: ""))
                        .environmentObject(otherUserViewModel)
                } label: {
                    Image(systemName: "ellipsis")
//                    Text("작성자 프로필 이동")
                }
             //   .buttonStyle(Pill(backgroundColor: Color.white, titleColor: Color.darkGray, setFont: .bold16, paddingVertical:7))
                
                
            }
            .padding()
            .border(width: 1, edges: [.top], color: Color.bgColor)
            
        }
        
    }
}

