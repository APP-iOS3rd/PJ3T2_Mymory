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
        ZStack {
            HStack {

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
                    ProfileView(fromDetail: true, memoCreator: viewModel.memoCreator ?? User(email: "", name: ""))
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

