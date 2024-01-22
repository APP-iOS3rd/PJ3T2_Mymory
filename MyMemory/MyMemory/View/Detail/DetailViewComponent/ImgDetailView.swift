//
//  ImgDetailView.swift
//  MyMemory
//
//  Created by 김성엽 on 1/16/24.
//

import SwiftUI

struct ImgDetailView: View {
    @Binding var isShownFullScreenCover: Bool
    @Binding var imagUrl:String
    @Binding var images: [String]
    
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
                
                TabView(selection: $imagUrl) {
                    ForEach(images, id: \.self) { img in
                        AsyncImage(url: URL(string: img)) { phase in
                            switch phase {
                            case .success(let image):
                                image.imageModifier()
                            case .failure(_):
                                VStack {
                                    Image(systemName: "xmark.circle.fill").iconModifier()
                                    Text("오류로 이미지를 불러오지 못했습니다")
                                        .foregroundStyle(.white)
                                }
                            case .empty:
                                Image(systemName: "photo.circle.fill").iconModifier()
                            @unknown default:
                                ProgressView()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 600)
                        .padding(.bottom, 50)
                    }
                    
                }
                .tabViewStyle(.page)
                
                
                
                //                    Rectangle()
                //                        .foregroundStyle(.white)
                //                        .frame(maxWidth: .infinity)
                //                        .frame(height: 600)
                //                        .padding(.bottom, 50)
                
            }
        }
    }
}

//#Preview {
//    ImgDetailView()
//}


extension Image {
    func imageModifier() -> some View {
        self
            .resizable()
            .scaledToFit()
    }
    
    func iconModifier() -> some View {
        self
            .imageModifier()
            .frame(maxWidth: 128)
            .foregroundColor(.purple)
            .opacity(0.5)
    }
}
