//
//  Textarea.swift
//  MyMemory
//
//  Created by 김소혜 on 1/4/24.
//

import SwiftUI

struct Textarea: View {
    @State var label = "텍스트필드 라벨이에요"
    @State var text = ""
    @State var placeholder = ""
    @State var lineLimit: Int = 2
       var body: some View {
           VStack(alignment: .leading) {
               Text(label)
                   .font(.bold14)
               TextField(placeholder, text: $text, axis: .vertical)
                  .lineLimit(lineLimit...)
                  .padding()
                  .background(Color(UIColor.systemGray6))
                  .cornerRadius(8)
                  
           }
           .padding()
       }
}


#Preview {
    Textarea()
}

