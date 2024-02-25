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
    @Binding var memo: Memo
    @State var imgCount = 0
    @State private var presentLoginAlert: Bool = false
    @State private var geoMinimumWidth: Int = 0

    @EnvironmentObject var viewModel: DetailViewModel
    
//    init(selectedNum: Binding<Int>, isShowingImgSheet: Binding<Bool>, memo: Memo) {
//        self._selectedNum = selectedNum
//        self._isShowingImgSheet = isShowingImgSheet
//        self._memo = State(initialValue: memo)
//    }
    
    var body: some View {
        VStack(alignment: .leading) {
            //profile fetch를 여기서 Init해서 좀더 자연스럽게
            MoveUserProfileButton(viewModel: .init(userId: memo.userUid),
                                  presentLoginAlert: $presentLoginAlert,
                                  memo: $memo)
            
            HStack{
                VStack(alignment: .leading, spacing: 6) {
                    Text(memo.title)
                    
                        .font(.userMainTextFont(fontType: memo.memoFont, baseSize: 20))
                    Text("\(memo.date.createdAtTimeYYMMDD)")
                        .font(.userMainTextFont(fontType: memo.memoFont, baseSize: 14))
                        .foregroundStyle(Color.textGray)
                }
                Spacer()
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 8)
            
            if !memo.tags.isEmpty {
                ScrollView(.horizontal) {
                    LazyHGrid(rows: [.init(.flexible())], spacing: 5) {
                        ForEach(memo.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.semibold12)
                                .padding(.horizontal, 13)
                                .padding(.vertical, 8)
                                .foregroundColor(.textColor)
                                .background(
                                    Capsule()
                                        .foregroundColor(.accentColor)
                                )
                            
                        }
                    }
                }
                .scrollDisabled(false)
                .frame(maxWidth: .infinity)
//                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 25)
            }
            
            if !memo.imagesURL.isEmpty {
                GeometryReader { geo in
                    if geo.size.width != 0 {
                        ImageGridView(width: abs(geo.size.width - 50),
                                      touchEvent: $isShowingImgSheet,
                                      imgIndex: $imgCount,
                                      imgs: $memo.imagesURL)
                        .frame(maxWidth:abs(geo.size.width - 50),maxHeight: abs(geo.size.width - 50) * 1/2)
                        .contentShape(RoundedRectangle(cornerRadius: 10))
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(10)
                        .foregroundColor(.clear)
                        .background(memo.memoTheme.bgColor)
                        .padding(.horizontal, 25)
                    }
                }
                .frame(height: (UIScreen.main.bounds.width * 1/3))
                
            }
            
            Text(memo.description)
                .multilineTextAlignment(.leading)
                .padding(.top, 20)
                .font(.userMainTextFont(fontType: memo.memoFont, baseSize: 16))
                .padding(.horizontal, 25)
                .padding(.bottom, 20)

            Spacer()
            
        }
        .border(memo.memoTheme.borderColor, width: 1)
        .padding()
        .foregroundStyle(memo.memoTheme.textColor)
        .background(memo.memoTheme.bgColor)
        .border(memo.memoTheme.borderColor, width: 1)
      
    }
    
    func didTapImage(img: Int) {
        selectedNum = img
        isShowingImgSheet.toggle()
    }
}
