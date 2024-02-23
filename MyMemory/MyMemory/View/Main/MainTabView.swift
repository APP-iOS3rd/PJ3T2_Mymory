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
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                TabView(selection: $selectedIndex){
                    Group {
                        MainMapView()
                            .onTapGesture{
                                selectedIndex = 0
                            }
                            .tabItem {
                                Image(systemName: "map")
                                Text("지도")
                            }
                            .tag(0)
                        
                        CommunityTabView(selected: $selectedIndex) { logout in
                            if logout {
                                
                            }
                            
                        }
                        .onTapGesture{
                            selectedIndex = 1
                        }
                        .tabItem {
                            Image(systemName: "rectangle.fill.on.rectangle.angled.fill")
                            Text("피드")
                        }
                        .tag(1)
                        
                        PostView(selected: $selectedIndex, isEdit: false)
                            .onTapGesture{
                                selectedIndex = 2
                            }
                            .tabItem {
                                EmptyView()
                            }
                            .tag(2)
                            
                        
                        MyPageView(selected: $selectedIndex)
                            .onTapGesture{
                                selectedIndex = 3
                            }
                            .tabItem {
                                
                                Image(systemName: "person")
                                Text("My 메모")
                            }
                            .tag(3)

                        SettingTabView(selected: $selectedIndex)
                            .onTapGesture{
                                selectedIndex = 4
                            }
                            .tabItem {
                                Image(systemName: "gear")
                                Text("설정")
                            }
                            .tag(4)
                        
                    }
                    .toolbarBackground(.visible, for: .tabBar)
                }
                
               Button {
                   selectedIndex = 2
               } label: {
                   Image(systemName: "plus")
                       .fontWeight(.bold)
                       .tint(Color.white)
               }
               .frame(width: 50, height: 50)
               .background(Color.accentColor)
               .clipShape(Circle())
            }
        }
        .onAppear {
            AuthService.shared.fetchUser()
        }
    
    }
}


//
//#Preview {
//    MainTabView(selectedIndex: 1)
//}
