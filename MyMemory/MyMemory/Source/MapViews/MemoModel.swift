//
//  MemoModel.swift
//  MyMemory
//
//  Created by 김태훈 on 1/7/24.
//

import Foundation
import MapKit
struct MiniMemoModel: Identifiable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
    let title: String
    let contents: String
    let images: [UIImage]
    let createdAt: TimeInterval
}

struct MemoCluster: Equatable, Identifiable {
    static func == (lhs: MemoCluster, rhs: MemoCluster) -> Bool {
        lhs.center == rhs.center
    }
    var id: UUID
    var memos: [MiniMemoModel]
    var center: CLLocationCoordinate2D
    init(memo: MiniMemoModel) {
        self.id = UUID()
        self.center = memo.coordinate
        self.memos = [memo]
    }
    mutating func updateCenter(with other: MemoCluster) {
        self.memos.append(contentsOf: other.memos)
        updateCenter()
    }
    mutating func updateCenter() {
        let memoLocationSum = memos.reduce(CLLocationCoordinate2D(latitude: 0, longitude: 0)){CLLocationCoordinate2D(latitude: $0.latitude + $1.coordinate.latitude, longitude: $0.longitude + $1.coordinate.longitude)}
        let count = memos.count
        center = CLLocationCoordinate2D(latitude: memoLocationSum.latitude / Double(count), longitude: memoLocationSum.longitude / Double(count))
    }
}
extension TimeInterval {
    var createdAtTimeYYMMDD: String {
        let date = Date(timeIntervalSince1970: self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY.MM.dd"
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }
}
