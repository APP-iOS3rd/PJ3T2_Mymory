//
//  MainTabView.swift
//  MyMemory
//
//  Created by 김소혜 on 1/4/24.
//

import SwiftUI
import Combine

struct MainTabView: View {
    
    @ObservedObject var viewRouter: ViewRouter
    @State private var selectedIndex = 0
    @EnvironmentObject var viewModel : AuthViewModel
    @State var isPresented: Bool = false
 
    var body: some View {
        
        NavigationStack  {
            TabView(selection: $selectedIndex){
                
                MainMapView()
                    .onTapGesture{
                        selectedIndex = 0
                    }
                    .tabItem {
                        Image(systemName: "map.fill")
                        Text("지도")
                    }.tag(0)
                
                
                Text("")
                    .onTapGesture {
                        selectedIndex = 1
                    }
                    .tabItem {
                        Image(systemName: "pencil")
                        Text("메모하기")
                    }
                    .tag(1)
                
                MypageView()
                    .onTapGesture{
                        selectedIndex = 2
                    }
                    .tabItem {
                        Image(systemName: "person")
                        Text("마이")
                    }
                    .tag(2)
            }
            // PostView는 Tab전환 대신 Navigation으로 이동
            .onChange(of: selectedIndex) { [selectedIndex] newTab in
                if newTab == 1 {
                    self.selectedIndex = selectedIndex
                    isPresented = true
                }
            }
            .background(
                NavigationLink(
                    destination: PostView(),
                    isActive: $isPresented
                ) {
                    EmptyView()
                }
                    .hidden()
            )
                
        }
      
    }
        
 
}

 
// 
//#Preview {
//    MainTabView(selectedIndex: 1)
//}
