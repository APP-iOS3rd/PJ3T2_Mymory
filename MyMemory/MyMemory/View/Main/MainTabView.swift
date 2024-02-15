//
//  MainTabView.swift
//  MyMemory
//
//  Created by 김소혜 on 1/4/24.
//

import SwiftUI
import Combine

struct MainTabView: View {
    
    @State private var selectedIndex = 0
    @AppStorage("_isFirstLaunching") var isFirstLaunching: Bool = true
    
    var body: some View {
        NavigationStack  {
            TabView(selection: $selectedIndex){
                Group {
                    MainMapView()
                        .onTapGesture{
                            selectedIndex = 0
                        }
                        .tabItem {
                            Image(systemName: "map")
                            Text("지도")
                        }.tag(0)
                    
                    PostView(selected: $selectedIndex)
                        .tabItem {
                            Image(systemName: "pencil")
                            Text("메모하기")
                        }
                        .tag(1)
                    
                    MyPageView(selected: $selectedIndex)
                        .onTapGesture{
                            selectedIndex = 2
                        }
                        .tabItem {
                            Image(systemName: "person")
                            Text("마이")
                        }
                        .tag(2)
                }
                .toolbarBackground(.visible, for: .tabBar)
            }
            .background(Color.bgColor)
        }
        .onAppear {
            AuthService.shared.fetchUser()
        }
        .fullScreenCover(isPresented: $isFirstLaunching) {
            OnboardingView(isFirstLaunching: $isFirstLaunching)
        }
    }
}

//
//#Preview {
//    MainTabView(selectedIndex: 1)
//}
