//
//  IndexView.swift
//  MyMemory
//
//  Created by 김성엽 on 2/12/24.
//

import SwiftUI

struct IndexView: View {
    
    let numberOfPages: [Onboarding]
    @Binding var currentIndex: Int
    @Binding var isFirstLaunching: Bool
    
    private let circleSize: CGFloat = 12
    private let circleSpacing: CGFloat = 12
    
    private let primaryColor = Color.primary
    private let secondaryColor = Color.lightGray
    
    private let smallScale: CGFloat = 0.8
    
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            HStack(spacing: circleSpacing) {
                ForEach(numberOfPages.indices, id: \.self) { index in
                    if shouldShowIndex(index) {
                        Circle()
                            .fill(currentIndex == index ? primaryColor : secondaryColor)
                            .scaleEffect(currentIndex == index ? 1 : smallScale)
                        
                            .frame(width: circleSize, height: circleSize)
                            .transition(AnyTransition.opacity.combined(with: .scale))
                            .id(index)
                    }
                }
            }
            .padding(.top, 90)
            
            Spacer()
            
            ZStack {
                
                HStack {
                    if currentIndex == 3 {
                        Button {
                            isFirstLaunching.toggle()
                        } label: {
                            Text("시작하기")
                                .font(.medium18)
                                .frame(width: 180, height: 30)
                        }
                        .buttonStyle(Pill.standard)
                        
                    } else {
                        Button {
                            if currentIndex != 3 {
                                withAnimation {
                                    currentIndex = currentIndex + 1
                                }
                            }
                        } label: {
                            Text("다음")
                                .font(.medium18)
                                .frame(width: 180, height: 30)
                        }
                        .buttonStyle(Pill.standard)
                    }
                    
                }
                .padding(.bottom, 30)
            }
        }
    }
    
    func shouldShowIndex(_ index: Int) -> Bool {
        ((currentIndex - 3)...(currentIndex + 3)).contains(index)
    }
}
