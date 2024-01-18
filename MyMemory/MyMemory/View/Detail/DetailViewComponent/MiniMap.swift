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
  
            VStack(alignment: .leading) {
                
                HStack {
                    Image(systemName: "photo.fill")
                        .padding()
                        .frame(width: 40, height: 40)
                        .background(.white)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text("CGV 홍대")
                            .font(.bold18)
                            .foregroundColor(.white)
                           
                        Text("#영화관 #핫플레이스")
                            .font(.regular14)
                            .foregroundColor(.accentColor)
                            
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .fixedSize(horizontal: true, vertical: false)
                
                Map()
                    .clipShape(.rect(cornerRadius: 15))
                    .frame(maxHeight: .infinity)
                
                CurrentSpotButton()
                    .position(y:0)
                
            }
            .background(
                Rectangle()
                    .foregroundStyle(Color.deepGray)
                    .clipShape(.rect(cornerRadius: 15))
            )
        
        .padding()
    }
}

//#Preview {
//    if #available(iOS 17.0, *) {
//        MiniMap()
//    } else {
//        // Fallback on earlier versions
//    }
//}
