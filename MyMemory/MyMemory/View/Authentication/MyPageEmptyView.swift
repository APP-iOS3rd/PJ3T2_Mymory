//
//  MyPageEmptyView.swift
//  MyMemory
//
//  Created by 김태훈 on 2/5/24.
//

import SwiftUI
struct MyPageEmptyView: View {
    @Binding var selectedIndex: Int
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                    .padding(.top, 44)
                Image(.empty)
                Text("작성된 메모가 없어요!")
                    .font(.appFont(for: .ExtraBold, size: 22))
                    .padding(.top, geometry.size.height * 0.1) // 상단 여백을 화면 높이의 10%로 설정
                Text("새로운 메모를 작성해 보세요")
                    .font(.medium14)
                    .padding(.top, 5)

                Button{
                    self.selectedIndex = 1
                } label: {
                    Text("작성하기")
                        .padding(.horizontal, 40)
                }.buttonStyle(RoundedRect.primary)
                    .padding(.top, geometry.size.height * 0.05) // 상단 여백을 화면 높이의 5%로 설정
            }
            .frame(width: geometry.size.width) // 너비를 화면 크기에 맞게 설정
        }
    }
}

#Preview {
    MyPageEmptyView(selectedIndex: .constant(2))
}
