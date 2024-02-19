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
                        .font(.regular12)
                        .foregroundStyle(Color.textGray)
                } else {
                    Text(memo.address)
                        .font(.bold16)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 13)
    }
}
