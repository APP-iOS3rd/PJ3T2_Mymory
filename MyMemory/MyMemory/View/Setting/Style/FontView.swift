//
//  FontView.swift
//  MyMemory
//
//  Created by 김소혜 on 2/2/24.
//

import SwiftUI

struct FontView: View {
    var body: some View {
        VStack {
            Text("폰트")
        }
        .customNavigationBar(
            centerView: {
                Text("폰트 선택")
            },
            leftView: {
                BackButton()
            },
            rightView: {
              EmptyView()
            },
            backgroundColor: .bgColor3
        )
    }
}

//#Preview {
//    FontView()
//}
