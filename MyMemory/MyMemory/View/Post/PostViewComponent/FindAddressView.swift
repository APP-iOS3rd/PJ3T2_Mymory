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
            //PostViewFooter(memoAddressText: $memoAddressText)

        }//: VSTACK
    }
}

#Preview {
    // 예시로 초기화하는 부분
    FindAddressView(memoAddressText: .constant("Your Initial Address"))

}
