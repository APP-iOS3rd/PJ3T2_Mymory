//
//  ProgressBar.swift
//  MyMemory
//
//  Created by 김성엽 on 1/16/24.
//

import SwiftUI

struct ProgressBar: View {
    @State private var progress = 0.0
    
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.gray)
                .clipShape(.rect(cornerRadius: 15))
                .frame(height: 160)
            
            VStack(alignment: .leading) {
                ProgressView(value: progress, total: 100)
                    .progressViewStyle(RoundedRectProgressViewStyle())
                
                Button(action: {
                    progress += 10
                }, label: {
                    Text("Button")
                })
            }

        }
    }
}


struct RoundedRectProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        
        VStack(alignment: .leading) {
            GIFView(type: .name("run"))
                .frame(width: 30, height: 30)
                .offset(x: CGFloat(configuration.fractionCompleted ?? 0) * 330)
            
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
    ProgressBar()
}
