//
//  TopBarAddress.swift
//  MyMemory
//
//  Created by 김소혜 on 1/15/24.
//

import SwiftUI

struct TopBarAddress: View {
    
    // 추후 작업 때, binding으로 바꿔야함.
    @Binding var currentAddress: String?
    //@ObservedObject var MapviewModel: MainMapViewModel = .init()
    var body: some View {
        
        Button {
            //SearchView()
            //MapviewModel.fetchMemos()
        } label: {
            HStack {
                Text(currentAddress ?? "주소를 불러올 수 없습니다.")
                    .foregroundStyle(.black)
                Spacer()
                Image(systemName: "arrow.circlepath")
                    .foregroundColor(Color(UIColor.systemGray5))
            }
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(RoundedRect.large)
        .clipped()

 
       
    }
}

#Preview {
    TopBarAddress(currentAddress: .constant("wnth"))
}
