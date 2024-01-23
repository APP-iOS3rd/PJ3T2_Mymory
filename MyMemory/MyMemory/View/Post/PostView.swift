//
//  MemoView.swift
//  MyMemory
//
//  Created by 정정욱 on 1/10/24.
//

import SwiftUI
import MapKit
import Combine
import _PhotosUI_SwiftUI
import UIKit



struct PostView: View {
    @Binding var selected: Int
    @State var draw = true
    @StateObject var viewModel: PostViewModel = PostViewModel()
    let minHeight: CGFloat = 250
    let maxHeight: CGFloat = 400
    let maxCharacterCount: Int = 1000
    @State var handler = LocationsHandler.shared
    @State var isEdit: Bool = false
    var memo: Memo = Memo(userUid: "123", title: "ggg", description: "gggg", address: "서울시 @@구 @@동", tags: ["ggg", "Ggggg"], images: [], isPublic: false, date: Date().timeIntervalSince1970 - 1300, location: Location(latitude: 37.402101, longitude: 127.108478), likeCount: 10, memoImageUUIDs: [""])
 
    // 수정버튼 타고 왔을때 구분위한 Bool 타입

    
    // property
    @Environment(\.presentationMode) var presentationMode
    @State var centerLocation: CLLocation?
    var body: some View {
        ZStack{
            ScrollView{
                VStack(alignment: .leading){
                    
                    //💁 상단 MapView
                    KakaoMapSimple(draw: $draw,
                                   userLocation: $handler.location,
                                   userDirection: $handler.heading,
                                   centerLocation: $centerLocation)
                    .onAppear(perform: {
                        self.draw = true
                    }).onDisappear(perform: {
                        self.draw = false
                    }).frame(maxWidth: .infinity, maxHeight: .infinity)
                        .environmentObject(viewModel)
                        .frame(height: UIScreen.main.bounds.size.height * 0.2) // 화면 높이의 30%로 설정
                        .background(.ultraThinMaterial)
                        .padding(.bottom)
                        .padding(.horizontal)
                    
                    //💁 사진 등록하기 View
                    Group {
                        VStack(alignment: .leading, spacing: 10){
                            HStack {
                                Text("사진 등록하기")
                                    .font(.bold20)
                                
                                Spacer()
                                
                            } //:HSTACK
                            SelectPhotos(isEdit: $isEdit, memoSelectedImageData: $viewModel.memoSelectedImageData)
                            
                        }//:VSTACK
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom)
                    
                    
                    // 💁 주소찾기 View
                    Group {
                        FindAddressView(memoAddressText: $viewModel.memoAddressText)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 25)
                    // 💁 메모하기 View 굳이 분리할 필요가 없어 보임
                    Group {
                        VStack(alignment: .leading, spacing: 10){
                            ZStack(alignment: .leading){
                                Text("제목, 기록할 메모 입력")
                                    .font(.bold20)
                                    .bold()
                                
                                
                                Toggle(
                                    isOn: $viewModel.memoShare) {
                                        // 토글 내부에 아무 것도 추가하지 않습니다.
                                    } //: Toggle
                                    .toggleStyle(SwitchToggleStyle(tint: Color.blue))
                                    .overlay {
                                        Text(viewModel.memoShare ? "공유 하기" : "나만 보기")
                                        //.foregroundColor(Color(.systemGray3))
                                            .font(.caption)
                                        
                                            .offset(CGSize(width:
                                                            153.0, height: -25.0))
                                    }
                            }// HStack
                            
                            
                            TextField("제목을 입력해주세요", text: $viewModel.memoTitle)
                                .textFieldStyle(.roundedBorder)
                           
                            // TexEditor 여러줄 - 긴글 의 text 를 입력할때 사용
                            TextEditor(text: $viewModel.memoContents)
                                .frame(minHeight: minHeight, maxHeight: maxHeight)
                                .cornerRadius(10)
                                .colorMultiply(Color.gray.opacity(0.2))
                                .foregroundColor(.black)
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
                    .padding(.horizontal, 20)
                    .padding(.bottom)
                    
                    // 💁 Tag 선택 View
                    Group {
                        SelectTagView(memoSelectedTags: $viewModel.memoSelectedTags)
                    }
                    .padding(.bottom)
                    
                    Button(action: {
                        Task {
                            if isEdit {
                                // 수정 모드일 때는 editMemo 호출
                                await viewModel.editMemo(memo: memo)
                                presentationMode.wrappedValue.dismiss()
                            } else {
                                // 수정 모드가 아닐 때는 saveMemo 호출
                                await viewModel.saveMemo()
                            }
                        }
                    }, label: {
                        Text(isEdit ? "수정완료" : "작성완료")
                            .frame(maxWidth: .infinity)
                    })
                    
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)
                    .disabled(viewModel.memoTitle.isEmpty || viewModel.memoContents.isEmpty  )
                    .tint(viewModel.memoTitle.isEmpty || viewModel.memoContents.isEmpty ? Color(.systemGray5) : Color.blue)
                    .padding(.bottom)
                    
                    Spacer()
                } //:VSTACK
                
            } //: ScrollView
        }
        .customNavigationBar(
            centerView: {
                Group {
                    if isEdit {
                        Text("메모 수정")
                    } else {
                        Text("메모 등록")
                    }
                }
            },
            leftView: {
                Group {
                    if isEdit {
                      //  BackButton()
                        Button(action: {
                            Task.init {
                                // 휴지통 버튼을 눌렀을 때의 동작을 구현합니다
                                // 예: 삭제 확인 대화상자를 표시합니다
                                print("Trash button tapped!")
                                await viewModel.deleteMemo(memo: memo)
                                DispatchQueue.main.async {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    } else {
                        EmptyView()
                    }
                }
                
            },
            rightView: {
                Group {
                    if isEdit { CloseButton() }
                    else {
                        Button {
                            self.selected = 0
                        } label: {
                            HStack(spacing: 0){
                                Image(systemName: "multiply")
                                    .resizable()
                                    .frame(width: 18, height: 18)
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.deepGray)
                                //                Text("이전")
                            }
                        }
                    }
                }
            },
            backgroundColor: .white
        )
        .toolbar(.hidden, for: .tabBar)

        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .onAppear {
            
            if isEdit {
                viewModel.fetchEditMemo(memo: memo)
            }
            
        }

    }
        
}
 


//struct MemoView_Previews: PreviewProvider {
//    static var previews: some View {
//        PostView()
//    }
//}
//
