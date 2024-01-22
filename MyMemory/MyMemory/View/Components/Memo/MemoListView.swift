//
//  MemoListView.swift
//  MyMemory
//
//  Created by 김소혜 on 1/15/24.
//

import SwiftUI

struct MemoListView: View {
    
    @Binding var sortDistance: Bool
    @Environment(\.dismiss) private var dismiss
    @State var filterSheet: Bool = false
    @EnvironmentObject var viewModel: MainMapViewModel
    var body: some View {
        ZStack {
            
            Color.lightGray
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
                }
                
                ScrollView(.vertical, showsIndicators: false){
                    
                    VStack(spacing: 12) {
                        ForEach(viewModel.filterList.isEmpty ? viewModel.memoList : viewModel.filteredMemoList) { item in
                            
                            MemoCell(
                                isVisible: true,
                                isDark: false,
                                location: $viewModel.location,
                                memo: item)
                        }
                       
                    }
                    
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
        .sheet(isPresented: $filterSheet, content: {
            FileterListView(filteredList: $viewModel.filterList)
                .presentationDetents([.medium])
        })
        //.padding()
      
    }
}

#Preview {
    MemoListView(sortDistance: .constant(true))
}
