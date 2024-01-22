//
//  PostViewFooter.swift
//  MyMemory
//
//  Created by 정정욱 on 1/22/24.
//

import SwiftUI

struct PostViewFooter: View {
    @Binding var memoAddressText: String
    
    var body: some View {
        
        ZStack {
            Rectangle()
                .clipShape(.rect(cornerRadius: 15))
                .foregroundStyle(Color.black)
                .frame(height: 65)
                .padding(.horizontal, 20)
            
            HStack(spacing: 20) {
                
                VStack(alignment: .leading) {
                    Text(memoAddressText)
                        .foregroundStyle(.white)
                        .font(.bold14)
                        .lineLimit(1)
                        .truncationMode(.tail) // 끝 부분 생략(...) 추가
                    
                    Text("현재 위치를 기준으로 자동으로 탐색합니다.")
                        .font(.caption)
                        .foregroundColor(Color(.systemGray3))
                    
                }
                .padding(.leading)
                
                Button {
                    
                } label: {
                    Text("위치 재설정")
                }
                .buttonStyle(Pill(backgroundColor: Color.white, titleColor: Color.darkGray, setFont: .bold16, paddingVertical:7))
                .padding(.trailing)
            }
            
        }

    }
}

//#Preview {
//    PostViewFooter(memoAddressText: <#Binding<String>#>)
//}
