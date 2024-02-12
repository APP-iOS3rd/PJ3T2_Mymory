//
//  HowToUseViewModel.swift
//  MyMemory
//
//  Created by 김소혜 on 1/16/24.
//

import Foundation
import Combine

final class OnboardingViewModel: ObservableObject{
    
    @Published var onboardingList: [Onboarding] = []
    init() {
        fetchModel()
    }
}

extension OnboardingViewModel {
    public func fetchModel(){
        self.onboardingList = [
            // 페이지 1: 앱 소개
            Onboarding(id:0,image: "onboarding0", title: "앱 핵심 기능 전달", content:"잊혀지지 않는 추억, \n 지금 이곳에서 기록하세요"),
            // 페이지 2: 쓰기 페이지 안내
            Onboarding(id:1,image: "onboarding1-1", title: "앱 주요 기능 설명 1", content:"사진, 메모, 감정까지 \n 당신의 추억을 자유롭게 담아보세요"),
            // 페이지 3: 내 메모 읽기 기능 안내
            Onboarding(id:2,image: "onboarding3", title: "앱 주요 기능 설명 3", content:"떠오르는 추억을 \n 어디서나 생생하게 되살려 보세요"),
            Onboarding(id:3,image: "onboarding2", title: "앱 주요 기능 설명 2", content:"지금 이곳에서의 추억을 \n 다른 사람들과 함께 공유해 보세요")
            
        ]
    }
   
}

