//
//  QuadTree.swift
//  MyMemory
//
//  Created by 김태훈 on 1/21/24.
//

import Foundation
import CoreLocation

// Quad Tree의 노드를 나타내는 클래스
final class QuadTreeNode{
    var coordinate: CLLocationCoordinate2D // 노드의 좌표
    var value: Memo // 노드의 값
    var topLeft: QuadTreeNode? // 좌상단 자식 노드
    var topRight: QuadTreeNode? // 우상단 자식 노드
    var bottomLeft: QuadTreeNode? // 좌하단 자식 노드
    var bottomRight: QuadTreeNode? // 우하단 자식 노드
    
    init(memo: Memo) {
        self.coordinate = .init(latitude: memo.location.latitude,
                                longitude: memo.location.longitude)
        self.value = memo
    }
}

// Quad Tree 클래스
final class QuadTree{
    private var rootNode: QuadTreeNode? = nil // 최상위 노드
    
    // 좌표를 기반으로 Quad Tree에 노드를 삽입하는 메서드
    func insert(memo: Memo) {
        let newNode = QuadTreeNode(memo: memo)
        if rootNode == nil {
            self.rootNode = newNode
        } else {
            insertNode(newNode, currentNode: rootNode)
        }
    }
    private func insertNode(_ newNode: QuadTreeNode, currentNode: QuadTreeNode?) {
        guard let currentNode = currentNode else {
            return
        }
        
        if newNode.coordinate.latitude >= currentNode.coordinate.latitude {
            if newNode.coordinate.longitude >= currentNode.coordinate.longitude {
                if currentNode.topRight == nil {
                    currentNode.topRight = newNode
                } else {
                    insertNode(newNode, currentNode: currentNode.topRight)
                }
            } else {
                if currentNode.topLeft == nil {
                    currentNode.topLeft = newNode
                } else {
                    insertNode(newNode, currentNode: currentNode.topLeft)
                }
            }
        } else {
            if newNode.coordinate.longitude >= currentNode.coordinate.longitude {
                if currentNode.bottomRight == nil {
                    currentNode.bottomRight = newNode
                } else {
                    insertNode(newNode, currentNode: currentNode.bottomRight)
                }
            } else {
                if currentNode.bottomLeft == nil {
                    currentNode.bottomLeft = newNode
                } else {
                    insertNode(newNode, currentNode: currentNode.bottomLeft)
                }
            }
        }
    }
    func search(inRegion region: ClusterBox) -> [Memo] {
        var nodes: [Memo] = []
        searchNodes(inRegion: region, currentNode: rootNode, foundNodes: &nodes)
        return nodes
    }
    
    private func searchNodes(inRegion region: ClusterBox, currentNode: QuadTreeNode?, foundNodes: inout [Memo]) {
        guard let currentNode = currentNode else {
            return
        }
        if region.containsCoordinate(coordinate: currentNode.coordinate) {
            foundNodes.append(currentNode.value)
        }
        searchNodes(inRegion: region, currentNode: currentNode.topLeft, foundNodes: &foundNodes)
        searchNodes(inRegion: region, currentNode: currentNode.topRight, foundNodes: &foundNodes)
        searchNodes(inRegion: region, currentNode: currentNode.bottomLeft, foundNodes: &foundNodes)
        searchNodes(inRegion: region, currentNode: currentNode.bottomRight, foundNodes: &foundNodes)
    }
    func removeAllNodes() {
        rootNode = nil
    }
    private func removeNode(memo: Memo) {
        removeNode(memo, currentNode: rootNode)
    }
    private func removeNode(_ memo: Memo, currentNode: QuadTreeNode?) -> QuadTreeNode? {
        guard let currentNode = currentNode else {
            return nil
        }
        
        if currentNode.value == memo {
            return nil
        }
        
        currentNode.topLeft = removeNode(memo, currentNode: currentNode.topLeft)
        currentNode.topRight = removeNode(memo, currentNode: currentNode.topRight)
        currentNode.bottomLeft = removeNode(memo, currentNode: currentNode.bottomLeft)
        currentNode.bottomRight = removeNode(memo, currentNode: currentNode.bottomRight)
        
        return currentNode
    }
}
