//
//  ReportView.swift
//  MyMemory
//
//  Created by 김소혜 on 1/4/24.
//

import SwiftUI

struct ReportView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var viewModel: ReportViewModel = .init()
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var reportText: String = ""
    @State private var reportMessageType: ReportMessage = .first
    @Binding var memo: Memo
    var body: some View {

        ZStack {
            VStack{
                ReportMemoView(memo: memo, label:"신고할 게시글")
                
                SelectBox(selection: $reportMessageType, label: "어떤문제가 있었나요?")
                
                Textarea(label:"자세히 설명해주세요", text: $reportText, placeholder: "내용을 입력하세요.")
                
                Button {
                    Task {
                        let result = await viewModel.fetchReport(memo: memo,
                                                                 type: reportMessageType.rawValue,
                                                                 reason: reportText)
                        
                        if let errorMessage = result {
                            alertTitle = "신고 실패"
                            self.alertMessage = errorMessage
                        } else {
                            alertTitle = "신고 완료"
                            self.alertMessage = "신고 내용은 24시간 이내에 조치됩니다."
                        }
                        self.showingAlert = true
                    }
                } label: {
                    Text("작성하기")
                }
                .disabled(reportText.isEmpty)
                .alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text(alertTitle),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("확인"),
                        action: {
                            if alertTitle == "신고 완료" {
                                presentationMode.wrappedValue.dismiss()
                            }
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
