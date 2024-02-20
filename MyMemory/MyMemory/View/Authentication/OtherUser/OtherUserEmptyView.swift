//
//  OtherUserEmptyView.swift
//  MyMemory
//
//  Created by 이명섭 on 2/19/24.
//

import SwiftUI

struct OtherUserEmptyView: View {
    var userName: String
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Image(.empty)
                Text("\(userName)님이 작성한 메모가 없어요!")
                    .font(.appFont(for: .ExtraBold, size: 22))
                    .padding(.top, geometry.size.height * 0.1) // 상단 여백을 화면 높이의 10%로 설정
            }
            .frame(width: geometry.size.width) // 너비를 화면 크기에 맞게 설정
        }
    }
}
