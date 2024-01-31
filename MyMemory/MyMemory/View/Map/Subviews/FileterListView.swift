//
//  FileterListView.swift
//  MyMemory
//
//  Created by 김태훈 on 1/18/24.
//

import SwiftUI

struct FileterListView: View {
    let data = ["데이트","맛집","핫플레이스","스타","이벤트","속닥속닥","게임","유머","패션뷰티","예술작품","그래피티","교육","사진","나만알고싶은곳","사진찍기좋은곳","인생샷"]
    @Binding var filteredList: Set<String>
    var body: some View {
        Rectangle()
            .frame(width: 40,height: 5)
            .foregroundColor(Color.bgColor)
            .cornerRadius(3)
            .padding(.vertical, 10)
        Text("어떤 주제를 선택해볼래?")
                .font(.bold20)
                .padding(.top, 30)
        if !self.filteredList.isEmpty {
            HStack {
                Spacer()
                Button(action: {self.filteredList = Set<String>()},
                       label: {Text("초기화 하기")
                        .font(.regular14)
                        .foregroundStyle(Color.gray)
                })
            }
        }
        ScrollView {
            VStack {
                Spacer().frame(height: 20)
                GeometryReader { GeometryProxy in
                    FlexibleView(availableWidth: GeometryProxy.size.width,
                                 data: data,
                                 spacing: 15,
                                 alignment: .center) { item in
                        Button(action: {
                            if filteredList.contains(item) {
                                filteredList.remove(item)
                            } else {
                                filteredList.insert(item)
                            }
                        }, label: {
                            Text("#\(item)")
                        }).buttonStyle(
                            filteredList.contains(item) ?                     
                            Pill.selected : Pill.lightGray
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .aspectRatio(contentMode: .fit)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

#Preview {
    FileterListView(filteredList: .constant([]))
}
