//
//  MemoCell.swift
//  MyMemory
//
//  Created by 정정욱 on 1/10/24.
//

import SwiftUI

struct MemoCell: View {
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height

    
    var body: some View{
        VStack(alignment: .leading, spacing: 10){
            Text("서울특빌시 00구 00동")
                .font(.caption)
                .foregroundStyle(Color(.systemGray2))
                .padding(.leading,30)
            ZStack {
                // Content
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
                    .frame(width: screenWidth * 0.9, height: screenHeight * 0.12)
                VStack(spacing: 10){
                    HStack(alignment: .lastTextBaseline, spacing: 10) {
                        Text("메모 제목")
                            .font(.title3)
                            .bold()
                        Spacer()
                        Text("2024.01.10")
                            .font(.caption)
                            .foregroundStyle(Color(.systemGray2))
                    } //:HSTACK
                    
                    Text("메모내용메모내용메모내용메모내용메모내용메모내용메모내용내용메모내용메모내용메모메모내용")
                        .lineLimit(2)
                        .font(.caption)
                } //:VSTACK
                .padding(.horizontal,40)
                
            } //:ZSTACK
         
        }
       
        
       
    }
}


#if DEBUG
@available(iOS 17.0, *)
struct MemoCell_Previews: PreviewProvider {
    static var previews: some View {
        MemoCell()
    }
}
#endif


