//
//  String+Extensions.swift
//  MyMemory
//
//  Created by 이명섭 on 1/16/24.
//

import Foundation

extension String {
    // MARK: "yyyy-MM-dd" 형식을 Date 형식으로 변환 (추후 Memo Model이 정해지면 시간까지 추가해야할듯..?)
    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            return nil
        }
    }
}
