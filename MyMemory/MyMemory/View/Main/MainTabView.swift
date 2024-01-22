//
//  MainTabView.swift
//  MyMemory
//
//  Created by 김소혜 on 1/4/24.
//

import SwiftUI
import Combine

struct MainTabView: View {
    
    let user: User
    @ObservedObject var viewRouter: ViewRouter
    @State private var selectedIndex = 0
    @State var isPresented = false
    
    var body: some View {
        
        NavigationStack {
            TabView(selection: $selectedIndex){
                
                MainMapView()
                    .onTapGesture{
                        selectedIndex = 0
                    }
                    .tabItem {
                        Image(systemName: "map.fill")
                        Text("지도")
                    }.tag(0)

                PostView()
                    .onTapGesture {
                        selectedIndex = 1
                    }
                    .tabItem {
                        Image(systemName: "pencil")
                        Text("메모하기")
                    }
                    .tag(1)
                
                MypageView(user: user)
                    .onTapGesture{
                        selectedIndex = 2
                    }
                    .tabItem {
                        Image(systemName: "person")
                        Text("마이")
                    }
                    .tag(2)
            }
        }
        
    }
}

 
// 
//#Preview {
//    MainTabView(selectedIndex: 1)
//}
