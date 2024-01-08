//
//  ContentView.swift
//  MyMemory
//
//  Created by 김태훈 on 1/2/24.
//

import SwiftUI

struct ContentView: View {
    @State var selectedIndex = 0
    
    var body: some View {
        //LoginView() 로그인 상태에 따라 분리
        MainTabView(selectedIndex: $selectedIndex)
    }
}

#Preview {
    ContentView()
}
