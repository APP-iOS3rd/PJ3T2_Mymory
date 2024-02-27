//
//  SettingTabView.swift
//  MyMemory
//
//  Created by 김소혜 on 2/23/24.
//

import SwiftUI

struct SettingTabView: View {
    @Binding var selected: Int
    @ObservedObject var authViewModel : AuthService = .shared
    @State var profile: Profile? = nil
    
    var body: some View {
        ZStack{
            Color.bgColor.ignoresSafeArea()
            
            SettingView(user: $authViewModel.currentUser,
                        isCurrentUserLoginState: $authViewModel.isCurrentUserLoginState, selected: $selected)
        }
     
    }
}

//#Preview {
//    SettingTabView()
//}
