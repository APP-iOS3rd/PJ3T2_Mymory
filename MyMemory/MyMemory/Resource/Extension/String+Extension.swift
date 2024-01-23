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
//MARK: - 한글 은는이가 자연스럽게 적용하기
extension String{
    func hasLastWordBatchimKR() -> Bool {
        guard let lastText = self.last else { return false}
        let unicodeVal = UnicodeScalar(String(lastText))?.value
        guard let value = unicodeVal else { return false }
        if (value < 0xAC00 || value > 0xD7A3) { return false }
        let last = (value - 0xAC00) % 28
        return last > 0
    }
    func addYi() -> String {
        let str = self.hasLastWordBatchimKR() ? "이" : ""
        return self + str
    }
    func addUl() -> String {
        let str = self.hasLastWordBatchimKR() ? "을" : "를"
        return self + str
    }
    func addUn() -> String {
        let str = self.hasLastWordBatchimKR() ? "은" : "는"
        return self + str
    }
}
extension Set<String> {
    var combinedWithComma: String {
        var reduced = self.reduce("") { $0 + ", " + $1}
        reduced.removeFirst()
        reduced.removeFirst()
        return reduced
    }
}

extension Double {
    func distanceToMeters() -> String{
        var str = String(format: "%.2f" , self) + "m"
        if self > 500{
            str = String(format: "%.2f" , self/1000) + "km"
        }
        return str
    }
}
