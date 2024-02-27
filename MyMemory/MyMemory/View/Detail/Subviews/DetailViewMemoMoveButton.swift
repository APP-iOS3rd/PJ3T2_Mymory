//
//  DetailViewMemoMoveButton.swift
//  MyMemory
//
//  Created by 이명섭 on 2/16/24.
//

import SwiftUI

struct DetailViewMemoMoveButton: View {
    @Binding var memos: [Memo]
    @Binding var selectedMemoIndex: Int?
    var body: some View {
        HStack {
            if selectedMemoIndex != memos.startIndex {
                HStack {
                    Image(systemName: "chevron.left")
                    
                    Text("이전 글")
                        .font(.regular16)
                }
                .foregroundStyle(Color.init(hex:"999494"))
                .onTapGesture {
                    if selectedMemoIndex != memos.startIndex {
                        preButton()
                    }
                }
                
            }
            Spacer()
            if selectedMemoIndex != memos.endIndex - 1 {
                HStack {
                    Text("다음 글")
                        .font(.regular16)
                    
                    Image(systemName: "chevron.right")
                }
                .foregroundStyle(Color.init(hex:"999494"))
                .onTapGesture {
                    if selectedMemoIndex != memos.endIndex - 1 {
                        nextButton()
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }
    
    func preButton() {
        if var value = selectedMemoIndex {
            value -= 1
            withAnimation(.default) {
                selectedMemoIndex = value
            }
        }
    }
    
    func nextButton() {
        if var value = selectedMemoIndex {
            value += 1
            withAnimation(.default) {
                selectedMemoIndex = value
            }
        }
    }
}
