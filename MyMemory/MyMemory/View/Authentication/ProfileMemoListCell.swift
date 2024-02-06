//
//  MemoListCell.swift
//  MyMemory
//
//  Created by 이명섭 on 1/15/24.
//

import SwiftUI

struct ProfileMemoListCell<ViewModel: ProfileViewModelProtocol>: View {
    
    @Binding var memo: Memo
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        HStack {
            HStack(alignment: .top, spacing: 10){
                Circle()
                    .frame(width: 42, height: 42)
                    .foregroundStyle(Color(hex: "F5F5F5"))
                    .overlay(alignment: .center) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(Color(hex: "EF8E8E"))
                    }
                
                VStack(alignment: .leading, spacing: 3) {
                    if !memo.tags.isEmpty {
                        HStack(spacing: 2) {
                            ForEach(memo.tags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.regular12)
                                    .foregroundStyle(Color.textColor)
                            }
                        }
                    }
                    Text(memo.title)
                        .font(.bold16)
                        .foregroundStyle(Color.textColor)
                    
                    Text("해당 장소 메모보기")
                        .padding(EdgeInsets(top: 6, leading: 13, bottom: 6, trailing: 13))
                        .background(Color.bgColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(Color.textColor)
                        .font(.extraBold12)
                    
                    HStack(spacing: 2) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 11))
                        Text("\(memo.likeCount)개")
                            .font(.regular12)
                        Text("|")
                            .font(.semibold11)
                        Image(systemName: "location.fill")
                            .font(.system(size: 11))
                        if let location = viewModel.currentLocation {
                            Text("\(memo.location.distance(from: location).distanceToMeters())")
                                .font(.regular12)
                        } else {
                            Text("-")
                                .font(.regular12)
                        }
                    }
                    .foregroundStyle(Color(hex: "898A8D"))
                    .padding(.top, 27)
                }
            }
            
            Spacer()
        }
        .padding(EdgeInsets(top: 12, leading: 18, bottom:12, trailing: 18))
        .background(Color.cardColor)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.borderColor)
        )
    }
}
