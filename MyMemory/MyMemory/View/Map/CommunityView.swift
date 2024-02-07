//
//  CommunityView.swift
//  MyMemory
//
//  Created by 이명섭 on 2/1/24.
//

import SwiftUI

struct CommunityView: View {
    @State var memo: Memo = Memo(userUid: "123", title: "ggg", description: "gggg", address: "서울시 @@구 @@동", tags: ["ggg", "Ggggg"], images: [], isPublic: false, date: Date().timeIntervalSince1970 - 1300, location: Location(latitude: 0, longitude: 0), likeCount: 10, memoImageUUIDs: [""])
    @State var memos: [Memo] = [Memo(userUid: "123", title: "ggg", description: "gggg", address: "서울시 @@구 @@동", tags: ["ggg", "Ggggg"], images: [], isPublic: false, date: Date().timeIntervalSince1970 - 1300, location: Location(latitude: 0, longitude: 0), likeCount: 10, memoImageUUIDs: [""])]
    
    @StateObject var locationManager = LocationsHandler.shared
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("반응이 많은\n메모")
                        .font(.bold24)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }.padding(.horizontal, 25)
                    .padding(.top, 25)
                ScrollView(.horizontal){
                    LazyHStack(spacing: 0, content: {
                        ForEach(1...10, id: \.self) { count in
                            MemoCell(location: $locationManager.location,memo: $memo, memos: $memos)
                                .padding(.leading, 18)
                        }
                    })
                }.padding(.top, 25)

                HStack {
                    Text("이번 주\n가장 핫한 지역")
                        .font(.bold24)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }.padding(.horizontal, 25)
                    .padding(.top, 60)
                    .padding(.bottom, 25)
                LazyVStack(spacing: 15, content: {
                    ForEach(1...10, id: \.self) { count in
                        HStack{
                            VStack(alignment: .leading) {
                                Text("호그와트 마법학교")
                                    .font(.bold16)
                                    .foregroundStyle(Color.textColor)
                                    .padding(.bottom,5)
                                Text("서울시 마포구 대흥동")
                                    .font(.regular12)
                                    .foregroundStyle(Color.textColor)
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 15)

                            Spacer()
                            Button{

                            } label: {
                                Image(systemName: "ellipsis")
                            }
                            .padding(.horizontal, 15)
                        }

                        .background(Color.cardColor)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.borderColor)
                        )

                    }
                }).padding(.horizontal, 25)
            }
        }
    }
}
