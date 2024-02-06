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
        VStack {
            Image(.empty)
            Text("작성된 메모가 없어요!")
                .font(.appFont(for: .ExtraBold, size: 22))
                .padding(.top, 50)
            Text("새로운 메모를 작성해 보세요")
                .font(.medium14)
                .padding(.top, 5)

            Button{
                self.selectedIndex = 1
            } label: {
                Text("작성하기")
                    .padding(.horizontal, 40)
            }.buttonStyle(RoundedRect.primary)
                .padding(.top, 25)

        }
    }
}

#Preview {
    MyPageEmptyView(selectedIndex: .constant(2))
}
