//
//  CommunityViewModel.swift
//  MyMemory
//
//  Created by 김태훈 on 2/13/24.
//

import Foundation
import Combine

final class CommunityViewModel: ObservableObject {
    
    @Published var memosOfTheWeek:[Memo] = []
    init() {
        Task{ @MainActor in
            do {
                self.memosOfTheWeek = try await MemoService.shared.fetchMemosOfWeek()
            }
        }
    }
}
