//
//  MainView.swift
//  MyMemory
//
//  Created by 김소혜 on 1/16/24.
//

import SwiftUI

struct MainView: View {
    
    @ObservedObject var viewRouter: ViewRouter
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        
        if viewRouter.currentPage == "onboardingView" {
            OnboardingView(viewRouter: viewRouter)
        }
        else if viewModel.userSession == nil {
            LoginView(viewModel: viewModel)
        }
        
        else if viewRouter.currentPage == "mainView" {
            if let user = viewModel.currentUser {
                MainTabView(user: user, viewRouter: viewRouter)
            }
        }
    }
}

//#Preview {
//    MainView(viewRouter: ViewRouter(), memo: <#Memo#>)
//}
