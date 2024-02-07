//
//  addMemoSubView.swift
//  MyMemory
//
//  Created by 김태훈 on 1/23/24.
//

import SwiftUI
import Combine
struct addMemoSubView: View {
    let minHeight: CGFloat = 250
    let maxHeight: CGFloat = 400
    let maxCharacterCount: Int = 1000
    let placeholder: String = "본문을 입력해주세요."
    
    @EnvironmentObject var viewModel: PostViewModel
    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: 10){
                HStack(alignment: .bottom){

                    
                    Spacer()
                    VStack(alignment:.trailing) {
                        Text(viewModel.memoShare ? "공유 하기" : "나만 보기")
                            .font(.regular12)
                        Toggle(
                            isOn: $viewModel.memoShare) {
                                // 토글 내부에 아무 것도 추가하지 않습니다.
                            } //: Toggle
                            .toggleStyle(SwitchToggleStyle(tint: Color.blue))
                    }
                    .aspectRatio(contentMode: .fit)
                } // HStack
                
                
                TextField("제목을 입력해주세요", text: $viewModel.memoTitle)
                    .font(.userMainTextFont(baseSize: 20))

                // TexEditor 여러줄 - 긴글 의 text 를 입력할때 사용
                TextEditor(text: $viewModel.memoContents)
                    .padding(.horizontal, -4)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: minHeight, maxHeight: maxHeight)
                    .foregroundColor(.textColor)
                    .font(.userMainTextFont(baseSize: 16))
                    .background(
                        Text(viewModel.memoContents.isEmpty ? "본문을 입력해주세요." : "")
                            .foregroundStyle(Color.placeHolder)
                            .font(.userMainTextFont(baseSize: 16))
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .padding(.vertical, 8)
                        ,alignment: .topLeading
                    )
                // 최대 1000자 까지만 허용
                    .onChange(of: viewModel.memoContents) { newValue in
                        // Limit text input to maxCharacterCount
                        if newValue.count > maxCharacterCount {
                            viewModel.memoContents = String(newValue.prefix(maxCharacterCount))
                        }
                    }// Just는 Combine 프레임워크에서 제공하는 publisher 중 하나이며, SwiftUI에서 특정 이벤트에 반응하거나 값을 수신하기 위해 사용됩니다. 1000를 넘으면 입력을 더이상 할 수 없습니다.
                    .onReceive(Just(viewModel.memoContents)) { _ in
                        // Disable further input if the character count exceeds maxCharacterCount
                        if viewModel.memoContents.count > maxCharacterCount {
                            viewModel.memoContents = String(viewModel.memoContents.prefix(maxCharacterCount))
                        }
                    }
            }
        }
        .padding(.bottom)
    }
}

#Preview {
    addMemoSubView()
}
