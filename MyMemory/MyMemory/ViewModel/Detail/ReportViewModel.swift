//
//  ReportViewModel.swift
//  MyMemory
//
//  Created by 이명섭 on 2/6/24.
//

import Foundation

class ReportViewModel: ObservableObject {
    let memoService = MemoService.shared
    
    func fetchReport(memo: Memo, type: String, reason: String) async -> String? {
        let result = await memoService.fetchReportMemo(memo: memo,
                                                       type: type,
                                                       reason: reason)
        
        switch result {
        case .success:
            return nil
        case .failure(let failure):
            var errorMessage: String
            switch failure {
            case .firebaseError :
                errorMessage = "서버에러가 발생하였습니다. 잠시 후 다시 시도해주세요."
            case .invalidMemo:
                errorMessage = "메모가 유효하지 않습니다. 다시 시도해주세요."
            case .isNotLogin:
                errorMessage = "로그인 중이 아닙니다. 로그인 후 시도해주세요."
            case .duplicatedReport:
                errorMessage = "이전에 신고한 메모입니다. 2회 이상 신고할 수 없습니다."
            }
            return errorMessage
        }
    }
}
