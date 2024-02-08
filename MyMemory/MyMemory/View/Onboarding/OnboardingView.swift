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
//                    Color.lightGrayBackground
//                        .ignoresSafeArea()
                    
                    VStack(spacing:10){
                        Text(item.title)
                            .font(.bold20)
                        Text(item.content)
                            .font(.light14)
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
//    var body: some View {
//
//        TabView(selection: $currentIndex) {
//            ForEach(viewModel.onboardingList){ index in
//                
//                ZStack(alignment: .bottom){
//                    index.bgColor
//                        .ignoresSafeArea()
//                    Image(systemName: "square.and.arrow.up")
//                    //Image(systemName: index.image)
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 280, height: 280)
//                    .offset(y: -10)
//                    
//                    ZStack(alignment: .bottom) {
//                        
//                        Image(systemName: index.image)
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 280, height: 280)
//                            //.offset(y: 0)
//                        
//                        VStack(spacing:10){
//                            Text(index.title)
//                                .font(.bold20)
//                            Text(index.content)
//                                .font(.light14)
//                            Spacer()
//                            
//                            
//                            Button {
//                                if currentIndex == 2 {
//                                    isFirstLaunching.toggle()
//                                } else {
//                                    currentIndex = currentIndex + 1
//                                }
//                            } label: {
//                                if currentIndex == 2 {
//                                    Text("시작하기")
//                                } else {
//                                    Text("다음으로")
//                                }
//                            }
//                        }
//                        .padding(.horizontal,30)
//                        .padding(.vertical,70)
//                        .frame(maxWidth: .infinity)
//                        .frame(height: 260)
//                        .background(Color.white)
//                    }
//                }
//            }
//        }
//        .ignoresSafeArea()
//        .tabViewStyle(PageTabViewStyle())
//        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
 
 
//#Preview {
//    OnboardingView()
//}



struct IndexView: View {
  
  let numberOfPages: [Onboarding]
  @Binding var currentIndex: Int
    @Binding var isFirstLaunching: Bool
  
  private let circleSize: CGFloat = 16
  private let circleSpacing: CGFloat = 12
  
  private let primaryColor = Color.white
  private let secondaryColor = Color.white.opacity(0.6)
  
  private let smallScale: CGFloat = 0.6
  
  
  // MARK: - Body
    
    var body: some View {
            VStack {
                Spacer()
                ZStack {
                    
                    Color.lightGrayBackground
                        .ignoresSafeArea()
                        .frame(height: 70)
                    
                    HStack {
                        if currentIndex == 3 {
                            Button {
                                isFirstLaunching.toggle()
                            } label: {
                                Text("시작하기")
                            }
                            
                        } else {
                            Button {
                                isFirstLaunching.toggle()
                            } label: {
                                Text("SKIP")
                            }
                            
                            Spacer()
                            
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
                            Spacer()
                            Button {
                                if currentIndex != 3 {
                                    withAnimation {
                                        currentIndex = currentIndex + 1
                                    }
                                }
                            } label: {
                                Text("NEXT")
                            }
                        }
                            
                    }
                    .padding()
                }
        }
    }
  
  
  // MARK: - Private Methods
    
  func shouldShowIndex(_ index: Int) -> Bool {
    ((currentIndex - 1)...(currentIndex + 1)).contains(index)
  }
}
