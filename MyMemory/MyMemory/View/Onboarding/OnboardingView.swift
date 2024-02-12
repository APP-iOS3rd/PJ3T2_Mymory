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
