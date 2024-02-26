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
    @State private var isKeyboardVisible = false
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
                                Image("square.and.pencil")
                                Text("작성")
                            }
                            .tag(2)
                        
                        
                        MyPageView(selected: $selectedIndex)
                            .onTapGesture{
                                selectedIndex = 3
                            }
                            .tabItem {
                                Image(systemName: "person")
                                Text("MY")
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
                // 키보드가 활성화되지 않았을 때만 버튼을 표시합니다.
                if !isKeyboardVisible {
                       Button {
                           selectedIndex = 2
                       } label: {
                           Image(systemName: "plus")
                               .fontWeight(.bold)
                               .tint(Color.white)
                       }
                       .frame(width: 30, height: 30)
                       .background(Color.accentColor)
                       .clipShape(Circle())
                       .offset(CGSize(width: 0, height: -16))
                   }
            }
        }
        .onAppear {
            AuthService.shared.fetchUser()
            // 키보드가 나타나는 이벤트를 감지합니다.
           NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
               isKeyboardVisible = true
           }
           // 키보드가 사라지는 이벤트를 감지합니다.
           NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
               isKeyboardVisible = false
           }
        }
    
    }
}


//
//#Preview {
//    MainTabView(selectedIndex: 1)
//}
