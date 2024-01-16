//
//  MiniMap.swift
//  MyMemory
//
//  Created by 김성엽 on 1/16/24.
//

import SwiftUI
import MapKit

@available(iOS 17.0, *)
struct MiniMap: View {
    
    var body: some View {
        ZStack {

            Rectangle()
                    .foregroundStyle(.gray)
                    .clipShape(.rect(cornerRadius: 15))
                    .frame(height: 250)
                    .offset(y: -50)
            
            VStack(alignment: .leading) {
                
                HStack {
                    Image(systemName: "photo.circle.fill")
                        .foregroundStyle(.white)
                    VStack(alignment: .leading) {
                        Text("CGV 홍대")
                        Text("#영화관 #핫플레이스")
                            .font(.footnote)
                    }
                    .padding()
                    
                }
                .padding(.horizontal, 30)
                .offset(y: 25)
                
                Map()
                    .clipShape(.rect(cornerRadius: 15))
                    .frame(height: 350)
                    .offset(y: 10)
                
            }
        }//:ZSTACK
        .padding(.horizontal, 20)
    }
}




