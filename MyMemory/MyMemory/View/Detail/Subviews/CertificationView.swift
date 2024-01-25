//
//  CertificationView.swift
//  MyMemory
//
//  Created by 김성엽 on 1/16/24.
//

import SwiftUI

struct CertificationView: View {
    
    @Binding var memo: Memo
    @State var draw:Bool = true
    @StateObject private var viewModel: CertificationViewModel = CertificationViewModel()
    
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
                
                Spacer()
                    
                CertificationMap(memo: $memo, draw: $viewModel.draw, isUserTracking: $viewModel.isUserTracking, userLocation: $viewModel.location, userDirection: $viewModel.direction)
                        .onAppear {
                            DispatchQueue.main.async {
                                self.draw = true
                            }
                        }
                        .onDisappear {
                            self.draw = false
                        }
                        .environmentObject(viewModel)
                        .clipShape(.rect(cornerRadius: 10))
                        .frame(height: UIScreen.main.bounds.size.height * 0.55)
                    
                    Spacer()
                    
                    ProgressBarView(memo: $memo, userLocation: $viewModel.location)
                        .environmentObject(viewModel)
                        .ignoresSafeArea()
                    
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}
