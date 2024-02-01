//
//  MainSectionsView.swift
//  MyMemory
//
//  Created by 이명섭 on 2/1/24.
//

import SwiftUI

struct MainSectionsView: View {
    @EnvironmentObject var mainMapViewModel: MainMapViewModel
    @Binding var sortDistance: Bool
    @State var selectedIndex = 0
    var body: some View {
        NavigationStack {
            VStack {
                MenuTabBar(
                    menus: [MenuTabModel(index: 0, image: "list.bullet.below.rectangle"), MenuTabModel(index: 1, image: "newspaper")],
                    selectedIndex: $selectedIndex,
                    fullWidth: UIScreen.main.bounds.width,
                    spacing: 50,
                    horizontalInset: 91.5)
                
                switch selectedIndex {
                case 0:
                    MemoListView(sortDistance: $sortDistance)
                        .environmentObject(mainMapViewModel)
                default:
                    CommunityView()
                }
            }
            .background(Color.bgColor)
        }
    }
}

