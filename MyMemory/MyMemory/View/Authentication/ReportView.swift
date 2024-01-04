//
//  ReportView.swift
//  MyMemory
//
//  Created by 김소혜 on 1/4/24.
//

import SwiftUI

struct ReportView: View {
    var body: some View {
        
        NavigationView {
            ZStack {
                VStack{
                    Textarea(label:"메모 제목")
                    Textarea(label:"어떤 문제가 있나요?",placeholder: "사회/정치적으로 부적절한 메시지가 있어요.")
                    Textarea(label:"자세히 설명해주세요")
                    Spacer()
                }
            }
            .navigationTitle("신고하기")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("이전"){
                        
                    }
                    
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("등록하기"){
                        
                    }
                }
            }
        }
     
        
    }
}

#Preview {
    ReportView()
}
