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
                
                
                Text("포스트뷰").hidden()
                    .onTapGesture {
                        selectedIndex = 1
                    }
                    .tabItem {
                        Image(systemName: "pencil")
                        Text("메모하기")
                    }
                    .tag(1)
                
                    // 로그인 여부, 유저 정보를 확인한다.
                    if let user = viewModel.currentUser {
                        
                        MypageView(user: user)
                            .onTapGesture {
                                selectedIndex = 2
                            }
                            .tabItem {
                                Image(systemName: "person")
                                Text("마이")
                            }
                            .tag(2)
                        
                   } else {
                       
                       Text("로그인이 필요합니다.").hidden()
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
            // [화면 이동 방법] Tab 전환 대신 Navigation 으로 화면이동
            .onChange(of: selectedIndex) { [selectedIndex] newTab in
                
                // 클릭한 탭이 tag(1)이고, userSession이 nil이 아닐 때,
                if newTab == 1 && viewModel.userSession != nil   {
                    self.selectedIndex = selectedIndex
                    isLoginView = false
                    isPostView = true
                }
                // 로그인 상태가 아닐 때, tag(0)일때는 loginview x
                if newTab == 2 && viewModel.userSession == nil || newTab == 1 && viewModel.userSession == nil  {
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
            .background(
                
                NavigationLink(
                    destination: LoginView(),
                    isActive: $isLoginView
                ) {
                    EmptyView()
                }
                .hidden()
                
            )
            
            
//            
//            .fullScreenCover(isPresented: $isLoginView) {
//                LoginView()
//            }
 
        }
      
    }
        
 
}

 
// 
//#Preview {
//    MainTabView(selectedIndex: 1)
//}
