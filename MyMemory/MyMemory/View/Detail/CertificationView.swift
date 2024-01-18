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
                    Text("장소 근처")
                        .foregroundStyle(.white)
                       .font(.bold24)
                      +
                     Text("에서")
                        .foregroundStyle(.white)
                       .font(.regular24)
                     Text("메모를 확인할 수 있어요!")
                        .foregroundStyle(.white)
                        .font(.regular24)
                }
                .padding(.top, 20)
                
                ScrollView {

                    MiniMap()
                }
                
                VStack {
                    ProgressBarView()
                        .offset(CGSize(width: 0.0, height: 35.0))
                        .frame(maxWidth: .infinity)
                        //.padding(.vertical)
                }
                
            }
            .frame(alignment: .bottom)
            

            
            
        }
    }
}
    
@available(iOS 17.0, *)
#Preview {
    CertificationView()
}
