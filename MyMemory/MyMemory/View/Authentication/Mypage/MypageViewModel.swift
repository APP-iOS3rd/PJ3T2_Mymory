//
//  MyPageViewModel.swift
//  MyMemory
//
//  Created by 이명섭 on 1/4/24.
//

import Foundation
import CoreLocation

// 임시
struct Memo: Hashable, Codable {
    var id = UUID()
    // 제목
    var title: String
    // 메모 내용
    var description: String
    // 주소
    var address: String
    // 태그
    var tags: [String]?
    // 사진
    var images: [String]
    // 공개여부
    var isPublic: Bool
    // 작성일
    var date: String
    // 위치
    var location: Location
}

struct Location: Hashable, Codable {
    var latitude: Double
    var longitude: Double
}

class MemoManager: ObservableObject {
    static let shared = MemoManager()
    
    @Published var memoList: [Memo] = []
    @Published var memoListInRange: [Memo] = []
    
    init() {
        self.memoList = [
            Memo(title: "ggg", description: "gggg", address: "서울시 @@구 @@동", tags: ["ggg", "Ggggg"], images: [], isPublic: false, date: "2023.10.23", location: Location(latitude: 0.0, longitude: 0.0)),
            Memo(title: "ggg", description: "gggg", address: "서울시 @@구 @@동", tags: ["ggg", "Ggggg"], images: [], isPublic: false, date: "2023.10.23", location: Location(latitude: 0.0, longitude: 0.0)),
            Memo(title: "ggg", description: "gggg", address: "서울시 @@구 @@동", tags: ["ggg", "Ggggg"], images: [], isPublic: false, date: "2023.10.23", location: Location(latitude: 0.0, longitude: 0.0)),
            Memo(title: "ggg", description: "gggg", address: "서울시 @@구 @@동", tags: ["ggg", "Ggggg"], images: [], isPublic: false, date: "2023.10.23", location: Location(latitude: 0.0, longitude: 0.0)),
            Memo(title: "ggg", description: "gggg", address: "서울시 @@구 @@동", tags: ["ggg", "Ggggg"], images: [], isPublic: false, date: "2023.10.23", location: Location(latitude: 0.0, longitude: 0.0)),
        ]
    }
    
    // MARK: 현재 사용의 위치(위도, 경도)와 메모의 위치, 그리고 설정할 거리를 통해 설정된 거리 내 메모를 필터링하는 함수(CLLocation의 distance 메서드 사용)
    func fetchMemoInRange(myLat lat: Double, myLon lon: Double, distance: Double) {
        // 사용자의 위치를 CLLocation객체로 생성
        let myLocation = CLLocation(latitude: lat, longitude: lon)
        self.memoListInRange = self.memoList.filter { memo in
            let memoLat = memo.location.latitude
            let memoLon = memo.location.longitude
            let memoLocation = CLLocation(latitude: memoLat, longitude: memoLon)
            return myLocation.distance(from: memoLocation) <= distance ? true : false
        }
    }
}
