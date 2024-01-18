//
//  MemoListView.swift
//  MyMemory
//
//  Created by 김소혜 on 1/15/24.
//

import SwiftUI

struct MemoListView: View {
    
    @State var sortDistance: Bool = true
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            
            Color(UIColor.systemGray5)
                .ignoresSafeArea()
            
            VStack {
                HStack{
                    
                    Button{
                        
                    } label: {
                        FilterButton(buttonName: .constant("전체메뉴"))
                    }
                    .buttonStyle(RoundedRect.standard)
                
                    Button {
                        // 거리순 - 최근 등록순
                        self.sortDistance.toggle()
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
                        MemoCell(isVisible: true, isDark: false)
                        MemoCell(isVisible: true, isDark: false)
                        MemoCell(isVisible: true, isDark: false)
                        MemoCell(isVisible: true, isDark: false)
                        MemoCell(isVisible: true, isDark: false)
                        MemoCell(isVisible: false, isDark: false)
                        MemoCell(isVisible: false, isDark: false)
                        MemoCell(isVisible: false, isDark: false)
                        MemoCell(isVisible: false, isDark: false)
                        MemoCell(isVisible: false, isDark: false)
                        MemoCell(isVisible: false, isDark: false)
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
      
    }
}

#Preview {
    MemoListView()
}
