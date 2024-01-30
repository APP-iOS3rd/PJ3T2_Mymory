//
//  Clustering.swift
//  MyMemory
//
//  Created by 김태훈 on 1/21/24.
//

import Foundation
import CoreLocation
import MapKit
protocol ClusteringDelegate: AnyObject {
    
    func displayClusters(clusters: [MemoCluster])
}
final class ClusterOperation {
    public weak var delegate: ClusteringDelegate?
    
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
            self.quadTree.removeAllNodes()
            for memo in memos {
                self.quadTree.insert(memo: memo)
            }
        }
    }
    
    public func clusterMemosWithMapRect(visibleMapRect: MKMapRect, zoomScale: Double) {
        operationQueue.cancelAllOperations()
        guard !zoomScale.isInfinite else {
            return
        }
        var clusterMemos: [MemoCluster] = []
        let cellSizePoints = Double(visibleMapRect.size.width/Double(ClusterOperation.cellSizeForZoomScale(zoomScale: MKZoomScale(zoomScale))))
        let minX = visibleMapRect.minX
        let maxX = visibleMapRect.maxX
        let minY = visibleMapRect.minY
        let maxY = visibleMapRect.maxY
        
        operationQueue.addOperation {
            var yCoordinate = minY
            
            while yCoordinate<maxY {
                var xCoordinate = minX
                
                while xCoordinate<maxX {
                    let mapRect = MKMapRect(x: xCoordinate, y: yCoordinate, width: cellSizePoints, height: cellSizePoints)
                    let area = ClusterBox.mapRectToBoundingBox(mapRect: mapRect)
                    let memos = self.quadTree.search(inRegion: area)
                    if !memos.isEmpty {
                        clusterMemos.append(MemoCluster(memoList: memos))
                    }
                    xCoordinate+=cellSizePoints
                }
                yCoordinate+=cellSizePoints
            }
            self.delegate?.displayClusters(clusters: clusterMemos)
        }
    }
}
extension ClusterOperation {
    
    class func zoomScaleToZoomLevel(scale: MKZoomScale) -> Int {
        
        let totalTilesAtMaxZoom = MKMapSize.world.width / 256.0
        let zoomLevelAtMaxZoom = CGFloat(log2(totalTilesAtMaxZoom))
        
        return Int(max(0,zoomLevelAtMaxZoom+CGFloat(floor(log2f(Float(scale))+0.5))))
        
    }
    
    class func cellSizeForZoomScale(zoomScale: MKZoomScale) -> Int {
        
        let zoomLevel = zoomScaleToZoomLevel(scale: zoomScale)
        
        switch zoomLevel {
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
