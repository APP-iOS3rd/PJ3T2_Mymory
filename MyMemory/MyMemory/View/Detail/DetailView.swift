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
    
    var body: some View {
        if isVisble {
            MemoDetailView(memo: $memo)
        } else {
            CertificationView(memo: $memo)
        }
    }
}
