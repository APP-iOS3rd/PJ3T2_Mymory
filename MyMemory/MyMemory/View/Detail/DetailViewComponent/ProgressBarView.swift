//
//  ProgressView.swift
//  MyMemory
//
//  Created by 김성엽 on 1/16/24.
//

import SwiftUI
import CoreLocation

struct ProgressBarView: View {
    @State private var progress = 0.0
    @State private var userDistance: Int = 50
    
    @StateObject var viewModel: CertificationViewModel = CertificationViewModel()
    private var marker: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 37.5125, longitude: 127.102778)
    
    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .foregroundStyle(.gray)
                .clipShape(.rect(cornerRadius: 15))
                .frame(height: 180)
            
            VStack(alignment: .leading) {
                
                if let distance = viewModel.userCoordinate?.distance(from: marker) {
                    
                    ProgressView(value: distance, total: 300000)
                        .progressViewStyle(RoundedRectProgressViewStyle())
                    
                    if userDistance < 5 {
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
