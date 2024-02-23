//
//  FilterListView.swift
//  MyMemory
//
//  Created by 김태훈 on 1/18/24.
//

import SwiftUI

struct FilterListView: View {
    @Binding var filteredList: Set<String>
    @ObservedObject var tagService = TagService.shared
    var body: some View {
        VStack(spacing: 0){
            
                Rectangle()
            .frame(width: 40,height: 5)
//            .foregroundColor(Color.darkGray)
            .cornerRadius(3)
            .padding(.vertical, 10)
        
        Text("어떤 주제를 선택해 볼까요?")
                .font(.bold20)
                .padding(.top, 30)
                .foregroundColor(Color.textColor)

            ScrollView {
                VStack {
                    Spacer().frame(height: 20)
                    GeometryReader { GeometryProxy in
                        FlexibleView(availableWidth: GeometryProxy.size.width,
                                     data: tagService.tagList,
                                     spacing: 15,
                                     alignment: .center) { item in
                            Button(action: {
                                if filteredList.contains(item) {
                                    filteredList.remove(item)
                                } else {
                                    filteredList.insert(item)
                                }
                            }, label: {
                                Text("#\(item)")
                            }).buttonStyle(
                                filteredList.contains(item) ?
                                Pill.selected : Pill.standard2
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .aspectRatio(contentMode: .fit)
                        }
                                     .frame(maxWidth: .infinity)
                    }
                    
                }
            }
            if !self.filteredList.isEmpty {
                Button(action: {self.filteredList = Set<String>()},
                       label: {Text("초기화 하기")
                        .font(.regular14)
                        .foregroundStyle(Color.gray)
                })
                .padding(.bottom, 10)
//                .buttonStyle(RoundedRect.active)
            }
        }
    }
}

#Preview {
    FilterListView(filteredList: .constant([]))
}
