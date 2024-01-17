//
//  ProgressView.swift
//  MyMemory
//
//  Created by 김성엽 on 1/16/24.
//

import SwiftUI

struct ProgressBarView: View {
    @State private var progress = 0.0
    @State private var userDistance: Int = 50
    
    
    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .foregroundStyle(.gray)
                .clipShape(.rect(cornerRadius: 15))
                .frame(height: 180)
            
            VStack(alignment: .leading) {
                ProgressView(value: Double(userDistance), total: 100)
                    .progressViewStyle(RoundedRectProgressViewStyle())
                
                if userDistance < 5 {
                    Text("인증 장소에 도착했어요!")
                        .foregroundStyle(.white)
                } else {
                    Text("인증 장소까지 \(userDistance)m")
                        .foregroundStyle(.white)
                }
//                Button(action: {
//                    progress += 10
//                }, label: {
//                    /*@START_MENU_TOKEN@*/Text("Button")/*@END_MENU_TOKEN@*/
//                })
            }
            .padding(.top, 8)

        }
    }
}


struct RoundedRectProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
    
        VStack(alignment: .leading) {
            GIFView(type: .name("run4"))
                .frame(width: 70, height: 70)
                .offset(x: CGFloat(configuration.fractionCompleted ?? 0) * 300)
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 14)
                    .frame(width: 350, height: 10)
                    .foregroundColor(.gray)
                    .overlay(Color.black.opacity(0.5)).cornerRadius(14)
                
                RoundedRectangle(cornerRadius: 14)
                    .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * 350, height: 10)
                    .foregroundColor(.pink)
            }
            
        }
    }
}






#Preview {
    ProgressView()
}
