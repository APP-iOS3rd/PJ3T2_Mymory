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
 
    @State var isLogin: Bool = false
 
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
                
                // 로그인한 유저 확인
                if viewModel.userSession != nil {
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
                   }
                } 
                // 로그아웃 상태일 때,
                else {
                    
                    Text("로그인이 필요합니다.")
                        .onTapGesture{
                            selectedIndex = 2
                             
                            isLogin = true
                        }
                        .tabItem {
                            Image(systemName: "person")
                            Text("마이")
                        }
                        .tag(2)
                    
                }
            }
            // PostView는 Tab전환 대신 Navigation으로 이동
            .onChange(of: selectedIndex) { [selectedIndex] newTab in
                if newTab == 1 {
                    self.selectedIndex = selectedIndex
                    isPresented = true
                    isLogin = false
                    
                }
                if newTab == 2 && viewModel.userSession == nil {
                    self.selectedIndex = selectedIndex
                    isLogin = true
                    isPresented = false
                    
                }
            }
            // NavigationView - PostView
            .background(
                
                NavigationLink(
                    destination: PostView(selected: $selectedIndex),
                    isActive: $isPresented
                ) {
                    EmptyView()
                }
                    .hidden()
                
            )
            // NavigationView - LoginView
            .background(
                
                NavigationLink(
                    destination: LoginView(),
                    isActive: $isLogin
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
