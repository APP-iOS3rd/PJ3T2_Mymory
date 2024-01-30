//
//  MemoList.swift
//  MyMemory
//
//  Created by 이명섭 on 1/7/24.
//

import SwiftUI

struct MypageMemoList: View {
    @EnvironmentObject var viewModel: MypageViewModel
    @State private var isLoadingFetchMemos = false
    
    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach($viewModel.memoList, id: \.self) { memo in
                NavigationLink {
                    MemoDetailView(memo: memo)
                    
                } label: {
                    MypageMemoListCell(
                        memo: memo
                    )
                    .onAppear {
                        if memo.id == self.viewModel.memoList.last?.id {
                            Task {
                                if let userId = UserDefaults.standard.string(forKey: "userId") {
                                    self.isLoadingFetchMemos = true
                                    await self.viewModel.pagenate(userID: userId)
                                    self.isLoadingFetchMemos = false
                                }
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        
        if isLoadingFetchMemos {
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            .padding(.vertical, 16)
        }
    }
}

