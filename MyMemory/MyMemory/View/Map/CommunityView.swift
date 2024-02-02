//
//  CommunityView.swift
//  MyMemory
//
//  Created by 이명섭 on 2/1/24.
//

import SwiftUI

struct CommunityView: View {
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
                ScrollView(.horizontal){
                    LazyHStack(spacing: 20, content: {
                        ForEach(1...10, id: \.self) { count in
                            MemoCell(location: $locationManager.location)
                        }
                    })
                }.padding(.top, 25)
                
                HStack {
                    Text("반응이 많은\n메모")
                        .font(.bold24)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }.padding(.horizontal, 25)
                    .padding(.top, 60)
                LazyVStack(content: {
                    ForEach(1...10, id: \.self) { count in
                        HStack{
                            VStack {
                                Text("호그와트 마법학교")
                                    .font(.bold16)
                                    .foregroundStyle(Color.textColor)
                                    .padding(.bottom,5)
                                Text("서울시 마포구 대흥동")
                                    .font(.regular12)
                                    .foregroundStyle(Color.textColor)
                            }.padding(.horizontal, 15)
                            Spacer()
                            Button{
                                
                            } label: {
                                Image(systemName: "ellipsis")
                            }.padding(.horizontal, 15)
                        }
                        .padding(13)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke()
                                .foregroundStyle(Color(hex: "#E9E9E9"))
                        )
                    }
                })
            }
        }
    }
}

#Preview {
    CommunityView()
}
