//
//  Time+Extensions.swift
//  MyMemory
//
//  Created by 김태훈 on 2/1/24.
//

import Foundation
extension TimeInterval {
    var createdAtTimeYYMMDD: String {
        let date = Date(timeIntervalSince1970: self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY.MM.dd"
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }
    var toSimpleStr: String {
        let date = Date(timeIntervalSince1970: self)
        let current = Date().timeIntervalSince1970
        switch (current - self) {
            //1분 전
        case ..<60 :
            return "방금"
            //1시간 전
        case 60..<3600 :
            return "\(Int(current - self)/60)분 전"
        default:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM월dd일"
            let formattedDate = dateFormatter.string(from: date)
            return formattedDate
        }
    }
}
