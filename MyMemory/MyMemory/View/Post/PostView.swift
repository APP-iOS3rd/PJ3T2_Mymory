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
    @State var presentLocationAlert: Bool = false
    @State var draw = true
    @StateObject var viewModel: PostViewModel = PostViewModel()
    
    let minHeight: CGFloat = 250
    let maxHeight: CGFloat = 400
    let maxCharacterCount: Int = 1000
    
    @State var isEdit: Bool = false
    @State var selectedItemsCounts: Int = 0
    var memo: Memo = Memo(userUid: "123", title: "ggg", description: "gggg", address: "서울시 @@구 @@동", tags: ["ggg", "Ggggg"], imagesURL: [], isPublic: false,isPinned: true, date: Date().timeIntervalSince1970 - 1300,  location : Location(latitude: 37.402101, longitude: 127.108478), likeCount: 10, memoImageUUIDs: [""], memoTheme: .atom)
    // 수정버튼 타고 왔을때 구분위한 Bool 타입
    
    // property
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView{
                    VStack(alignment: .leading){
                        //💁 메모하기 View, 사진 등록하기 View
                        Group {
                            addMemoSubView()
                                .environmentObject(viewModel)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom)
                        
                        // 💁 Tag 선택 View
                        Group {
                            SelectTagView(memoSelectedTags: $viewModel.memoSelectedTags)
                                .frame(maxWidth: .infinity)
                                .aspectRatio(contentMode: .fit)
                        }
                        
                        .padding(.bottom)
                        .buttonStyle(.borderedProminent)
                        .padding(.horizontal, 20)
                        .tint(viewModel.memoTitle.isEmpty || viewModel.memoContents.isEmpty ? Color(.systemGray5) : Color.blue)
                        .padding(.bottom, 20)
                        
                        // 💁 사진 선택 View
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
                        .padding(.bottom, 100)
                        .onReceive(viewModel.dismissPublisher) { toggle in
                            if toggle {
                                dismiss()
                            }
                        }
                        Spacer()
                        
                    } //:VSTACK
                    
                } //: ScrollView
                
                
                // 주소찾기 View: 하단 고정
                VStack {
                    Spacer()
                    PostViewFooter()
                        .environmentObject(viewModel)
                        .disabled(isEdit)
                    
                }.edgesIgnoringSafeArea(.bottom)
            } //: ZStack
            //        .navigationBarHidden(false)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(isEdit ? "메모 수정" : "메모 등록")
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    if isEdit {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Back")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isEdit {
                        HStack(spacing: 20) {
                            Button(action: {
                                Task.init {
                                    print("휴지통 버튼이 탭되었습니다!")
                                    await viewModel.deleteMemo(memo: memo)
                                    DispatchQueue.main.async {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            
                            Button(action: {
                                viewModel.loading = true
                                LoadingManager.shared.phase = .loading
                                viewModel.editMemo(memo: memo)
                                isEdit = false
                            }, label: {
                                Text("수정")
                            })
                            .disabled(viewModel.memoTitle.isEmpty || viewModel.memoContents.isEmpty || viewModel.userCoordinate == nil)
                        }
                    } else {
                        Button(action: {
                            viewModel.loading = true
                            LoadingManager.shared.phase = .loading
                            viewModel.saveMemo()
                        }) {
                            Text("저장")
                        }
                        .disabled(viewModel.memoTitle.isEmpty || viewModel.memoContents.isEmpty || viewModel.userCoordinate == nil)
                    }
                }
            }
            
        }
        
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .onAppear {
            if let useruid = UserDefaults.standard.string(forKey: "userId") {
                AuthService.shared.fetchUser()
                presentLoginAlert = false
                switch CLLocationManager.authorizationStatus() {
                case .authorizedAlways, .authorizedWhenInUse:
                    print("승인")
                case .notDetermined, .restricted, .denied:
                    presentLocationAlert.toggle()
                @unknown default:
                    print("승인")
                }
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
            LoginView().environmentObject(AuthViewModel())
        }
        .onReceive(viewModel.dismissPublisher) { toggle in
            if toggle {
                if isEdit {
                    dismiss()
                } else {
                    self.selected = 0
                }
            }
        }
        .moahAlert(isPresented: $presentLocationAlert, moahAlert: {
            MoahAlertView(message: "현재 위치를 찾을 수 없어요. 위치서비스를 켜 주세요.", firstBtn: MoahAlertButtonView(type: .CANCEL, isPresented: $presentLocationAlert, action: {
                self.selected = 0
            }), secondBtn: MoahAlertButtonView(type: .SETTING, isPresented: $presentLocationAlert, action: {
                self.selected = 0
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }))
        })
        
        
        
        .overlay( content: {
            if viewModel.loading {
                LoadingView()
            }
        })
    }
}



//struct MemoView_Previews: PreviewProvider {
//    static var previews: some View {
//        PostView(selected: .constant(1))
//    }
//}
