//
//  ImgDetailView.swift
//  MyMemory
//
//  Created by 김성엽 on 1/16/24.
//
import SwiftUI
import Kingfisher

struct ImgDetailView: View {
    @Binding var selectedImage: Int {
        didSet {
            self.scale = 1.0
        }
    }
    @State private var scale: CGFloat = 1.0
    @Environment(\.dismiss) var dismiss
    var magnification: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                // 제스처가 변경될 때마다 상태 업데이트
                scale = value.magnification
            }
            .onEnded { _ in
                // 제스처가 끝날 때 아무 작업도 하지 않음
            }
    }
    @GestureState private var translation: CGSize = .zero
    private var swipe: some Gesture {
        DragGesture()
            .updating($translation) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                let swipeDistance = value.translation.height
                //오른쪽
                if swipeDistance > (UIScreen.main.bounds.height)/10.0 {
                    dismiss()
                    //왼쪽
                }
            }
    }
    
    var images: [String]
    var body: some View {
        
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(alignment: .trailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(Color.accentColor)
                        .font(.largeTitle)
                }
                .padding(.top, 50)
                
                TabView(selection: $selectedImage) {
                    ForEach(images.indices, id: \.self) { index in
                            KFImage(URL(string: images[index]))
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(.bottom, 50)
                                .scaleEffect(scale)
                                .gesture(magnification)
                    }
                    
                }
                .tabViewStyle(.page)
                .gesture(swipe)
            }
        }.gesture(swipe)
    }
}
