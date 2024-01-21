//
//  FileterListView.swift
//  MyMemory
//
//  Created by 김태훈 on 1/18/24.
//

import SwiftUI

struct FileterListView: View {
    let data = ["슬픔","기쁨","화남","ㅁㅁㅁ","ㅈㅈㅈㅈ","ㅊㅊㅊㅊㅊ","ㅁㅋㅋㄴ","슬픔2","기쁨2","화남2","ㅁㅁㅁ2","ㅈㅈㅈㅈ2","ㅊㅊㅊㅊㅊ2","ㅁㅋㅋㄴ2"]
    @Binding var filteredList: Set<String>
    var body: some View {
        Rectangle()
            .frame(width: 40,height: 5)
            .foregroundStyle(Color.init(hex: "B5B5B5"))
            .cornerRadius(3)
            .padding(.vertical, 10)
        Text("어떤 주제를 선택해볼래?")
            .font(.bold20)
            .padding(.top, 30)
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
                            filteredList.contains(item) ?                     Pill.selected : Pill.lightGray
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .aspectRatio(contentMode: .fit)
                    }.frame(maxWidth: .infinity)
                }
            }
        }
    }
}

#Preview {
    FileterListView(filteredList: .constant([]))
}
