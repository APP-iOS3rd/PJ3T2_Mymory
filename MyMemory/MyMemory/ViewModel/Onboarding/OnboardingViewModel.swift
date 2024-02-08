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
            Onboarding(id:0,image: "person.3.fill", title: "메모", content:"잊혀지지 않는 추억, 지금 이곳에서 기록하세요",bgColor: .blue),
            // 페이지 2: 쓰기 페이지 안내
            Onboarding(id:1,image: "note.text.badge.plus", title: "메모 작성", content:"사진, 메모, 감정까지, 당신의 추억을 자유롭게 담아보세요", bgColor: .green),
            // 페이지 3: 내 메모 읽기 기능 안내
            Onboarding(id:2,image: "eyes", title: "메모", content:"지금 이곳에서 떠오르는 추억, 생생하게 되살려 보세요", bgColor: .blue),
            // 페이지 4: 커뮤니티 페이지 안내 + 온보딩 완료
            Onboarding(id:3,image: "eyes", title: "메모", content:"가까운 곳에서 다른 사람들의 추억을 찾아보세요.", bgColor: .red)
        ]
    }
    
}

