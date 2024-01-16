//
//  MyPageViewModel.swift
//  MyMemory
//
//  Created by 이명섭 on 1/4/24.
//

import Foundation
import CoreLocation

enum SortedTypeOfMemo: String, CaseIterable, Identifiable {
    case last = "최신순"
    case like = "좋아요순"
    case close = "가까운순"
    
    var id: Self { self }
}

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
    // 좋아요
    var like: Int
}

struct Location: Hashable, Codable {
    var latitude: Double
    var longitude: Double
}

class MypageViewModel: ObservableObject {
    static let shared = MypageViewModel()
    
    @Published var memoList: [Memo] = []
    @Published var selectedFilter = SortedTypeOfMemo.last
    @Published var isShowingOptions = false
    
    init() {
        self.memoList = [
            Memo(title: "덕수궁", description: "gggg", address: "서울시 @@구 @@동", tags: ["ggg", "Ggggg"], images: [], isPublic: false, date: "2023.10.23", location: Location(latitude: 37.5658049, longitude: 126.9751461), like: 1),
            Memo(title: "서울광장", description: "gggg", address: "서울시 @@구 @@동", tags: ["ggg", "Ggggg"], images: [], isPublic: false, date: "2023.10.20", location: Location(latitude: 37.5655675, longitude: 126.978014), like: 5),
            Memo(title: "롯백", description: "gggg", address: "서울시 @@구 @@동", tags: ["ggg", "Ggggg"], images: [], isPublic: false, date: "2023.10.19", location: Location(latitude: 37.5647073, longitude: 126.9816637), like: 8),
            Memo(title: "서울역", description: "gggg", address: "서울시 @@구 @@동", tags: ["ggg", "Ggggg"], images: [], isPublic: false, date: "2023.10.21", location: Location(latitude: 37.555946, longitude: 126.972317), like: 9),
            Memo(title: "2023.10.24", description: "gggg", address: "서울시 @@구 @@동", tags: ["ggg", "Ggggg"], images: [], isPublic: false, date: "2023.10.24", location: Location(latitude: 0.0, longitude: 0.0), like: 10),
            Memo(title: "2023.10.24", description: "gggg", address: "서울시 @@구 @@동", tags: ["ggg", "Ggggg"], images: [], isPublic: false, date: "2023.10.24", location: Location(latitude: 0.0, longitude: 0.0), like: 0),
        ]
    }
    
    // MARK: 현재 사용의 위치(위도, 경도)와 메모의 위치, 그리고 설정할 거리를 통해 설정된 거리 내 메모를 필터링하는 함수(CLLocation의 distance 메서드 사용)
    func fetchDistanceOfUserAndMemo(myLocation: CLLocationCoordinate2D, memoLocation: Location ) -> Double {
        // 사용자의 위치를 CLLocation객체로 생성
        let location = CLLocationCoordinate2D(latitude: memoLocation.latitude, longitude: memoLocation.longitude)
        return location.distance(to: myLocation)
    }
    // MARK: MemoList 필터링 & 정렬하는 메서드입니다
    func sortMemoList(type: SortedTypeOfMemo) {
        self.selectedFilter = type
        switch type {
        case .last:
            self.memoList = memoList.sorted {
                if let first = $0.date.toDate(), let second = $1.date.toDate() {
                    // 시간비교 orderedAscending: first가 second보다 이전(빠른), orderedDescending: first가 second보다 이후(늦은)
                    switch first.compare(second) {
                    case .orderedAscending: return false
                    case .orderedDescending: return true
                    case .orderedSame: return true
                    }
                }
                return false
            }
        case .like:
            self.memoList = memoList.sorted { $0.like > $1.like }
        case .close:
            self.memoList = memoList.sorted {
                let first = fetchDistanceOfUserAndMemo(myLocation: CLLocationCoordinate2D(latitude: 37.5664056, longitude: 126.9778222), memoLocation: $0.location)
                let second = fetchDistanceOfUserAndMemo(myLocation: CLLocationCoordinate2D(latitude: 37.5664056, longitude: 126.9778222), memoLocation: $1.location)
                return first < second
            }
        }
    }
}
