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
    @State var presentLoginAlert: Bool = false
    @State var presentLoginView: Bool = false
    @State var draw = true
    @StateObject var viewModel: PostViewModel = PostViewModel()
    
    let minHeight: CGFloat = 250
    let maxHeight: CGFloat = 400
    let maxCharacterCount: Int = 1000
    
    @State var isEdit: Bool = false
    @State var selectedItemsCounts: Int = 0
    var memo: Memo = Memo(userUid: "123", title: "ggg", description: "gggg", address: "서울시 @@구 @@동", tags: ["ggg", "Ggggg"], images: [], isPublic: false, date: Date().timeIntervalSince1970 - 1300, location: Location(latitude: 37.402101, longitude: 127.108478), likeCount: 10, memoImageUUIDs: [""])
    
    // 수정버튼 타고 왔을때 구분위한 Bool 타입

    
    // property
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView{
            VStack(alignment: .leading){
                
                //💁 메모하기 View, 사진 등록하기 View
                Group {
                    addMemoSubView()
                        .environmentObject(viewModel)
                    
                    
                    VStack(alignment: .leading, spacing: 10){
                        HStack {
                            Text("사진 등록하기")
                                .font(.bold20)
                            
                            Spacer()
                            
                        } //:HSTACK
                        SelectPhotos(isEdit: $isEdit, memoSelectedImageData: $viewModel.memoSelectedImageData, selectedItemsCounts: $viewModel.selectedItemsCounts)
                        
                    }//:VSTACK
                }
                .padding(.horizontal, 20)
                .padding(.bottom)
                .onReceive(viewModel.dismissPublisher) { toggle in
                    if toggle {
                        dismiss()
                    }
                }
                
               
                // 💁 Tag 선택 View
                Group {
                    SelectTagView(memoSelectedTags: $viewModel.memoSelectedTags)
                }
                .padding(.bottom)
                
                // 💁 주소찾기 View
                Group {
                    PostViewFooter()
                        .environmentObject(viewModel)
                }
                .padding(.bottom, 25)
    
                Button(action: {
                    Task {
                        LoadingManager.shared.phase = .loading
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
        .toolbar(.hidden, for: .tabBar)
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        

        .onAppear {
            if let useruid = UserDefaults.standard.string(forKey: "userId") {
                presentLoginAlert = false
            } else {
                presentLoginAlert = true
            }
            if isEdit {
                viewModel.fetchEditMemo(memo: memo)
            }
            
        }
        .alert("로그인 후에 사용 가능한 기능입니다.\n로그인 하시겠습니까?", isPresented: $presentLoginAlert) {
            Button("로그인 하기", role: .destructive) {
                self.presentLoginView = true
            }
            Button("둘러보기", role: .cancel) {
                self.selected = 0
            }
        }
        .fullScreenCover(isPresented: $presentLoginView) {
            LoginView()
        }
        .onReceive(viewModel.dismissPublisher) { toggle in
            if toggle {
                dismiss()
            }
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
                        CloseButton()
                    } else {
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
            rightView: {
                Group {
                    if isEdit {
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
                    }
                }
                
            }, 
            backgroundColor: .bgColor
        )
    }
}




struct MemoView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(selected: .constant(1))
    }
}
