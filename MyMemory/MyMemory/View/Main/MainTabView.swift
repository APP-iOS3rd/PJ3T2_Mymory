//
//  MainTabView.swift
//  MyMemory
//
//  Created by 김소혜 on 1/4/24.
//

import SwiftUI

struct MainTabView: View {
    
    //@State var selectedIndex: Int = 1
    @Binding var selectedIndex: Int
    var body: some View {
        NavigationView {
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
                    .onTapGesture{
                        selectedIndex = 1
                    }
                    .tabItem {
                        Image(systemName: "pencil")
                        Text("메모하기")
                    }.tag(1)
 
                MypageView()
                    .onTapGesture{
                        selectedIndex = 2
                    }
                    .tabItem {
                        Image(systemName: "person")
                        Text("마이")
                    }.tag(2)
                
                // 임시
//                RegisterView()
//                    .onTapGesture{
//                        selectedIndex = 3
//                    }
//                    .tabItem {
//                        Image(systemName: "person")
//                        Text("회원가입")
//                    }.tag(3)
            }
        }
    }
}

 
// 
//#Preview {
//    MainTabView(selectedIndex: 1)
//}
