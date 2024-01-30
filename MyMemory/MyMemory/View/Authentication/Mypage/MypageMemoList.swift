//
//  MemoList.swift
//  MyMemory
//
//  Created by 이명섭 on 1/7/24.
//

import SwiftUI

struct MypageMemoList: View {
    @EnvironmentObject var viewModel: MypageViewModel
    var body: some View {
        VStack(spacing: 12) {
            ForEach($viewModel.memoList, id: \.self) { memo in
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

