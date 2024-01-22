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
            currentPage = "onboardingView"
            isFirstLaunch = false
        } else {
            currentPage = "mainView"
        }
    }
    
    var currentPage: String = "mainView" {
        didSet {
            withAnimation() {
                objectWillChange.send(self)
            }
        }
    }
}
