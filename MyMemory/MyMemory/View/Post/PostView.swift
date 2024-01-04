//
//  PostView.swift
//  MyMemory
//
//  Created by 김소혜 on 1/4/24.
//

import SwiftUI

struct PostView: View {
    var body: some View {
        VStack {
            NavigationLink {
                ReportView()
            } label: {
                Text("신고하기")
            }

            
        }
    }
}

#Preview {
    PostView()
}
