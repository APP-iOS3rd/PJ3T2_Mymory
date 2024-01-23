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
    @State var selectedIndex = 0
    @ObservedObject var viewModel: AuthViewModel
    @State var isPresented: Bool = false
    
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

                PostView(selected: $selectedIndex)
                    .onTapGesture {
                        selectedIndex = 1
                    }
                    .tabItem {
                        Image(systemName: "pencil")
                        Text("메모하기")
                    }
                    .tag(1)
 
                if let user = viewModel.currentUser {
                    if viewModel.userSession != nil {
               
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
                else {
                    
                    LoginView()
                        .onTapGesture{
                            selectedIndex = 2
                            //isPresented.toggle()
                        }
                        .tabItem {
                            Image(systemName: "person")
                            Text("마이")
                        }
                        .tag(2)
                }
 
            }
//            .onChange(of: selectedIndex) { value in
//              //  if selectedIndex ==  2 {
//                     
//                    if viewModel.userSession == nil {
//                        isPresented = true
//                    }
//                
//                //}
//                print(value)
//            }
//            .fullScreenCover(isPresented: $isPresented) {
//                LoginView()
//            }
        }
        
    }
}

 
// 
//#Preview {
//    MainTabView(selectedIndex: 1)
//}
