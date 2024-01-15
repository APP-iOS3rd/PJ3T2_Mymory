//
//  MainTabView.swift
//  MyMemory
//
//  Created by 김소혜 on 1/4/24.
//

import SwiftUI

struct MainTabView: View {
    
    @Binding var selectedIndex: Int
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedIndex){
                MainMapView()
                    .onTapGesture{
                        selectedIndex = 0
                    }
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("지도")
                    }.tag(0)
                
                PostView()
                    .onTapGesture{
                        selectedIndex = 1
                    }
                    .tabItem {
                        Image(systemName: "pencil")
                        Text("작성")
                    }.tag(1)
                
                MypageView()
                    .onTapGesture{
                        selectedIndex = 2
                    }
                    .tabItem {
                        Image(systemName: "person")
                        Text("마이")
                    }.tag(2)
            }
        }
    }
}
