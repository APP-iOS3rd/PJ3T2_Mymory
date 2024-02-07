//
//  MemoModel.swift
//  MyMemory
//
//  Created by 김태훈 on 1/7/24.
//

import Foundation
import MapKit

struct MemoCluster: Equatable, Identifiable {
    static func == (lhs: MemoCluster, rhs: MemoCluster) -> Bool {
        lhs.center == rhs.center
    }
    var id: UUID
    var memos: [Memo]
    var center: CLLocationCoordinate2D
    init(memo: Memo) {
        self.id = UUID()
        self.center = CLLocationCoordinate2D(latitude: memo.location.latitude, longitude: memo.location.longitude)
        self.memos = [memo]
    }
    init(memoList: [Memo]) {
        self.id = UUID()
        self.memos = memoList
        let memoLocationSum = memos.reduce(CLLocationCoordinate2D(latitude: 0, longitude: 0)){CLLocationCoordinate2D(latitude: $0.latitude + $1.location.latitude, longitude: $0.longitude + $1.location.longitude)}
        let count = memos.count
        self.center = CLLocationCoordinate2D(latitude: memoLocationSum.latitude / Double(count), longitude: memoLocationSum.longitude / Double(count))
    }
    func isNearBy(threshold : Double = 500) {
        LocationsHandler.shared.getCurrentLocation(completion: { location2d in
            let location = CLLocation(latitude: location2d?.latitude ?? 0, longitude: location2d?.longitude ?? 0)
            let centerloc = CLLocation(latitude: center.latitude, longitude: center.longitude)
            let dist = location.distance(from: centerloc)
        })
    }
    mutating func updateCenter(with other: MemoCluster) {
        self.memos.append(contentsOf: other.memos)
        updateCenter()
    }
    mutating func updateCenter() {
        let memoLocationSum = memos.reduce(CLLocationCoordinate2D(latitude: 0, longitude: 0)){CLLocationCoordinate2D(latitude: $0.latitude + $1.location.latitude, longitude: $0.longitude + $1.location.longitude)}
        let count = memos.count
        center = CLLocationCoordinate2D(latitude: memoLocationSum.latitude / Double(count), longitude: memoLocationSum.longitude / Double(count))
    }
}
