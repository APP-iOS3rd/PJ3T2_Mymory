//
//  SettingMenuCell.swift
//  MyMemory
//
//  Created by 이명섭 on 1/8/24.
//

import SwiftUI

struct SettingMenuCell: View {
    var name: String
    var page: String = ""
    
    var body: some View {
        
        NavigationLink {
            chooseDestination()
        } label: {
            HStack(alignment: .center) {
                Text(name)
                    .font(.regular18)
                Spacer()
            }
            .foregroundStyle(Color.textColor)
        }

    }
    
    
    @ViewBuilder
    func chooseDestination() -> some View {
        switch page {
        case "theme": ThemeView()
        case "login": LoginView()
        case "font": FontView()
        default: EmptyView()
        }
    }
}
