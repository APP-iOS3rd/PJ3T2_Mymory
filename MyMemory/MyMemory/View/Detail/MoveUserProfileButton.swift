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
            Rectangle()
                .clipShape(.rect(cornerRadius: 15))
                .foregroundStyle(Color.black)
                .frame(height: 65)
                .padding(.horizontal, 20)
            
            HStack(spacing: 20) {

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
                        .foregroundStyle(Color(hex: "d9d9d9"))
                }
                
                
                VStack(alignment: .leading) {
                    Text(viewModel.memoCreator?.name ?? "")
                        .foregroundStyle(.white)
                        .font(.bold18)
                    
                }
                
                NavigationLink {
                    MypageView(fromDetail: true, memoCreator: viewModel.memoCreator ?? User(email: "", name: ""))
                    
                } label: {
                    Text("작성자 프로필 이동")
                }
                .buttonStyle(Pill(backgroundColor: Color.white, titleColor: Color.darkGray, setFont: .bold16, paddingVertical:7))
                
                
            }
            
        }
        
    }
}



