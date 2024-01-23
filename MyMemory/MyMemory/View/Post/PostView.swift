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
                // 💁 메모하기 View 굳이 분리할 필요가 없어 보임

                addMemoSubView()
                    .environmentObject(viewModel)
                
                //💁 사진 등록하기 View
                Group {
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
        .overlay(content: {
            if LoadingManager.shared.phase == .loading {
                LoadingView()
            }
        })
        //.toolbar(.hidden, for: .tabBar)
        .onTapGesture {
            UIApplication.shared.endEditing()
        }

        .onAppear {
            
            if isEdit {
                viewModel.fetchEditMemo(memo: memo)
            }
            
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
                        BackButton()
                    } else {
                        EmptyView()
                    }
                }
                
            },
            rightView: {
                CloseButton()
            },
            backgroundColor: .white
        )        

    }
}




struct MemoView_Previews: PreviewProvider {
    static var previews: some View {
        PostView()
    }
}
