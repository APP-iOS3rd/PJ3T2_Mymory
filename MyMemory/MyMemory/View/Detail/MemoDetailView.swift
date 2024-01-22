//
//  MemoDetailView.swift
//  MyMemory
//
//  Created by 김성엽 on 1/16/24.
//

import SwiftUI

struct MemoDetailView: View {
    @State private var selectedNum: String = ""
    @State private var isHeart: Bool = false
    @State private var isBookmark: Bool = false
    @State private var isShowingSheet: Bool = false
    @State private var isReported: Bool = false
    @State private var isShowingImgSheet: Bool = false
    @State private var images: [String] = ["https://firebasestorage.googleapis.com:443/v0/b/mymemory-94fc8.appspot.com/o/images%2F02ACAC65-3830-4B43-8EA9-E35AF7B5E184.jpg?alt=media&token=2b6db024-7ed6-4176-a6ad-0955925e906e", "https://firebasestorage.googleapis.com:443/v0/b/mymemory-94fc8.appspot.com/o/images%2F70F144B2-AB09-4A3F-8155-282733613B2D.jpg?alt=media&token=f2cdb0cd-de86-42f6-8cd6-56f7b99896f9", "https://firebasestorage.googleapis.com:443/v0/b/mymemory-94fc8.appspot.com/o/images%2F02ACAC65-3830-4B43-8EA9-E35AF7B5E184.jpg?alt=media&token=2b6db024-7ed6-4176-a6ad-0955925e906e"]
    
    @State private var isMyMemo:Bool = false
    var memo: Memo
    @EnvironmentObject var mainMapViewModel: MainMapViewModel
    
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
            
            Footer()
            
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
                .environmentObject(mainMapViewModel)
        )
    }
        
    
    func didTapImage(img: String) {
        selectedNum = img
        isShowingImgSheet.toggle()
    }
    
    func checkMyMemo() async {
        isMyMemo = await MemoService().checkMyMemo(checkMemo: memo)
    }
    
}
    

//#Preview {
//    MemoDetailView()
//}

