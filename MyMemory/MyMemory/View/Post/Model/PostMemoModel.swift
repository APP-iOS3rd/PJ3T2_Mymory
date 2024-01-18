//
//  MemoModel.swift
//  MyMemory
//
//  Created by 정정욱 on 1/15/24.
//

import Foundation
import UIKit
import _PhotosUI_SwiftUI

// Identifiable 채택시 고유의 ID를 만들어줘야함
struct PostMemoModel: Identifiable {
    let id: String = UUID().uuidString // UUID() 고유의 ID값 생성후 문자열로 변환
    let userCoordinateLatitude: Double
    let userCoordinateLongitude: Double
    let userAddress: String
    let memoTitle: String
    let memoContents: String
    let isPublic:Bool
    let memoTagList: [String]
    let memoLikeCount: Int
    let memoSelectedImageData: [Data]
    let memocreatedAt: TimeInterval
    
    
    static let sampleMemoModel = PostMemoModel(userCoordinateLatitude: 37.5125, userCoordinateLongitude: 127.102778,
                                               userAddress: "대한민국 서울특별시 송파구 올림픽로 300 (신천동 29)",
                                               memoTitle: "오늘의 메모",
                                               memoContents: "메모메모메모메모메모메모",
                                               isPublic: false,
                                               memoTagList: ["데이트장소", "맛집"],
                                               memoLikeCount: 0,
                                               memoSelectedImageData: [/* initialize your PhotosPickerItem array here */],
                                               memocreatedAt: Date().timeIntervalSince1970)
}

