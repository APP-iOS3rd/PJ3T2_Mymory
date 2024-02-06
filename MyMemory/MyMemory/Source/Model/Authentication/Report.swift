//
//  Report.swift
//  MyMemory
//
//  Created by 김소혜 on 1/4/24.
//

import Foundation
import SwiftUI

enum ReportError: Error {
    case invalidMemo
    case isNotLogin
    case firebaseError
    case duplicatedReport
}

enum ReportMessage: String, Identifiable, CaseIterable{
    case first = "사회/정치적으로 부적절한 메시지가 있어요"
    case second = "욕설/혐오발언을 사용했어요"
    case third = "기타 신고사항"
    
    var id: Self { self }
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

