//
//  SettingMenuCell.swift
//  MyMemory
//
//  Created by 이명섭 on 1/8/24.
//

import SwiftUI

struct SettingMenuCell: View {
    var name: String
    var iconName: String?
    var body: some View {
        NavigationLink {
            
        } label: {
            HStack(alignment: .center) {
                Text(name)
                    .font(.regular18)
                Spacer()
                if let iconName {
                    Image(systemName: iconName)
                        .font(.system(size: 24))
                } else {
                    Text("1.0.0")
                        .foregroundStyle(Color(UIColor.systemGray))
                }
            }.foregroundStyle(.black)
        }
    }
}

