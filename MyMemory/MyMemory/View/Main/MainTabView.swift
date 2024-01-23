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
    
    @State private var isPostView: Bool = false
    @State private var isLoginView: Bool = false
 
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
                
                
                Text("포스트뷰")
                    .onTapGesture {
                        selectedIndex = 1
                       
                    }
                    .tabItem {
                        Image(systemName: "pencil")
                        Text("메모하기")
                    }
                    .tag(1)
                
               // 로그인 상태 확인
               // if viewModel.userSession != nil {
                    // 로그인 상태가 맞다면, 로그인한 유저 확인한다.
                
                    if let user = viewModel.currentUser {
                        MypageView(user: user)
                            .onTapGesture{
                                selectedIndex = 2
                              
                            }
                            .tabItem {
                                Image(systemName: "person")
                                Text("마이")
                            }
                            .tag(2)
                   } else {
                       
                    Text("로그인이 필요합니다.")
                        .onTapGesture{
                            selectedIndex = 2
                           // isLogin = true
                            
                        }
                        .tabItem {
                            Image(systemName: "person")
                            Text("마이")
                        }
                        .tag(2)
                        
                    }
            }
           //  Tab 전환을 통해 화면 이동하는 방법 대신 Navigation으로 이동
            .onChange(of: selectedIndex) { [selectedIndex] newTab in
                
                if newTab == 1 && viewModel.userSession != nil   {
                    self.selectedIndex = selectedIndex
                    
                    isLoginView = false
                    isPostView = true
                }
                // 로그인 상태가 아닐 때,
                if newTab == 2 && viewModel.userSession == nil || newTab == 1 && viewModel.userSession == nil {
                    self.selectedIndex = selectedIndex
                    isPostView = false
                    isLoginView = true
                
                }
            }
            .background(

                NavigationLink(
                    destination: PostView(),
                    isActive: $isPostView
                ) {
                    EmptyView()
                }
                    .hidden()
                
            )
            // NavigationView - LoginView
            .background(
               
                NavigationLink(
                    destination: LoginView(),
                    isActive: $isLoginView
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
