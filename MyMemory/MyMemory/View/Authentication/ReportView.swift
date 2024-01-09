//
//  ReportView.swift
//  MyMemory
//
//  Created by 김소혜 on 1/4/24.
//

import SwiftUI

struct ReportView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
         
        ZStack {
                VStack{
                    Textarea(label:"신고할 게시글")
                    SelectBox(label: "어떤문제가 있었나요?")
                
                    Textarea(label:"자세히 설명해주세요", placeholder: "내용을 입력하세요.")
                    Spacer()
                }
            }
            .navigationTitle("신고하기")
            .navigationBarBackButtonHidden()
            .navigationBarItems(leading: BackButton())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        
                    } label: {
                        Text("등록하기")
                    }
                }
            }
       
     
        
    }
}

#Preview {
    ReportView()
}
