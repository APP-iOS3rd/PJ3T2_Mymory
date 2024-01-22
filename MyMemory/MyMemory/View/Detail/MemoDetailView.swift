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
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading) {
                    ScrollView(.horizontal) {
                        LazyHGrid(rows: [.init(.flexible())], spacing: 5) {
                            ForEach(memo.tags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.semibold11)
                                    .padding(.horizontal, 13)
                                    .padding(.vertical, 8)
                                    .foregroundColor(.white)
                                    .background(
                                        Capsule()
                                            .foregroundColor(.peach)
                                    )
                                
                            }
                        }
                    }.frame(maxWidth: .infinity)
                        .aspectRatio(contentMode: .fit)
                        .padding(.leading, 25)
                    
                    
                    HStack{
                        VStack(alignment: .leading, spacing: 6) {
                            Text(memo.title)
                                .font(.bold20)
                            Text(memo.address)
                                .font(.regular14)
                                .foregroundStyle(Color.textGray)
                            
                            Text("등록 수정일 : \(memo.date.createdAtTimeYYMMDD)")
                                .font(.regular14)
                                .foregroundStyle(Color.textGray)
                        }
                        Spacer()
                    }.padding(.leading, 25)
                    
                    
                    
                    
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
                    .padding(.top, 25)
                    .padding(.leading, 25)
                    
                    Text(memo.description)
                        .multilineTextAlignment(.leading)
                        .padding(.top, 25)

                        .padding(.horizontal, 25)
                        .padding(.bottom, 70)
                    Spacer()
                }.padding(.top, 50)
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
            VStack {
                Spacer()
                Footer()
            }
        }
        .customNavigationBar(
            centerView: {
                Text(" ")
            },
            leftView: {
                BackButton()
            },
            rightView: {
                NavigationBarItems(isHeart: $isHeart, isBookmark: $isBookmark, isShowingSheet: $isShowingSheet, isReported: $isReported, isShowingImgSheet: $isShowingSheet, isMyMemo: $isMyMemo, memo: memo)
//                                        CloseButton()
            },
            backgroundColor: .white
        )

//        .navigationBarItems(
//            // 오른쪽 부분
//            trailing:   
//                NavigationBarItems(isHeart: $isHeart, isBookmark: $isBookmark, isShowingSheet: $isShowingSheet, isReported: $isReported, isShowingImgSheet: $isShowingSheet, isMyMemo: $isMyMemo, memo: memo)
//        )
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

