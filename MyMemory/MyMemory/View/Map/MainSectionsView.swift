//
//  MainSectionsView.swift
//  MyMemory
//
//  Created by 이명섭 on 2/1/24.
//

import SwiftUI

struct MainSectionsView: View {
    @EnvironmentObject var viewModel: MainMapViewModel
    @Binding var sortDistance: Bool
    @Environment(\.dismiss) private var dismiss
    @State var filterSheet: Bool = false
    
    @State var selectedIndex = 0
    var body: some View {
        NavigationStack {
            VStack {
                MenuTabBar(
                    menus: [MenuTabModel(index: 0, image: "list.bullet.below.rectangle"), MenuTabModel(index: 1, image: "newspaper")],
                    selectedIndex: $selectedIndex,
                    fullWidth: UIScreen.main.bounds.width,
                    spacing: 50,
                    horizontalInset: 91.5)
                
                switch selectedIndex {
                case 0:
                    
                    VStack {
                        ZStack {
                            
                            Color.bgColor
                                .ignoresSafeArea()
                            
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
                                }.padding(.top, 20)
                                
                                ScrollView(.vertical, showsIndicators: false){
                                    
                                    VStack(spacing: 12) {
                                        ForEach(viewModel.filterList.isEmpty ? $viewModel.memoList : $viewModel.filteredMemoList) { item in
                                            NavigationLink {
                                                //                                                MemoDetailView(memo: item)
                                                DetailView(memo: item, isVisble: .constant(true))
                                            } label: {
                                                MemoCard(memo: item, isVisible: true)
                                            }
            
                                        }
                                        
                                    }
                                    
                                }.refreshable {
                                    viewModel.fetchMemos()
                                }
                            }
                            .padding(.horizontal, 20)
                            
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
                    }
                    .sheet(isPresented: $filterSheet, content: {
                        FileterListView(filteredList: $viewModel.filterList)
                            .presentationDetents([.medium])
                    })
                    .overlay(content: {
                        if viewModel.isLoading {
                            LoadingView()
                        }
                    })
                    //.padding()
                    
                default:
                    CommunityView()
                }
            }
            .background(Color.bgColor)
        }
    }
}

