//
//  DetailView.swift
//  MyMemory
//
//  Created by 김성엽 on 1/23/24.
//

import SwiftUI
import CoreLocation

struct DetailView: View {
    @Binding var memo: Memo
    @Binding var isVisble: Bool
    @Binding var location: CLLocation?
    @Binding var memos: [Memo]
    @Binding var selectedMemoIndex: Int
    
    var body: some View {
        if isVisble {
            MemoDetailView(memo: $memo, memos: memos, location: $location, selectedMemoIndex: selectedMemoIndex)
        } else {
            CertificationView(memo: $memo)
        }
    }
}
