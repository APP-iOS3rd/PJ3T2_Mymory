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
                    Color.bgColor
                        .ignoresSafeArea()
                        
                    VStack(spacing: 30) {
                        Text(item.content)
                            .font(.bold20)
                            .foregroundStyle(Color.textColor)
                            .multilineTextAlignment(.center)
                        
                            Image(item.image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: UIScreen.main.bounds.size.width * 0.85, maxHeight: UIScreen.main.bounds.size.height * 0.5)


                    }
                }
              .tag(index)
          }
        }
        .ignoresSafeArea()
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .overlay(IndexView(numberOfPages: viewModel.onboardingList, currentIndex: $currentIndex, isFirstLaunching: $isFirstLaunching))
      }
    }
