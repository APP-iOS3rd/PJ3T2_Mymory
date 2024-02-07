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
            Onboarding(id:0,image: "홈", title: "메모", content:"메모를 저장해요",bgColor: .blue),
            Onboarding(id:1,image: "홈", title: "메모", content:"메모를 저장해요", bgColor: .green),
            Onboarding(id:2,image: "홈", title: "메모", content:"메모를 저장해요", bgColor: .blue)
        ]
    }
    
}
