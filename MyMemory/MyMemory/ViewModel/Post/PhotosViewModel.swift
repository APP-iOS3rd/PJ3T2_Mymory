//
//  PhotosViewModel.swift
//  MyMemory
//
//  Created by 김태훈 on 2/19/24.
//

import Foundation
import Photos
import PhotosUI
import SwiftUI
struct Asset : Hashable{
    let asset: PHAsset
    let image: UIImage
    var selected: Bool = false
    init(asset: PHAsset, image: UIImage) {
        self.asset = asset
        self.image = image
    }

}

final class PhotosViewModel: ObservableObject {
    @Published var assets: [Asset] = []
    private let fetchLimit = 100 // 가져올 사진의 개수 제한
    private var page = 0
    private var fetchResult: PHFetchResult<PHAsset>? // fetchResult 변수 추가
    @Published var pagenate: Bool = true
    init() {
        fetchPhotos()
    }
    deinit {
        print("deinit Photos")
        self.assets = []
    }
    func fetchPhotos() {
        let fetchOptions = PHFetchOptions()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sortDescriptor]
        
        fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions) // fetchResult 초기화
        guard let fetchResult = fetchResult else {
            return
        }
        
        // 사진 정보를 처리하는 로직을 작성하세요.
        // asset을 이용하여 사진에 접근하고 필요한 정보를 가져올 수 있습니다.
        Task{@MainActor in
            
            for index in 0..<min(fetchLimit, fetchResult.count) {
                let asset = fetchResult.object(at: index)
                if asset.mediaType == .image {
                    if let image = await convertPHAssetToImage(asset : asset) {
                        // 이미지 사용
                        self.assets.append(.init(asset: asset, image: image))
                    }
                }
            }
            page += 1
        }
        
    }
    
    // 추가적인 사진 로딩을 위한 메서드
    func loadMorePhotos() {
        guard let fetchResult = fetchResult else {
            return
        }
        
        guard assets.count < fetchResult.count else {
            return // 이미 모든 사진을 가져왔으면 종료
        }
        let remainingCount = fetchResult.count - assets.count
        Task{@MainActor in

        var additionalLimit = 0
        if fetchLimit > remainingCount {
            additionalLimit = remainingCount
        } else {
            additionalLimit = fetchLimit
        }
            for index in (fetchLimit*page)..<((fetchLimit*page) + additionalLimit) {
                let asset = fetchResult.object(at: index)
                if asset.mediaType == .image {
                    if let image = await convertPHAssetToImage(asset : asset) {
                        // 이미지 사용
                        self.assets.append(.init(asset: asset, image: image))
                    }
                }
                // 사진 정보를 처리하는 로직을 작성하세요.
                // asset을 이용하여 사진에 접근하고 필요한 정보를 가져올 수 있습니다.
            }
            if fetchLimit == additionalLimit {
                page += 1
                self.pagenate = true
            }
        }
    }
    func convertPHAssetToImage(asset: PHAsset) async -> UIImage? {
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true // 동기적으로 이미지를 요청합니다.
        return await withCheckedContinuation { continuation in
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 200, height: 200),  contentMode: .aspectFill, options: requestOptions) { imageData, _ in
                if let image = imageData {
                    continuation.resume(returning: image)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}
extension PHAsset {
    func convertPHAssetToImage() async -> (UIImage, String)? {
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true // 동기적으로 이미지를 요청합니다.
        return await withCheckedContinuation { continuation in
            PHImageManager.default().requestImage(for: self, targetSize: CGSize(width: 200, height: 200),  contentMode: .aspectFill, options: requestOptions) { imageData, _ in
                if let image = imageData {
                    continuation.resume(returning: (image, self.localIdentifier))
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}
