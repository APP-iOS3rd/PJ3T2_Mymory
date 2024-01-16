//
//  ClusterSelectionView.swift
//  MyMemory
//
//  Created by 김태훈 on 1/16/24.
//

import Foundation
import SwiftUI
struct ClusterSelectionView: View {
    @EnvironmentObject var viewModel: MainMapViewModel
    let contents: MemoCluster
    var body: some View {
        VStack {

            ScrollView(.horizontal) {
                HStack{
                    ForEach(contents.memos) { item in
                        VStack {
                            HStack {
                                Text("\(item.title)")
                                    .lineLimit(1)
                                    .font(.bold20)
                                Spacer()
                                Text("\(item.createdAt.createdAtTimeYYMMDD)")
                                    .font(.regular12)
                                    .foregroundStyle(Color.gray)
                            }
                            .padding([.leading, .trailing], 14)
                            Text(item.contents)
                                .lineLimit(3)
                                .font(.regular14)
                                .frame(maxWidth: .infinity)
                                .padding([.leading,.trailing], 14)
                                .padding(.bottom, 20)
                                .padding(.top, 10)
                        
                        }.frame(width: 300)
                        .padding(.top, 10)
                        .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                            .cornerRadius(15)
                            .padding(10)
                            
                    }
                }
            }
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity)
        .background(Color.clear)
        .clipShape(RoundedCornersShape(radius: 20,corners: [.topLeft,.topRight]))
    }
}
