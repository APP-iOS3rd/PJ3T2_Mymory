//
//  FindAddressView.swift
//  MyMemory
//
//  Created by 정정욱 on 1/11/24.
//

import SwiftUI

struct FindAddressView: View {
    @State var addressText: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10){
            HStack(alignment: .lastTextBaseline, spacing: 10) {
                Text("주소 찾기")
                    .font(.title3)
                    .bold()
                
                Text("현재 위치를 기준으로 자동으로 탐색합니다.")
                    .font(.caption)
                    .foregroundColor(Color(.systemGray3))
            }//:HSTACK
            
            TextField("서울특별시 00구 00동", text: $addressText)
                .textFieldStyle(.roundedBorder)
            
        }//: VSTACK
    }
}

#Preview {
    FindAddressView()
}
