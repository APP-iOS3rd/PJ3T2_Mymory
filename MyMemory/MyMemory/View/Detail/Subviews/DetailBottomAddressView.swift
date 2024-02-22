//
//  DetailBottomAddressView.swift
//  MyMemory
//
//  Created by 이명섭 on 2/16/24.
//

import SwiftUI

struct DetailBottomAddressView: View {
    @EnvironmentObject var viewModel: DetailViewModel
    var memo: Memo
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                if let buildingName = memo.building, !buildingName.isEmpty {
                    Text(buildingName)
                        .font(.userMainTextFont(baseSize: 16))
                        .padding(.bottom, 5)
                    
                    Text(memo.address)
                        .font(.userMainTextFont(baseSize: 12))
                        .foregroundStyle(Color.textGray)
                } else {
                    
                    Text(lastStr)
                        .font(.userMainTextFont(baseSize: 16))
                    
                    Text(memo.address)
                        .font(.userMainTextFont(baseSize: 12))
                        .foregroundStyle(Color.textGray)
                }
            }
            
            Spacer()
        }
        .padding()
        .border(Color.lightGray, width: 1) // 테마에 따라 border컬러 변경예정
        .frame(maxWidth: .infinity)
        .padding(.vertical, 13)
    }
    
    
    var lastStr: String{
        
        // 공백으로 문자열 분할
        let components = self.memo.address.components(separatedBy: " ")
        // 마지막 요소 접근
        if let lastComponent = components.last {
            return lastComponent
        } else {
            return ""
        }
        
       
    }
    
     
}
