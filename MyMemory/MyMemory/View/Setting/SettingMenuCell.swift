//
//  SettingMenuCell.swift
//  MyMemory
//
//  Created by 이명섭 on 1/8/24.
//

import SwiftUI

struct SettingMenuCell: View {
    var name: String
    var body: some View {
        NavigationLink {
            
        } label: {
            HStack(alignment: .center) {
                Text(name)
                    .font(.regular18)
                Spacer()
            }.foregroundStyle(.black)
        }
    }
}
