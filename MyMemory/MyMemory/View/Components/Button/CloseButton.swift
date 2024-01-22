//
//  CloseButton.swift
//  MyMemory
//
//  Created by 김소혜 on 1/18/24.
//

import SwiftUI

struct CloseButton: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
       
        Button {
            self.presentationMode.wrappedValue.dismiss()
        } label: {
            HStack(spacing: 0){
                Image(systemName: "multiply")
                    .resizable()
                    .frame(width: 18, height: 18)
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.deepGray)
//                Text("이전")
            }
        }
    }
}

#Preview {
    CloseButton()
}
