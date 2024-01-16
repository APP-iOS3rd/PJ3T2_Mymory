//
//  CurrentSpotButton.swift
//  MyMemory
//
//  Created by 김소혜 on 1/15/24.
//

import SwiftUI

struct CurrentSpotButton: View {
    
    @State private var isClicked: Bool = false
   
    var body: some View {
        Image(systemName: "dot.scope")
            .frame(width: 40, height: 40)
            .background(isClicked ? Color.lightPrimary : .white)
            .clipShape(Circle())
            .cornerRadius(40)
            .overlay(
                Circle()
                    .stroke(Color(UIColor.systemGray5))
            )
         
    }
}

#Preview {
    CurrentSpotButton()
}
