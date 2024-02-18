//
//  DetailViewListCell.swift
//  MyMemory
//
//  Created by 이명섭 on 2/16/24.
//

import SwiftUI
import Kingfisher

struct DetailViewListCell: View {
    @Binding var selectedNum: Int
    @Binding var isShowingImgSheet: Bool
    @State var memo: Memo
    @State var imgCount = 0
    
    init(selectedNum: Binding<Int>, isShowingImgSheet: Binding<Bool>, memo: Memo) {
        self._selectedNum = selectedNum
        self._isShowingImgSheet = isShowingImgSheet
        self._memo = State(initialValue: memo)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                VStack(alignment: .leading, spacing: 6) {
                    Text(memo.title)
                        .font(.userMainTextFont(baseSize: 20))
                    
                    Text("등록일 : \(memo.date.createdAtTimeYYMMDD)")
                        .font(.regular14)
                        .foregroundStyle(Color.textGray)
                }
                Spacer()
            }
            .padding(.horizontal, 25)
            
            if !memo.tags.isEmpty {
                ScrollView(.horizontal) {
                    LazyHGrid(rows: [.init(.flexible())], spacing: 5) {
                        ForEach(memo.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.semibold12)
                                .padding(.horizontal, 13)
                                .padding(.vertical, 6)
                                .foregroundColor(.textColor)
                                .background(
                                    Capsule()
                                        .foregroundColor(.peach)
                                )
                            
                        }
                    }
                }
                .scrollDisabled(false)
                .frame(maxWidth: .infinity)
//                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 25)
                .padding(.top, 15)
            }
            
            if !memo.imagesURL.isEmpty {
                ImageGridView(width: UIScreen.main.bounds.width - 50,
                              touchEvent: $isShowingImgSheet,
                              imgIndex: $imgCount,
                              imgs: $memo.imagesURL)
                .frame(maxWidth: UIScreen.main.bounds.width - 50, maxHeight: (UIScreen.main.bounds.width - 50) * 1/2)
                .contentShape(Rectangle())
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
                .foregroundColor(.clear)
                .background(memo.memoTheme.bgColor)
                .padding(.horizontal, 25)
            }
            
            Text(memo.description)
                .multilineTextAlignment(.leading)
                .padding(.top, 20)
                .font(.userMainTextFont(baseSize: 16))
                .padding(.horizontal, 25)

            Spacer()
        }
        .foregroundStyle(memo.memoTheme.textColor)
        .background(memo.memoTheme.bgColor)
    }
    
    func didTapImage(img: Int) {
        selectedNum = img
        isShowingImgSheet.toggle()
    }
}
