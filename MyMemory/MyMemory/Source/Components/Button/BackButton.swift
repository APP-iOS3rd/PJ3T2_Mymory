//
//  BackButton.swift
//  MyMemory
//
//  Created by 김소혜 on 1/4/24.
//

import SwiftUI

struct BackButton: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        Button {
            self.presentationMode.wrappedValue.dismiss()
        } label: {
            HStack(spacing: 4){
                Image(systemName: "chevron.left")
                    .font(.bold24)
                    .aspectRatio(contentMode: .fit)
//                    .foregroundColor(.deepGray)
//                Text("이전")
//                    .font(.semibold16)
            }
     
        }
    }
}

#Preview {
    BackButton()
}
