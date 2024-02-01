//
//  FindAddressView.swift
//  MyMemory
//
//  Created by 정정욱 on 1/11/24.
//

import SwiftUI

struct FindAddressView: View {
    @Binding var memoAddressText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10){
            HStack(alignment: .lastTextBaseline, spacing: 10) {
                Text("메모 작성 위치 ")
                    .font(.bold20)
                    .bold()
                
                Text("현재 위치를 기준으로 자동으로 탐색합니다.")
                    .font(.caption)
                    .foregroundColor(Color(.systemGray3))
            }//:HSTACK
            
            TextField(memoAddressText, text: $memoAddressText)
                .textFieldStyle(.roundedBorder)
                .disabled(true) // TextField를 선택할 수 없도록 비활성화
        }//: VSTACK
    }
}

#Preview {
    // 예시로 초기화하는 부분
    FindAddressView(memoAddressText: .constant("Your Initial Address"))

}
