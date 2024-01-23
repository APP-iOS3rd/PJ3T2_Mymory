//
//  LoadingViewModel.swift
//  MyMemory
//
//  Created by 김태훈 on 1/22/24.
//

import Foundation
import SwiftUI
class LoadingManager : ObservableObject {
    static let shared = LoadingManager()
    @Published var phase: LoadingPhase = .initial
    func failed(msg: String) {
        phase = .fail(msg: msg)
    }
    func success() {
        phase = .success
    }
    func loading() {
        phase = .loading
    }
}
enum LoadingPhase: Equatable {
    case initial
    case loading
    case success
    case fail(msg: String)
}
