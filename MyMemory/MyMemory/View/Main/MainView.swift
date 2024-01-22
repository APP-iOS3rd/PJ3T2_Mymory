//
//  MainView.swift
//  MyMemory
//
//  Created by 김소혜 on 1/16/24.
//

import SwiftUI

struct MainView: View {
   
    @StateObject var viewRouter: ViewRouter = .init()
    @State var initialIdx = 0
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        
        if viewRouter.currentPage == "page0" {
            OnboardingView(viewRouter: viewRouter)
        }
        
        else if viewRouter.currentPage == "page1" {
           
            if let user = viewModel.currentUser {
                MainTabView(user: user, selectedIndex: $initialIdx)
            }
        }
    }
}

#Preview {
    MainView(viewRouter: ViewRouter())
}
