//
//  MemoList.swift
//  MyMemory
//
//  Created by 이명섭 on 1/7/24.
//

import SwiftUI

struct MypageMemoList: View {
    @EnvironmentObject var viewModel: MypageViewModel
    @Binding var memoList: [Memo]
    var body: some View {
        VStack(spacing: 12) {
            ForEach($memoList, id: \.self) { memo in
                NavigationLink {
                    
                    MemoDetailView(memo: memo)
                    
                } label: {
                    MypageMemoListCell(
                        memo: memo
                    )
                  
                }
                .buttonStyle(.plain)
            }
        }
    }
}

