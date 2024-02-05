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
    
    var body: some View {
     
        HStack {

            NavigationLink {
                MypageView(fromDetail: true, memoCreator: viewModel.memoCreator ?? User(email: "", name: ""))
                    .customNavigationBar(
                        centerView: {
                            Text(viewModel.memoCreator?.name ?? "")
                        },
                        leftView: {
                            BackButton()
                        },
                        rightView: {
                            EmptyView()
                        },
                        backgroundColor: Color.bgColor3
                    )
            } label: {
                if let imageUrl = viewModel.memoCreator?.profilePicture, let url = URL(string: imageUrl) {
                    KFImage(url)
                        .resizable()
                        .scaledToFill()
                        .foregroundStyle(.white)
                        .clipped()
                        .clipShape(.circle)
                        .frame(width: 60, height: 60)
                } else {
                    Circle()
                        .frame(width: 60, height: 60)
                        .foregroundStyle(Color.darkGray)
                }
                
                VStack(alignment: .leading) {
                    Text(viewModel.memoCreator?.name ?? "")
                        .foregroundStyle(Color.textColor)
                        .font(.semibold16)
                    Text("@ididid")
                        .foregroundStyle(Color.textGray)
                        .font(.regular14)
                }
                .padding(.leading, 20)
            }
            Spacer()
            
            Button {
                
                
            } label: {
                Text("팔로우")
//                Image(systemName: "ellipsis")
//                    .foregroundColor(Color.textColor)
            }

            
        }
        .padding()
        .border(width: 1, edges: [.top], color: Color.bgColor)
        
    }
}

