//
//  Clustering.swift
//  MyMemory
//
//  Created by 김태훈 on 1/21/24.
//

import Foundation
import CoreLocation
import KakaoMapsSDK
protocol PGClusteringManagerDelegate: AnyObject {
    
    func displayClusters(clusters: [MemoCluster])
}
final class ClusterOperation {
    public weak var delegate: PGClusteringManagerDelegate?

    private var operationQueue = OperationQueue()

    private let quadTree = QuadTree()
    private var dispatchQueue = DispatchQueue(label: "io.pablogs.concurrent", attributes: DispatchQueue.Attributes.concurrent)

    public func addMemo(memo: Memo) {
        operationQueue.cancelAllOperations()

        dispatchQueue.async {
            self.quadTree.insert(memo: memo)
        }
    }
    public func addMemoList(memos: [Memo]) {
        operationQueue.cancelAllOperations()

        dispatchQueue.async {
            for memo in memos {
                self.quadTree.insert(memo: memo)
            }
        }
    }
    
    public func clusterMemosWithMapRect(cameraRect: AreaRect, zoomScale: Int = 16) {
        var clusterMemos: [MemoCluster] = []
        let cellSizePoint = Double(cameraRect.width / Double(cellSizeForZoomScale(zoomScale: zoomScale)))
        
        let minX = cameraRect.minX
        let maxX = cameraRect.maxX
        let minY = cameraRect.minY
        let maxY = cameraRect.maxY
        operationQueue.cancelAllOperations()
        operationQueue.addOperation {
            var yCoordinate = minY
            
            while yCoordinate<maxY {
                var xCoordinate = minX
                
                while xCoordinate<maxX {
                    let area = ClusterBox.mapRectToBoundingBox(mapRect: AreaRect(southWest: .init(longitude: xCoordinate, latitude: yCoordinate)
                                                                                 , northEast: .init(from: .init(longitude: xCoordinate + cellSizePoint, latitude: yCoordinate + cellSizePoint))))
                    let memos = self.quadTree.search(inRegion: area)
                    if !memos.isEmpty {
                        clusterMemos.append(MemoCluster(memoList: memos))
                    }
                    xCoordinate += cellSizePoint
                }
                yCoordinate += cellSizePoint
            }
            self.delegate?.displayClusters(clusters: clusterMemos)
        }
    }
    private func cellSizeForZoomScale(zoomScale: Int) -> Int {
        
        switch zoomScale {
        case 0...4:
            return 32
        case 5...8:
            return 16
        case 9...16:
            return 8
        case 17...20:
            return 4
        default:
            return 10
        }
    }
}

extension AreaRect {
    var width: Double {
        abs(self.northEast.wgsCoord.longitude - self.southWest.wgsCoord.longitude)
    }
    var widthMeters: Double {
        let west = CLLocation(latitude: minY, longitude: minX)
        let east = CLLocation(latitude: minY, longitude: maxX)
        return west.distance(from: east)
    }
    var heightMeters: Double {
        let west = CLLocation(latitude: minY, longitude: minX)
        let east = CLLocation(latitude: maxY, longitude: minX)
        return west.distance(from: east)
    }
    var minX: CGFloat {
        self.southWest.wgsCoord.longitude
    }
    var maxX: CGFloat {
        self.northEast.wgsCoord.longitude
    }
    var minY: CGFloat {
        self.northEast.wgsCoord.latitude
    }
    var maxY: CGFloat {
        self.southWest.wgsCoord.latitude
    }
}

