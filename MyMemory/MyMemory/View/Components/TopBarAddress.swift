//
//  TopBarAddress.swift
//  MyMemory
//
//  Created by 김소혜 on 1/15/24.
//

import SwiftUI

struct TopBarAddress: View {
    
    // 추후 작업 때, binding으로 바꿔야함.
    @State var currentAddress: String = "서울특별시 마포구 서교동 364-2"
    
    var body: some View {
        
        NavigationLink {
            SearchView()
        } label: {
            HStack {
                Text(currentAddress)
                    .foregroundStyle(.black)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(UIColor.systemGray5))
            }
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(RoundedRect.large)
        .clipped()

 
       
    }
}

#Preview {
    TopBarAddress()
}
