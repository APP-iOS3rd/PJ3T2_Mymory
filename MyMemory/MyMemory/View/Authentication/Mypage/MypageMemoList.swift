//
//  MemoList.swift
//  MyMemory
//
//  Created by 이명섭 on 1/7/24.
//

import SwiftUI
// MypageMemoList 수정
struct MypageMemoList<ViewModel: MemoListViewModel>: View {
    @EnvironmentObject var viewModel: ViewModel
    @State private var isLoadingFetchMemos = false
    
    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach($viewModel.MemoList, id: \.self) { memo in
                NavigationLink {
                    MemoDetailView(memo: memo)
                } label: {
                    MypageMemoListCell(memo: memo, viewModel: viewModel)
                        .onAppear {
                            Task {
                                // 1. 로그인 되어있는지 체크
                                // 2. 뷰모델에 따라 알맞은 로직을 실행
                                if let userId = UserDefaults.standard.string(forKey: "userId") {
                                    if let mypageViewModel = viewModel as? MypageViewModel {                                        
                                        self.isLoadingFetchMemos = true
                                        await mypageViewModel.pagenate(userID: userId)
                                        self.isLoadingFetchMemos = false
                                    } else if let otherUserViewModel = viewModel as? OtherUserViewModel {
                                        self.isLoadingFetchMemos = true
                                        let userId = otherUserViewModel.memoCreator.id?.description
                                        await otherUserViewModel.pagenate(userID: userId ?? "")
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
