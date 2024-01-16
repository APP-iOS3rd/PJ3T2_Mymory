//
//  SearchCell.swift
//  MyMemory
//
//  Created by 김소혜 on 1/16/24.
//

import SwiftUI

struct SearchCell: View {

    var name: String
    var address: String
   
    var body: some View {
        VStack (alignment: .leading){
            Text(name)
                .foregroundStyle(Color.black)
                .font(.bold16)
            Text(address)
                .foregroundStyle(Color.darkGray)
                .font(.light14)
        }
        .padding(.vertical, 12)
    
    }
}

#Preview {
    SearchCell(name: "사당", address: "서울시 동작구 사당동")
 
}
