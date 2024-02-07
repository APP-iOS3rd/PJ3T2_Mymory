//
//  FilterButton.swift
//  MyMemory
//
//  Created by 김소혜 on 1/15/24.
//

import SwiftUI

struct FilterButton: View {
    @State var imageName: String = "line.3.horizontal"
    @Binding var buttonName: String
 
    var body: some View {
        HStack {
            Image(systemName: imageName)
            Text(LocalizedStringKey(buttonName))
        }
    }
}

//#Preview {
//    FilterButton(action: bss())
//}
