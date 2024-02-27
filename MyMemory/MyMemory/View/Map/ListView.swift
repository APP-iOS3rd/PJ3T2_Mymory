//
//  ListView.swift
//  MyMemory
//
//  Created by 김소혜 on 2/23/24.
//

import SwiftUI

struct ListView: View {
    @EnvironmentObject var viewModel: MainMapViewModel
    @Binding var sortDistance: Bool
    @Environment(\.dismiss) private var dismiss
    @State var presentLoginAlert: Bool = false
    @State var filterSheet: Bool = false
    @State var isFirst = true
    @State var selectedIndex = 0
    //MARK: - Gesture 프로퍼티
    @GestureState private var translation: CGSize = .zero
    @State var selectedUser: Profile? = nil
    @State var currentAppearingMemo: Memo? = nil {
        didSet {
            if let memo = currentAppearingMemo {
                viewModel.memoDidSelect(memo: memo)
            }
        }
    }
    let unAuthorized: (Bool) -> ()
    var operationQueue = OperationQueue()
    private var swipe: some Gesture {
        DragGesture()
            .updating($translation) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                let swipeDistance = value.translation.width
                //오른쪽
                if swipeDistance > (UIScreen.main.bounds.width)/3.0 {
                    if selectedIndex == 1 {
                        self.selectedIndex = 0
                    }
                    //왼쪽
                } else if swipeDistance < (UIScreen.main.bounds.width)/3.0 * -1 {
                    if selectedIndex == 0 {
                        self.selectedIndex = 1
                    }
                }
            }
    }
    var body: some View {
        NavigationStack {
            VStack {
                
                VStack {
                    HStack{
                        
                        Button{
                            filterSheet.toggle()
                        } label: {
                            FilterButton(buttonName: .constant(viewModel.filterList.isEmpty ? "전체 메뉴" : viewModel.filterList.combinedWithComma))
                        }
                        .buttonStyle(viewModel.filterList.isEmpty ? RoundedRect.standard : RoundedRect.selected)
                        
                        Button {
                            // 거리순 - 최근 등록순
                            self.sortDistance.toggle()
                            viewModel.sortByDistance(sortDistance)
                        } label: {
                            FilterButton(
                                imageName: "arrow.left.arrow.right",
                                buttonName: sortDistance ?
                                    .constant("거리순보기") : .constant("최근 등록순 보기")
                            )
                        }
                        .buttonStyle(RoundedRect.standard)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    //.padding(.top, 20)
                    ScrollView(.vertical, showsIndicators: false){
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.filterList.isEmpty ? Array(zip($viewModel.memoList.indices, $viewModel.memoList)) : Array(zip($viewModel.filteredMemoList.indices, $viewModel.filteredMemoList)), id: \.0 ) { index, item in
                                NavigationLink {
                                    DetailView(memo: item,
                                               isVisble: .constant(true),
                                               memos: viewModel.filterList.isEmpty ? $viewModel.memoList : $viewModel.filteredMemoList,
                                               selectedMemoIndex: index
                                    )
                                } label: {
                                    
                                    MemoCell(
                                        location: $viewModel.location,
                                        selectedMemoIndex: index,
                                        memo: item,
                                        memos: viewModel.filterList.isEmpty ? $viewModel.memoList : $viewModel.filteredMemoList
                                    ) { res in
                                        if res {
                                            presentLoginAlert.toggle()
                                        }
                                    }
                                    .id(item.id)
                                    .environmentObject(viewModel)
                                    .onTapGesture {
                                        viewModel.memoDidSelect(memo: item.wrappedValue)
                                    }
                                   // .frame(width: UIScreen.main.bounds.size.width)
                                    .padding(.horizontal, 12)
                                    .padding(.bottom, 12)
                                    .background {
                                        GeometryReader { geometry in
                                            Color.clear
                                                .onAppear {
                                                    let minx = geometry.frame(in: .global).minX
                                                    let scrollViewWidth = geometry.frame(in: .global).width
                                                    let contentsWidth = geometry.frame(in: .local).width
                                                    var idx = index
                                                    let oldid = viewModel.selectedMemoId
                                                    let newid = item.id
                                                }
                                                .onChange(of: geometry.frame(in: .global).minX) { old, minX in
                                                    if minX < 180 && minX > -10 {
                                                        operationQueue.cancelAllOperations()
                                                        operationQueue.addOperation{
                                                            DispatchQueue.main.async{
                                                                if item.id != currentAppearingMemo?.id {
                                                                    currentAppearingMemo = item.wrappedValue
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                        }
                                    }
                                    
//                                    if !viewModel.memoWriterList.isEmpty {
//                                         
//                                        MemoCard(memo: item,
//                                                 isVisible: true,
//                                                 profile: viewModel.filterList.isEmpty ? $viewModel.memoWriterList[index] : $viewModel.filteredProfilList[index]
//                                        ) { actions in
//                                            switch actions {
//                                            case .follow:
//                                                viewModel.refreshMemoProfiles()
//                                            case .like:
//                                                viewModel.refreshMemos()
//                                                print("liked!")
//                                            case .unAuthorized:
//                                                presentLoginAlert.toggle()
//                                            case .navigate(profile: let profile):
//                                                selectedUser = profile
//                                                print("Navigate to \(profile.name)'s profile")
//                                            default :
//                                                print("selected\(actions)")
//                                            }
//                                        }.frame(maxWidth: .infinity)
//                                    }
//                                    
                                    
                                }
                                
                            }
                            
                        }.refreshable {
                            viewModel.fetchMemos()
                            viewModel.fetchMemoProfiles()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 24)
                        .gesture(swipe)
                    }
                    
                }
                .sheet(isPresented: $filterSheet, content: {
                    FilterListView(filteredList: $viewModel.filterList)
                        .presentationDetents([.medium])
                })
                .overlay(content: {
                    if viewModel.isLoading {
                        LoadingView()
                    }
                })
                //.padding()
                    
               
            }
            .overlay(
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "map")
                        Text("지도뷰")
                    }
                }
                    .buttonStyle(Pill.secondary)
                    .frame(maxWidth: .infinity, maxHeight : .infinity, alignment: .bottomTrailing)
                    .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                
            )
            .background(Color.bgColor)
            .navigationDestination(item: $selectedUser){ profile in
                let user = profile.toUser
                if isFirst {
                    OtherUserProfileView(memoCreator: user)
//                        .environmentObject(otherUserViewModel)
                }
            }
            .onAppear{
                AuthService.shared.fetchUser()
                viewModel.refreshMemoProfiles()
            }
            .moahAlert(isPresented: $presentLoginAlert) {
                MoahAlertView(message: "로그인 후에 사용 가능한 기능입니다.\n로그인 하시겠습니까?",
                              firstBtn: MoahAlertButtonView(type: .CUSTOM(msg: "둘러보기", color: .accentColor), isPresented: $presentLoginAlert, action: {
                }),
                              secondBtn: MoahAlertButtonView(type: .CUSTOM(msg: "로그인 하기"), isPresented: $presentLoginAlert, action: {
                    self.dismiss()
                    
                    unAuthorized(true)
                })
                )
            }
        }
    }
}

