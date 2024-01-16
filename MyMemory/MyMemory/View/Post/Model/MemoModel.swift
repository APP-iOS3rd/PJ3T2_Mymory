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
struct MemoModel: Identifiable {
    let id: String = UUID().uuidString // UUID() 고유의 ID값 생성후 문자열로 변환
    let userCoordinate: CLLocationCoordinate2D
    let userAddress: String
    let memoTitle: String
    let memoContents: String
    let memoShare:Bool
    let memoTagList: [String]
    let memoLikeCount: Int
    let memoimages: [PhotosPickerItem]
    let momocreatedAt: TimeInterval
    
    
    static let sampleMemoModel = MemoModel(userCoordinate: CLLocationCoordinate2D(latitude: 37.5125, longitude: 127.102778),
                                               userAddress: "대한민국 서울특별시 송파구 올림픽로 300 (신천동 29)",
                                               memoTitle: "오늘의 메모",
                                               memoContents: "메모메모메모메모메모메모",
                                               memoShare: false,
                                               memoTagList: ["데이트장소", "맛집"],
                                               memoLikeCount: 0,
                                               memoimages: [/* initialize your PhotosPickerItem array here */],
                                               momocreatedAt: Date().timeIntervalSince1970)
}

