//
//  PostView2.swift
//  MyMemory
//
//  Created by 김소혜 on 1/18/24.
//


import SwiftUI
import MapKit
import Combine
import _PhotosUI_SwiftUI

struct PostView2: View {
    
    @StateObject var viewModel: PostViewModel = PostViewModel()
    
    //viewModel로 전달할 값 모음
    @State var memoTitle: String = ""
    @State var memoContents: String = ""
    @State var memoAddressText: String = ""
    @State var memoSelectedImageItems: [PhotosPickerItem] = []
    @State private var memoSelectedTags: [String] = []
    @State var memoShare: Bool = false
    
    
    // 추후 사용자 위치 값 가져오기
    var userCoordinate = CLLocationCoordinate2D(latitude: 37.5125, longitude: 127.102778)
    
    let minHeight: CGFloat = 250
    let maxHeight: CGFloat = 400
    let maxCharacterCount: Int = 1000
    
    // property
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading){
                
                // 💁 메모하기 View 굳이 분리할 필요가 없어 보임
                Group {
                    VStack(alignment: .leading, spacing: 10) {
                        
                        TextField("제목을 입력해주세요", text: $memoTitle)
                            .textFieldStyle(.roundedBorder)
                        
                        // TexEditor 여러줄 - 긴글 의 text 를 입력할때 사용
                        TextEditor(text: $memoContents)
                            .frame(minHeight: minHeight, maxHeight: maxHeight)
                            .cornerRadius(10)
                            .colorMultiply(Color.gray.opacity(0.2))
                            .foregroundColor(.black)
                        // 최대 1000자 까지만 허용
                            .onChange(of: memoContents) { newValue in
                                // Limit text input to maxCharacterCount
                                if newValue.count > maxCharacterCount {
                                    memoContents = String(newValue.prefix(maxCharacterCount))
                                }
                            }// Just는 Combine 프레임워크에서 제공하는 publisher 중 하나이며, SwiftUI에서 특정 이벤트에 반응하거나 값을 수신하기 위해 사용됩니다. 1000를 넘으면 입력을 더이상 할 수 없습니다.
                            .onReceive(Just(memoContents)) { _ in
                                // Disable further input if the character count exceeds maxCharacterCount
                                if memoContents.count > maxCharacterCount {
                                    memoContents = String(memoContents.prefix(maxCharacterCount))
                                }
                            }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom)
                
                // 💁 Tag 선택 View
                Group {
                    SelectTagView(memoSelectedTags: $memoSelectedTags)
                }
                .padding(.bottom)
                //💁 사진 등록하기 View
                
                Group {
                    VStack(alignment: .leading, spacing: 10){
                        HStack {
                            Text("사진 등록하기")
                                .font(.bold20)
                            
                            Spacer()
                            
                        } //:HSTACK
//                        SelectPhotos(memoSelectedImageItems: $memoSelectedImageItems)
                    }//:VSTACK
                }
                .padding(.horizontal, 20)
                .padding(.bottom)
                
                Button(action: {
                    // 사용자 입력값을 뷰모델에 저장
                    
//                    viewModel.saveMemo(userCoordinate: userCoordinate,
//                                       memoShare: memoShare,
//                                       memoTitle: memoTitle,
//                                       memoContents: memoContents,
//                                       memoAddressText: memoAddressText,
//                                       memoSelectedImageItems: memoSelectedImageItems,
//                                       memoSelectedTags: memoSelectedTags)
                    
                    // 임시로 로직 구현전 뒤로가기
                    // 메인뷰 보여주기
                }, label: {
                    Text("작성완료")
                        .frame(maxWidth: .infinity)
                })
                .buttonStyle(RoundedRect.primary)
                .padding(.horizontal)
                .disabled(memoTitle.isEmpty || memoContents.isEmpty || userCoordinate.latitude == 0)
                .tint(memoTitle.isEmpty || memoContents.isEmpty || userCoordinate.latitude == 0 ? Color(.systemGray5) : Color.blue)
                .padding(.bottom)
                
                Spacer()
            } //:VSTACK
    
        } //: ScrollView
       //.toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            // 뒤로 가기 동작을 구현합니다
            // 예: PresentationMode를 사용하여 화면을 닫습니다
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.blue)
        })
    }
    
}

#Preview {
    PostView2()
}
