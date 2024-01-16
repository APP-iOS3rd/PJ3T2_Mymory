//
//  ImgDetailView.swift
//  MyMemory
//
//  Created by 김성엽 on 1/16/24.
//

import SwiftUI

struct ImgDetailView: View {
    @Binding var isShownFullScreenCover: Bool
    
    var body: some View {
        
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(alignment: .trailing) {
                    Button {
                        isShownFullScreenCover.toggle()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.white)
                            .font(.largeTitle)
                    }
                    .padding(.top, 50)
                    
                    Rectangle()
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 600)
                        .padding(.bottom, 50)
                    
                }
        }
    }
}

//#Preview {
//    ImgDetailView()
//}
