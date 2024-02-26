//
//  Memo.swift
//  MyMemory
//
//  Created by 김소혜 on 1/23/24.
//

import Foundation
import FirebaseFirestore
import Firebase
import CoreLocation

struct Memo: Hashable, Codable, Identifiable, Equatable {
   
    @DocumentID var id: String? // 메모 id: 도큐먼트 이름을 memo의 아이디로 설정
    // var userId: String  // 작성한 유저Id = UUID()
    var userUid: String
    
    var title: String // 제목
    var description: String // 메모 내용
    var address: String  // 주소
    var building: String?
    var tags: [String]  // 태그
    var imagesURL: [String] // 사진 Url
    var isPublic: Bool = true // 공개여부
    var isPinned: Bool
    var date: TimeInterval  // 작성일 timestamp
    var location: Location  // 위치
    var likeCount: Int  // 좋아요 개수
    var didLike = false // 좋아요 누른 것을 확인
    var memoImageUUIDs: [String]  // 추후 이미지를 Storage에서 지우기 위한 변수입니다.
    var memoTheme: ThemeType
    var memoFont: FontType
}

struct Location: Hashable, Codable {
    var latitude: Double
    var longitude: Double
    func distance(from loc: CLLocation) -> Double {
        let clloc = CLLocation(latitude: latitude, longitude: longitude)
        let dist = clloc.distance(from: loc)
            
        return dist
    }
}
struct BuildingInfo: Equatable, Hashable {
    let buildingName: String
    let address: String
    var count: Int
    let location: Location
    
    static func == (lhs: BuildingInfo, rhs: BuildingInfo) -> Bool {
        lhs.buildingName == rhs.buildingName
    }

}
