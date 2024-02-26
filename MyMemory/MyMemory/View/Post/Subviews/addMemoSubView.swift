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
    
    @State var themeSheet: Bool = false
    @State var fontSheet: Bool = false
    @EnvironmentObject var viewModel: PostViewModel
    @ObservedObject var themeManager: ThemeManager = .shared
    @ObservedObject var fontManager: FontManager = .shared
    @State var currentTheme: ThemeType = .system
    @State var currentFont: FontType = .Regular
    
    enum Field {
        case title
        case contents
    }
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: 10){
                HStack(alignment: .bottom){
                    
                    
                    Spacer()
                    VStack(alignment:.trailing) {
                        Text(viewModel.memoShare ? "공유 하기" : "나만 보기")
                            .font(.regular12)
                            .foregroundStyle(Color.textColor)
                        Toggle(
                            isOn: $viewModel.memoShare) {
                                // 토글 내부에 아무 것도 추가하지 않습니다.
                            } //: Toggle
                            .toggleStyle(SwitchToggleStyle(tint: Color.blue))
                    }
                    .aspectRatio(contentMode: .fit)
                } // HStack
                
                VStack {
                    TextField("제목을 입력해주세요", text: $viewModel.memoTitle)
                        .font(.userMainTextFont(fontType: currentFont, baseSize: 20))
                        .focused($focusedField, equals: .title)
    
                    // TexEditor 여러줄 - 긴글 의 text 를 입력할때 사용
                    TextEditor(text: $viewModel.memoContents)
                        .padding(.horizontal, -4)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: minHeight, maxHeight: maxHeight)
                        .font(.userMainTextFont(fontType: currentFont, baseSize: 16))
                        .focused($focusedField, equals: .contents)
                        .background(
                            Text(viewModel.memoContents.isEmpty ? "본문을 입력해주세요." : "")
                                .foregroundStyle(Color.placeHolder)
                                .font(.userMainTextFont(fontType: currentFont, baseSize: 16))
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                                .padding(.vertical, 8)
                            ,alignment: .topLeading
                        )
                    // 최대 1000자 까지만 허용
                        .onChange(of: viewModel.memoContents) { _, newValue in
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
                        .toolbar {
                            ToolbarItem(placement: .keyboard) {
                                // 키보드 위에 툴바를 추가합니다.
                                if focusedField == .contents {
                                    HStack {
                                        Spacer()
                                        Button{
                                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                                                viewModel.scrollTag = 1
                                            }
                                        } label: {
                                            Text(viewModel.memoContents.isEmpty ? "닫기": "저장")
                                                .font(.semibold12)
                                        }
                                        .padding(.trailing, 15)
                                    }
                                }
                            }
                        }
                    
                }
                .onSubmit {
                    switch focusedField {
                    case .title:
                        focusedField = .contents
                    default:
                        print("Done")
                    }
                }
                .padding()
                .background(currentTheme.bgColor)
                .foregroundStyle(currentTheme.textColor)
                .onAppear {
                    self.currentTheme = viewModel.memoTheme
                    self.currentFont = viewModel.memoFont
                    
                }
                .onChange(of: viewModel.memoTheme) { _, newValue in
                    self.currentTheme = newValue
                   
                }
                .onChange(of: viewModel.memoFont) { _, newValue in
                    self.currentFont = newValue
                }
                .ignoresSafeArea(.keyboard, edges: .bottom) // 키보드가 올라온 경우 뷰가 키보드를 침범하지 않도록 합니다.
                
                
              
              
          
                HStack(spacing: 4) {
                    // 메모지 선택 Sheet
                    Button {
                        themeSheet.toggle()
                    } label : {
                        Text("메모지 선택")
                    }
                    .buttonStyle(RoundedRect.standard)
                    .padding(.bottom, 20)
                    .sheet (
                        isPresented: $themeSheet,
                        onDismiss: {
                            // 기본 값으로 설정된 메모지로 가져오고, 선택된 값이 없다면 .system모드로 불러옴.
                            // sheet 가 닫혔을 때 action
                            viewModel.memoTheme = themeManager.getTheme(themeData: viewModel.memoTheme)
                        },
                        content: {
                            MemoThemeView(currentTheme: $viewModel.memoTheme)
                                .environmentObject(viewModel)
                        }
                    )
                    
                    // 메모지 선택 Sheet
                    Button {
                        fontSheet.toggle()
                    } label : {
                        Text("폰트 선택")
                    }
                    .buttonStyle(RoundedRect.standard)
                    .padding(.bottom, 20)
                    .sheet (
                        isPresented: $fontSheet,
                        onDismiss: {
                            // 기본 값으로 설정된 메모지로 가져오고, 선택된 값이 없다면 .system모드로 불러옴.
                            // sheet 가 닫혔을 때 action

                            viewModel.memoFont = fontManager.getFont(fontData: viewModel.memoFont)
                        },
                        content: {
                            FontView(currentFont: $viewModel.memoFont)
                                .environmentObject(viewModel)
                        }
                    )
                   
                }
                
               
           
                
                
            }
        }
        .padding(.bottom)
    }
}

//#Preview {
//    addMemoSubView()
//}
