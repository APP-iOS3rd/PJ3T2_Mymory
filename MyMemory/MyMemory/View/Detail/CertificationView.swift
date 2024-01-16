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
                    
                
               ScrollView {
                   
                   LazyVStack {
                
                    VStack {
                        Text("장소 근처에서")
                            .frame(alignment: .center)
                            .foregroundStyle(.white)
                            .font(.title3)
                        
                        Text("메모를 확인할 수 있어요!")
                            .frame(alignment: .center)
                            .foregroundStyle(.white)
                            .font(.title3)
                    }
                    .padding(.top, 50)
                    .fixedSize(horizontal: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    
                    
                        MiniMap()
                           // .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                        
                    Spacer()
                        
//
//                    Rectangle()
//                        .foregroundStyle(.gray)
//                        .ignoresSafeArea()
//                        .frame(minHeight: 100)
                }//:VSTACK
                ProgressBar()
                       .offset(CGSize(width: 0.0, height: 100.0))

           }
            .frame(maxHeight: .infinity)
            //.ignoresSafeArea()
            
        }//:ZSTACK
    }
}

//#Preview {
//    CertificationView()
//}
