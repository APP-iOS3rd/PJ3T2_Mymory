//
//  MiniMap.swift
//  MyMemory
//
//  Created by 김성엽 on 1/16/24.
//

import SwiftUI
import KakaoMapsSDK
import CoreLocation

struct MiniMap: View {
    
    @Binding var memo: Memo
    @Binding var draw: Bool
    @Binding var userLocation: CLLocation?
    @Binding var userDirection: Double
    
    var body: some View {
  
            VStack(alignment: .leading) {
                
                HStack {
                    Image(systemName: "photo.fill")
                        .padding()
                        .frame(width: 40, height: 40)
                        .background(.white)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text("\(memo.title)")
                            .font(.bold18)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 3) {
                            // 태그 선택할때 마다 표시
                            ForEach(memo.tags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .fixedSize(horizontal: true, vertical: false)
                
                CertificationMap(memo: $memo, draw: $draw, userLocation: $userLocation, userDirection: $userDirection)
                    .onAppear {
                        self.draw = true
                    }
                    .onDisappear{
                        self.draw = false
                    }
                    //.environmentObject(viewModel)
                    .clipShape(.rect(cornerRadius: 15))
                    //.frame(maxHeight: .infinity) 
                    .frame(height: 390)
                    .offset(y: 10)
                
            }
            .background(
                Rectangle()
                    .foregroundStyle(Color.deepGray)
                    .clipShape(.rect(cornerRadius: 15))
            )
        
        .padding()
    }
}
