//
//  OnboardingView.swift
//  MyMemory
//
//  Created by 김소혜 on 1/16/24.
//

import SwiftUI

struct OnboardingView : View {
    
    @State var currentIndex: Int = 0
    @StateObject var viewModel: OnboardingViewModel = .init()
    @Binding var isFirstLaunching: Bool
        
    var body: some View {
        TabView(selection: $currentIndex.animation()) { // 1
            ForEach(Array(zip(viewModel.onboardingList.indices, viewModel.onboardingList)), id: \.0) { index, item in
                ZStack {
                    Color.white
                        .ignoresSafeArea()
                        
                    VStack(spacing: 15) {
                        Text(item.content)
                            .font(.bold20)
                            .multilineTextAlignment(.center)
                        
                        Image(item.image)
                            .resizable()
                            .frame(width: UIScreen.main.bounds.size.height * 0.4 ,height: UIScreen.main.bounds.size.height * 0.45)
                    }
                    //.padding(.top, 10)
                }
              .tag(index)
          }
        }
        .ignoresSafeArea()
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .overlay(IndexView(numberOfPages: viewModel.onboardingList, currentIndex: $currentIndex, isFirstLaunching: $isFirstLaunching))
      }
    }
 
 
//#Preview {
//    OnboardingView()
//}



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
            .padding(.top, 100)
            
            Spacer()
            
            ZStack {
                
                HStack {
                    if currentIndex == 3 {
                        Button {
                            isFirstLaunching.toggle()
                        } label: {
                            Text("시작하기")
                                .font(.medium18)
                                .frame(width: 200, height: 30)
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
                                .frame(width: 200, height: 30)
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
