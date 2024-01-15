//
//  MemoListCell.swift
//  MyMemory
//
//  Created by 이명섭 on 1/15/24.
//

import SwiftUI

struct MemoListCell: View {
    @Binding var title: String
    @Binding var tags: [String]?
    @Binding var date: String
    @Binding var address: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.bold14)
                if let tags = tags, !tags.isEmpty {
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
