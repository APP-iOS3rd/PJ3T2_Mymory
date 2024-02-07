//
//  DetailView.swift
//  MyMemory
//
//  Created by 김성엽 on 1/23/24.
//

import SwiftUI

struct DetailView: View {
    @Binding var memo: Memo
    @Binding var isVisble: Bool
    @Binding var memos: [Memo]
    @State var selectedMemoIndex = 0
    @State var isMyMemo: Bool = false
    
    var body: some View {
        if isVisble || isMyMemo {
            MemoDetailView(memo: $memo, memos: memos, selectedMemoIndex: selectedMemoIndex)
        } else {
            CertificationView(memo: $memo)
        }
    }
}
