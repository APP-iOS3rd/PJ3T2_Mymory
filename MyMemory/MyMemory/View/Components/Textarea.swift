//
//  Textarea.swift
//  MyMemory
//
//  Created by 김소혜 on 1/4/24.
//

import SwiftUI

struct Textarea: View {
    @State var label = "label"
    @State var text = ""
    @State var placeholder = ""
    @State var lineLimit: Int = 2
       var body: some View {
           VStack(alignment: .leading) {
               Text(label)
                   .font(.caption2)
               TextField(placeholder, text: $text, axis: .vertical)
                  .lineLimit(lineLimit...)
                  .background(Color("secondary"))
                  .cornerRadius(8)
                  
           }
           .padding()
       }
}


#Preview {
    Textarea()
}

