//
//  navigationBarItems.swift
//  MyMemory
//
//  Created by 정정욱 on 1/20/24.
//

import SwiftUI

enum SortedMemoDetail: String, CaseIterable, Identifiable {
    case report = "신고하기"
    case delete = "삭제하기"
  //  case theme = "메모지선택"
    
    var id: SortedMemoDetail { self }
}


struct NavigationBarItems: View {
   
    @Binding var isHeart: Bool
    @Binding var isBookmark: Bool
    @Binding var isShowingSheet: Bool
    @Binding var isReported: Bool
    @Binding var isShowingImgSheet: Bool
    @Binding var isMyMemo: Bool
    @Binding var memo: Memo
    
    @State var likeCount = 0
    
    var body: some View {
        HStack(spacing: 13) {
            // 내가 작성한 메모라면 수정 버튼 보여주기
            if isMyMemo {
               
                NavigationLink { // 버튼이랑 비슷함
                    // destination : 목적지 -> 어디로 페이지 이동할꺼냐
                    PostView(selected: .constant(1), isEdit: true, memo: memo)

                } label: {
                    Image(systemName: "pencil")
                        .font(.semibold20)
                }
                .buttonStyle(PlainButtonStyle())
    
            }
           
            VStack {
                Button {
                    print("memo.didLike\(memo.didLike)")
                    self.memo.didLike.toggle()

                    Task {
                        await fetchlikeCount()
                        await MemoService.shared.likeMemo(memo: memo)

                    }
                } label: {
                    if memo.didLike {
                        Image(systemName: "suit.heart.fill")
                            .font(.semibold20)
                    } else {
                        Image(systemName: "suit.heart")
                            .font(.semibold20)
                    }
                }
                .buttonStyle(.plain)
                
//                Text("\(likeCount)")
//                    .font(.caption2)
            }
            
            VStack {
                Button {
                    isBookmark.toggle()
                } label: {
                    if isBookmark {
                        Image(systemName: "bookmark.fill")
                            .font(.semibold20)
                    } else {
                        Image(systemName: "bookmark")
                            .font(.semibold20)
                    }
                }
                .buttonStyle(.plain)

            }
            
            
            // 더보기
            VStack {
                Button {
                    isShowingSheet.toggle()
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.semibold20)
                    
                }
                .buttonStyle(.plain)
                .confirmationDialog("",isPresented: $isShowingSheet){
                    ForEach(SortedMemoDetail.allCases, id: \.self) { type in
                        Button(type.rawValue){
                            if type.rawValue == "신고하기" {
                                isReported.toggle()
                            }
                            
                            if type.rawValue == "삭제하기" {
                                print("삭제하기 눌림")
                            }
                            
                          
                        }
                        
                    }
                }
                .sheet(isPresented: $isReported) {
                    ReportView(memo: $memo)
                        .presentationDragIndicator(.visible)
                        .presentationDetents([.medium, .large])
                }
            }
            // : 더보기
            
            
        }//: HSTACK
        .onAppear {
            Task {
                await fetchlikeCount()
            }
        }
    }
    
    func fetchlikeCount() async{
            likeCount = await MemoService.shared.likeMemoCount(memo: memo)
    }
}

//#if DEBUG
//struct NavigationBarItems_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationBarItems(isHeart: .constant(false), isBookmark: .constant(false), isShowingSheet: .constant(false), isReported: .constant(false), isShowingImgSheet: .constant(false), isMyMemo: .constant(false), memo: Memo(userUid: "123", title: "ggg", description: "gggg", address: "서울시 @@구 @@동", tags: ["ggg", "Ggggg"], images: [], isPublic: false, date: Date().timeIntervalSince1970 - 1300, location: Location(latitude: 37.402101, longitude: 127.108478), likeCount: 10, memoImageUUIDs: [""])) 
//    }
//}
//#endif
