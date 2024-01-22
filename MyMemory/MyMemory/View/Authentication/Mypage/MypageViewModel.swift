//
//  MyPageViewModel.swift
//  MyMemory
//
//  Created by 이명섭 on 1/4/24.
//

import Foundation
import CoreLocation
import _PhotosUI_SwiftUI
import FirebaseAuth

enum SortedTypeOfMemo: String, CaseIterable, Identifiable {
    case last = "최신순"
    case like = "좋아요순"
    case close = "가까운순"
    
    var id: Self { self }
}

// 임시
struct Memo: Hashable, Codable, Identifiable {
    // 유저Id
    var userId = UUID()
    // 메모 id
    var id = UUID()
    // 제목
    var userUid: String
    
    var title: String
    // 메모 내용
    var description: String
    // 주소
    var address: String
    // 태그
    var tags: [String]
    // 사진
    var images: [Data]
    // 공개여부
    var isPublic: Bool
    // 작성일
    var date: TimeInterval
    // 위치
    var location: Location
    // 좋아요 개수
    var likeCount: Int
    
    var memoImageUUIDs: [String]
    // 추후 이미지를 Storage에서 지우기 위한 변수입니다.
}

struct Location: Hashable, Codable {
    var latitude: Double
    var longitude: Double
    func distance(from loc: CLLocation) -> Double {
        let clloc = CLLocation(latitude: latitude, longitude: longitude)
        return clloc.distance(from: loc)
    }
}

class MypageViewModel: ObservableObject {   
    @Published var memoList: [Memo] = []
    @Published var selectedFilter = SortedTypeOfMemo.last
    @Published var isShowingOptions = false
    @Published var selectedImage: PhotosPickerItem? = nil
    @Published var selectedPhotoData: Data? = nil
    @Published var isCurrentUserLoginState = false
    
    init() {
        self.isCurrentUserLoginState = fetchCurrentUserLoginState()
        self.memoList = [
            Memo(userUid: "123", title: "ggg", description: "gggg", address: "서울시 @@구 @@동", tags: ["ggg", "Ggggg"], images: [], isPublic: false, date: Date().timeIntervalSince1970 - 1300, location: Location(latitude: 37.402101, longitude: 127.108478), likeCount: 10, memoImageUUIDs: [""]),
            Memo(userUid: "456", title: "ggg", description: "gggg", address: "서울시 @@구 @@동", tags: ["ggg", "Ggggg"], images: [], isPublic: false, date: Date().timeIntervalSince1970 - 3300, location: Location(latitude: 37.402201, longitude: 127.108578), likeCount: 10, memoImageUUIDs: [""]),
            Memo(userUid: "789", title: "ggg", description: "gggg", address: "서울시 @@구 @@동", tags: ["ggg", "Ggggg"], images: [], isPublic: false, date: Date().timeIntervalSince1970 - 100, location: Location(latitude: 37.402301, longitude: 127.108678), likeCount: 10, memoImageUUIDs: [""]),
            Memo(userUid: "91011", title: "ggg", description: "gggg", address: "서울시 @@구 @@동", tags: ["ggg", "Ggggg"], images: [], isPublic: false, date: Date().timeIntervalSince1970 + 200, location: Location(latitude: 37.402401, longitude: 127.108778), likeCount: 10, memoImageUUIDs: [""]),
            Memo(userUid: "1234", title: "ggg", description: "gggg", address: "서울시 @@구 @@동", tags: ["ggg", "Ggggg"], images: [], isPublic: false, date: Date().timeIntervalSince1970, location: Location(latitude: 37.402501, longitude: 127.108878), likeCount: 10, memoImageUUIDs: [""]),
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
                let first = Date(timeIntervalSince1970: $0.date)
                let second = Date(timeIntervalSince1970: $1.date)
                // 시간비교 orderedAscending: first가 second보다 이전(빠른), orderedDescending: first가 second보다 이후(늦은)
                switch first.compare(second) {
                case .orderedAscending: return false
                case .orderedDescending: return true
                case .orderedSame: return true
                }
        }
        case .like:
            self.memoList = memoList.sorted { $0.likeCount > $1.likeCount }
        case .close:
            self.memoList = memoList.sorted {
                let first = fetchDistanceOfUserAndMemo(myLocation: CLLocationCoordinate2D(latitude: 37.5664056, longitude: 126.9778222), memoLocation: $0.location)
                let second = fetchDistanceOfUserAndMemo(myLocation: CLLocationCoordinate2D(latitude: 37.5664056, longitude: 126.9778222), memoLocation: $1.location)
                return first < second
            }
        }
    }
    
    func fetchCurrentUserLoginState() -> Bool {
        if let _ = Auth.auth().currentUser {
            return true
        }
        return false
    }
}
