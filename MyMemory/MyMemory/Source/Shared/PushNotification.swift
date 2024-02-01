//
//  PushNotification.swift
//  MyMemory
//
//  Created by 김태훈 on 2/1/24.
//

import Foundation
import SwiftUI
/// Push notification을 관리하는 일종의 delegate 느낌으로 만든 단일 싱글톤입니다.

final class PushNotification: ObservableObject {
    static let shared = PushNotification()
    @Published var memo: Memo? = nil
}
