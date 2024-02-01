//
//  CertificationView.swift
//  MyMemory
//
//  Created by 김성엽 on 1/16/24.
//

import SwiftUI

struct CertificationView: View {
    
    @Binding var memo: Memo
    @StateObject private var viewModel: CertificationViewModel = .init()
    
    var body: some View {
        
        ZStack {
            
            Color.black
                .foregroundStyle(.black)
                .ignoresSafeArea()
            
            
            VStack {
                VStack {
                    VStack {
                        Text("장소 근처")
                            .font(.bold24)
                        +
                        Text("에서")
                            .font(.regular24)
                        
                        Text("메모를 확인할 수 있어요!")
                            .font(.regular24)
                    }
                    .frame(alignment: .center)
                    .foregroundStyle(.white)
                    .padding(.top, 20)
                }
                
                if let _ = viewModel.userCoordinate {
                    
                    ScrollView {
                        MiniMap(memo: $memo, draw: $viewModel.draw, userLocation: $viewModel.userCoordinate, userDirection: $viewModel.direction)
                    }
                    
                    
                    ProgressBarView(memo: $memo, userLocation: $viewModel.userCoordinate)
                        .ignoresSafeArea()
                } else {
                    ProgressView()
                }
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}
