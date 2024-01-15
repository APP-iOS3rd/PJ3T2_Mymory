//
//  SelectTagView.swift
//  MyMemory
//
//  Created by 정정욱 on 1/11/24.
//

import SwiftUI

struct SelectTagView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10){
            HStack(alignment: .lastTextBaseline, spacing: 200){
                Text("#어떤타입?")
                .font(.title3)
                .bold()
                
                Button {
                    // Action
                    
                } label: {
                    Text("추가하기")
                    .foregroundStyle(Color(.blue))
                    .font(.subheadline)
                }
            }
          
            Rectangle()
                .frame(width: UIScreen.main.bounds.size.width * 0.90, height:40)
                .cornerRadius(10)
                .foregroundStyle(Color.gray.opacity(0.17))
        }
    }
}

#Preview {
    SelectTagView()
}
