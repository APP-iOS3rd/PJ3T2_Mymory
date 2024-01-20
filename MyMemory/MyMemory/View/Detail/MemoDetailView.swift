//
//  MemoDetailView.swift
//  MyMemory
//
//  Created by 김성엽 on 1/16/24.
//

import SwiftUI

struct MemoDetailView: View {
    @State private var isHeart: Bool = false
    @State private var isBookmark: Bool = false
    @State private var isShowingSheet: Bool = false
    @State private var isReported: Bool = false
    @State private var isShowingImgSheet: Bool = false
    
    @State private var isMyMemo:Bool = false
    var memo: Memo
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                
                HStack(spacing: 5) {
                    // 태그 선택할때 마다 표시
                    ForEach(memo.tags, id: \.self) { tag in
                        Text("#\(tag)")
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .background(
                                Capsule()
                                    .foregroundColor(.pink)
                            )
                    }
                    .padding(.leading)
                    Spacer()
                }
                .padding(5)
            }
            
            HStack{
                VStack(alignment: .leading) {
                    Text(memo.title)
                        .font(.title2)
                    Text(memo.address)
                        .font(.caption)
                    Text(memo.date.createdAtTimeYYMMDD)
                        .font(.caption)
                }
                .padding(.leading)
                Spacer()
            }
          
            
            ScrollView(.horizontal) {
                HStack{
                    ForEach(memo.images.indices, id: \.self) { index in
                        if let uiimage = UIImage(data: memo.images[index]) {
                            Image(uiImage: uiimage)
                                .resizable()
                                //.scaledToFit()
                                .scaledToFill()
                                .frame(width: 90, height: 90)
                        }
                    }
                }
            }
            .padding()
            
            Text(memo.description)
            .multilineTextAlignment(.leading)
            .padding()
        }
        .onAppear {
            Task {
                do {
                    isMyMemo = try await MemoService().checkMyMemo(checkMemo: memo)
                } catch {
                    // 에러 처리
                    print("Error checking my memo: \(error.localizedDescription)")
                }
            }
        }

        .navigationBarItems(
            // 오른쪽 부분
            trailing:   
                NavigationBarItems(isHeart: $isHeart, isBookmark: $isBookmark, isShowingSheet: $isShowingSheet, isReported: $isReported, isShowingImgSheet: $isShowingSheet, isMyMemo: $isMyMemo, memo: memo)
        )
    }
        
    
    func didTapImage() {
        isShowingImgSheet.toggle()

    }
    
    func checkMyMemo() async {
        isMyMemo = await MemoService().checkMyMemo(checkMemo: memo)
    }
    
}
    

//#Preview {
//    MemoDetailView()
//}
