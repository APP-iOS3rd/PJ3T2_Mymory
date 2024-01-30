//
//  SelectBox.swift
//  MyMemory
//
//  Created by 김소혜 on 1/4/24.
//

import SwiftUI

struct SelectBox: View {
    
    @State var selection: ReportMessage = .first
    @State var label = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text(label)
                .font(.bold14)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            
            ZStack{
                Color(UIColor.systemGray6)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(12)
                
                 
                Picker("choose a...", selection: $selection){
                    ForEach(ReportMessage.allCases, id:\.self) { value in
                        Text(value.localizedName)
                             .tag(value)
                    }
                    .frame(maxWidth: .infinity)
                    .labelsHidden()
                    .padding()
                    
                }
                .accentColor(.black)
                .frame(maxWidth: .infinity, alignment:.leading)
                
            }
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            
        } 
        .padding()
    }
}
#Preview {
    SelectBox()
}
