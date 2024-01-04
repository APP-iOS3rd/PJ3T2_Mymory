//
//  SelectBox.swift
//  MyMemory
//
//  Created by 김소혜 on 1/4/24.
//

import SwiftUI

enum ReportMessage: String, Identifiable, CaseIterable{
    case first = "사회/정치적으로 부적절한 메시지가 있어요"
    case second = "욕설/혐오발언을 사용했어요"
    case third = "기타 신고사항"
    
    var id: Self { self }
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}


struct SelectBox: View {
    
    @State var selection: ReportMessage = .first
    @State var label = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text(label)
                .font(.bold14)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            
            ZStack{
                Color("secondary")
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
