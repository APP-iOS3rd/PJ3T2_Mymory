//
//  ReportView.swift
//  MyMemory
//
//  Created by 김소혜 on 1/4/24.
//

import SwiftUI

struct ReportView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var showingAlert = false
    @State var memo: Memo
    @State var reportText: String = ""
    var body: some View {
        
        ZStack {
            VStack{
                ReportMemoView(memo: memo, label:"신고할 게시글")
                
                SelectBox(label: "어떤문제가 있었나요?")
                
                Textarea(label:"자세히 설명해주세요", text: $reportText, placeholder: "내용을 입력하세요.")
                
                Button {
                    self.showingAlert.toggle()
                } label: {
                    Text("작성하기")
                }
                .disabled(reportText.isEmpty)
                .alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text("신고가 완료되었습니다."),
                        message: Text("신고 내용은 24시간 이내에 조치됩니다."),
                        dismissButton: .default(Text("확인"), action: {
                            self.presentationMode.wrappedValue.dismiss()
                        })
                    )
                }
                
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
