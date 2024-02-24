//
//  MemoModel.swift
//  MyMemory
//
//  Created by 정정욱 on 1/15/24.
//

import Foundation
import UIKit
import _PhotosUI_SwiftUI
import FirebaseAuth

// Identifiable 채택시 고유의 ID를 만들어줘야함
struct PostMemoModel: Identifiable {
    let id: String // = UUID().uuidString // UUID() 고유의 ID값 생성후 문자열로 변환
    let userUid: String
    let userCoordinateLatitude: Double
    let userCoordinateLongitude: Double
    let userAddress: String
    let userAddressBuildingName: String?
    let memoTitle: String
    let memoContents: String
    let isPublic: Bool
    let isPinned: Bool
    let memoTagList: [String]
    let memoLikeCount: Int
    let memoSelectedImageData: [Data]
    let memoCreatedAt: TimeInterval
    let memoTheme: ThemeType
    let memoFont: FontType
    
    // Firestore 문서 ID를 사용하여 초기화 가능한 생성자 추가
    // id: String = UUID().uuidString 생성할때는 자동으로, 파베에서 불러서 넣어줄때는 생성했던 uid로 
    init(id: String = UUID().uuidString, userUid: String, userCoordinateLatitude: Double, userCoordinateLongitude: Double,
         userAddress: String, userAddressBuildingName: String? = nil, memoTitle: String, memoContents: String, isPublic: Bool,
         memoTagList: [String], memoLikeCount: Int, memoSelectedImageData: [Data],
         memoCreatedAt: TimeInterval, memoTheme: ThemeType, memoFont: FontType) {
        self.id = id
        self.userUid = userUid
        self.userCoordinateLatitude = userCoordinateLatitude
        self.userCoordinateLongitude = userCoordinateLongitude
        self.userAddress = userAddress
        self.userAddressBuildingName = userAddressBuildingName
        self.memoTitle = memoTitle
        self.memoContents = memoContents
        self.isPinned = false
        self.isPublic = isPublic
        self.memoTagList = memoTagList
        self.memoLikeCount = memoLikeCount
        self.memoSelectedImageData = memoSelectedImageData
        self.memoCreatedAt = memoCreatedAt
        self.memoTheme = memoTheme
        self.memoFont = memoFont
    }

    
    /*static let sampleMemoModel = PostMemoModel(userUid: "1234", userCoordinateLatitude: 37.5125, userCoordinateLongitude: 127.102778,
                                               userAddress: "대한민국 서울특별시 송파구 올림픽로 300 (신천동 29)",
                                               memoTitle: "오늘의 메모",
                                               memoContents: "메모메모메모메모메모메모",
                                               isPublic: false,
                                               memoTagList: ["데이트장소", "맛집"],
                                               memoLikeCount: 0,
                                               memoSelectedImageData: [/* initialize your PhotosPickerItem array here */],
                                               memoCreatedAt: Date().timeIntervalSince1970)
     */
}

