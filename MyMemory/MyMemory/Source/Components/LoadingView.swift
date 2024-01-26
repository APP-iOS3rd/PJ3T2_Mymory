//
//  LoadingView.swift
//  MyMemory
//
//  Created by 김소혜 on 1/21/24.
//

import SwiftUI

struct LoadingView: View {
    @State private var shouldAnimate = false
    
       var body: some View {
           ZStack {
               Color.black
                   .opacity(0.3)
               
               HStack {
                   Circle()
                       .fill(Color.accentColor)
                       .frame(width: 16, height: 16)
                       .scaleEffect(shouldAnimate ? 1.0 : 0.5)
                       .animation(Animation.easeInOut(duration: 0.5).repeatForever())
                   Circle()
                       .fill(Color.accentColor)
                       .frame(width: 16, height: 16)
                       .scaleEffect(shouldAnimate ? 1.0 : 0.5)
                       .animation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.3))
                   Circle()
                       .fill(Color.accentColor)
                       .frame(width: 16, height: 16)
                       .scaleEffect(shouldAnimate ? 1.0 : 0.5)
                       .animation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.6))
               }
               .padding()
               .frame(width: 100, height: 100)
               .background(Color.lightGray)
               .cornerRadius(20)
               .onAppear {
                   self.shouldAnimate = true
               }
           }.ignoresSafeArea()
       }
}

#Preview {
    LoadingView()
}
