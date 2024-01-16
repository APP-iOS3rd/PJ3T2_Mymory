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
    let contents: [MiniMemoModel]
    @Binding var selectedItemID: UUID
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                ScrollViewReader{ proxy in
                    
                    HStack{
                        ForEach(contents) { item in
                            VStack {
                                HStack {
                                    Image(uiImage: UIImage(systemName: "car")!)
                                        .resizable()
                                        .frame(width: 72, height: 72)
                                    
                                        .padding([.top, .leading], 20)
                                    
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
                                
                            }
                            .frame(width: 310, height: 150)
                            .padding(.top, 10)
                            .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                            .cornerRadius(15)
                            .padding(10)
                            .id(item.id)
                            .onTapGesture{
                                print(item.id)
                            }
                            .onAppear {
                                // 스크롤을 가장 오른쪽으로 이동시킵니다.
                                proxy.scrollTo(contents.last?.id, anchor: .trailing)
                            }
                            .onChange(of: selectedItemID) { id in
                                // 선택된 아이템이 있을 경우 해당 셀을 화면 중앙으로 스크롤합니다.
                                if let item = contents.first(where: { $0.id == id }) {
                                    proxy.scrollTo(item.id, anchor: .center)
                                }
                            }
                            
                        }
                    }
                }
            }
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity)
        .background(Color.clear)
    }
}
