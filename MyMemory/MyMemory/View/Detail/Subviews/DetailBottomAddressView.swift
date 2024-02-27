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
                        .font(.bold16)
                        .padding(.bottom, 5)
                    
                    Text(memo.address)
                        .font(.medium12)
                        .foregroundStyle(Color.textGray)
                } else {
                    
                    Text(lastStr)
                        .font(.bold16)
                    
                        .padding(.bottom, 5)
                    Text(memo.address)
                        .font(.medium12)
                        .foregroundStyle(Color.textGray)
                }
            }
            .frame(height: 40)
            
            Spacer()
        }
        .padding(.horizontal,24)
        .padding(.top, 16)
        .padding(.bottom, 24)
        .border(width: 1, edges: [.top], color: .borderColor)
        .frame(maxWidth: .infinity)
        .ignoresSafeArea()
    }
    
    
    var lastStr: String{
        
        // 공백으로 문자열 분할
        let components = self.memo.address.components(separatedBy: " ")
        
        if components.count >= 2 {
            let secondLastComponent = components[components.count - 2]
            return secondLastComponent
        } else {
            return ""
        }
    
        
       
    }
    
     
}
