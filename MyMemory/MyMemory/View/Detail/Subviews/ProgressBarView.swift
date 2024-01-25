//
//  ProgressView.swift
//  MyMemory
//
//  Created by 김성엽 on 1/16/24.
//

import SwiftUI
import CoreLocation

struct ProgressBarView: View {
    
    @Binding var memo: Memo
    @Binding var userLocation: CLLocation?
    @EnvironmentObject var viewModel: CertificationViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .foregroundStyle(Color.deepGray)
                .clipShape(.rect(cornerRadius: 15))
                .frame(height: 140)
            
            VStack(alignment: .leading) {
                if let distance = userLocation?.coordinate.distance(from: memo.location) {
                    ProgressView(value: 1000 - distance, total: 1000)
                        .progressViewStyle(RoundedRectProgressViewStyle())
                    if distance < 10 {
                        Text("인증 장소에 도착했어요!")
                            .font(.regular16)
                            .foregroundStyle(.white)
                    } else {
                        Text("인증 장소까지 \(Int(distance))m")
                            .font(.regular16)
                            .foregroundStyle(.white)
                    }
                }
            }
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
