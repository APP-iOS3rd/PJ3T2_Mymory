//
//  ReportMemoView.swift
//  MyMemory
//
//  Created by 김태훈 on 1/23/24.
//

import SwiftUI

struct ReportMemoView: View {
    var memo: Memo
    @State var label = ""

    var body: some View {
        VStack(alignment: .leading) {
            
            Text(label)
                .font(.bold14)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            
            ZStack{
                Color(UIColor.systemGray6)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(12)
                VStack(alignment:.leading) {
                    HStack(alignment:.bottom) {
                        Text(memo.title)
                            .font(.bold20)
                        Spacer()
                        Text(memo.date.createdAtTimeYYMMDD)
                            .font(.regular12)
                    }.padding(14)
                    Text(memo.description)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .font(.regular16)
                        .padding(.horizontal,14)
                        .padding(.bottom,14)

                }
            }
            .frame(maxWidth: .infinity, maxHeight: 120)
        }
        .padding()
    }
    
}
