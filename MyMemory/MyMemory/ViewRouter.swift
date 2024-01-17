//
//  ViewRouter.swift
//  MyMemory
//
//  Created by 김소혜 on 1/16/24.
//

import Foundation
import Combine
import SwiftUI

final class ViewRouter: ObservableObject {
    
    let objectWillChange = PassthroughSubject<ViewRouter, Never>()
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    
    init(){
        setPage()
    }
    
    func setPage(){
        if isFirstLaunch {
            currentPage = "page0"
            isFirstLaunch = false
        } else {
            currentPage = "page1"
        }
    }
    
    var currentPage: String = "page1" {
        didSet {
            withAnimation() {
                objectWillChange.send(self)
            }
        }
    }
}
