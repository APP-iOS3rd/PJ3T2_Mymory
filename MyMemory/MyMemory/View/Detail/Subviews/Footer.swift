//
//  Footer.swift
//  MyMemory
//
//  Created by 김성엽 on 1/19/24.
//

import SwiftUI

struct Footer: View {
    var body: some View {
        
        ZStack {
            Rectangle()
                .clipShape(.rect(cornerRadius: 15))
                .foregroundStyle(Color.black)
                .frame(height: 65)
                .padding(.horizontal, 20)
            
            HStack(spacing: 20) {
                Image(systemName: "photo.artframe")
                    .foregroundStyle(.white)
                
                VStack(alignment: .leading) {
                    Text("장소명")
                        .foregroundStyle(.white)
                        .font(.bold18)
                    
                    Text("#기쁨 #슬픔 # 분노")
                        .foregroundStyle(.white)
                        .font(.regular14)
                }
                
                
                Button {
                    
                } label: {
                    Text("해당 장소 메모보기")
                }
                .buttonStyle(Pill(backgroundColor: Color.white, titleColor: Color.darkGray, setFont: .bold16, paddingVertical:7))
            }
            
        }
        

    }
}

#Preview {
    Footer()
}
