//
//  ImgDetailView.swift
//  MyMemory
//
//  Created by 김성엽 on 1/16/24.
//
import SwiftUI

struct ImgDetailView: View {
    @Binding var isShownFullScreenCover: Bool
    @Binding var selectedImage: Int
    var images: [Data]
    
    var body: some View {
        
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(alignment: .trailing) {
                Button {
                    isShownFullScreenCover.toggle()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(Color.accentColor)
                        .font(.largeTitle)
                }
                .padding(.top, 50)
                
                TabView(selection: $selectedImage) {
                    ForEach(images.indices, id: \.self) { index in
                        if let uiimage = UIImage(data: images[index]) {
                            Image(uiImage: uiimage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(.bottom, 50)
                        }
                    }
                    
                }
                .tabViewStyle(.page)
            }
        }
    }
}
