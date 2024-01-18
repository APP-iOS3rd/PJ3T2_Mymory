//
//  MemoList.swift
//  MyMemory
//
//  Created by 이명섭 on 1/7/24.
//

import SwiftUI

struct MemoList: View {
    var memoList: [Memo]
    var body: some View {
        VStack(spacing: 12) {
            ForEach(memoList, id: \.self) { memo in
                MemoListCell(
                    title: memo.title,
                    tags: memo.tags,
                    date: memo.date.createdAtTimeYYMMDD,
                    address: memo.address
                )
            }
        }
    }
}

struct MemoListCell: View {
    var title: String
    var tags: [String]
    var date: String
    var address: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.bold14)
                if !tags.isEmpty {
                    HStack {
                        ForEach(tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.semibold11)
                        }
                    }
                }
                HStack {
                    Text(date)
                        .padding(.trailing, 4)
                        .font(.regular11)
                    Text("﹒\(address)")
                        .font(.regular11)
                }
            }
            
            Spacer()
        }
        .padding(EdgeInsets(top: 12, leading: 18, bottom:12, trailing: 18))
        .background(Color(UIColor.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}
