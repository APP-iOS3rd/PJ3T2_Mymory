//
//  CurrentSpotButton.swift
//  MyMemory
//
//  Created by 김소혜 on 1/15/24.
//

import SwiftUI

struct CurrentSpotButton: View {
    
    @State var isClicked: Bool = false
    //@Binding var isClicked: Bool
    
    var body: some View {
        Image(systemName: "dot.scope")
            .foregroundColor(Color.deepGray)
            .frame(width: 40, height: 40)
            .background(isClicked ? Color.lightPrimary : .white)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.lightGray)
            )
           
    }
}

//#Preview {
//    CurrentSpotButton()
//}
