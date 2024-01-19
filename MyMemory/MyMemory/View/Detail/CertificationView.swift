//
//  CertificationView.swift
//  MyMemory
//
//  Created by 김성엽 on 1/16/24.
//

import SwiftUI

@available(iOS 17.0, *)
struct CertificationView: View {
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
                 
                MiniMap()
               
                Spacer()
                
                ProgressBarView()
                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity)

                
            }
            .edgesIgnoringSafeArea(.bottom)
            
        }
    }
}
    
@available(iOS 17.0, *)
#Preview {
    CertificationView()
}
