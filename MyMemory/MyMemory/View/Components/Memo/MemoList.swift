//
//  MemoList.swift
//  MyMemory
//
//  Created by 이명섭 on 1/7/24.
//

import SwiftUI

struct MemoList: View {
    @Binding var memoList: [Memo]
    var body: some View {
        VStack(spacing: 12) {
            ForEach($memoList, id: \.self) { memo in
                NavigationLink {
                    
                } label: {
                    MemoListCell(
                        title: memo.title,
                        tags: memo.tags,
                        date: memo.date,
                        address: memo.address
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
