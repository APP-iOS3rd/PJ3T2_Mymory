//
//  navigationBarItems.swift
//  MyMemory
//
//  Created by 정정욱 on 1/20/24.
//

import SwiftUI

struct NavigationBarItems: View {
   
    @Binding var isHeart: Bool
    @Binding var isBookmark: Bool
    @Binding var isShowingSheet: Bool
    @Binding var isReported: Bool
    @Binding var isShowingImgSheet: Bool
    @Binding var isMyMemo: Bool
    @Binding var memo: Memo
    
    @State var likeCount = 0
    @EnvironmentObject var mainMapViewModel: MainMapViewModel
    
    var body: some View {
        HStack {
            // 내가 작성한 메모라면 수정 버튼 보여주기
            if isMyMemo {
               
                NavigationLink { // 버튼이랑 비슷함
                    // destination : 목적지 -> 어디로 페이지 이동할꺼냐
                    PostView(selected: .constant(1), isEdit: true, memo: memo)
                } label: {
                    Image(systemName: "pencil")
                }
    
            }
            VStack {
                Button {
                    isShowingSheet.toggle()
                } label: {
                    Image(systemName: "light.beacon.max")
                    
                }
                .buttonStyle(.plain)
                .sheet(isPresented: $isShowingSheet) {
                    ReportView(memo: memo)
                        .presentationDragIndicator(.visible)
                        .presentationDetents([.medium, .large])
                }
                
                Text(" ")
                    .font(.caption2)
                
            }
            
            VStack {
                Button {
                    print("memo.didLike\(memo.didLike)")
                    MemoService.shared.likeMemo(memo: memo) { err in
                        guard err == nil else {
                            return
                        }
                    }
                    self.memo.didLike.toggle()
                    Task {
                        await fetchlikeCount()
                    }
                } label: {
                    if memo.didLike {
                        Image(systemName: "suit.heart.fill")
                    } else {
                        Image(systemName: "suit.heart")
                    }
                }
                .buttonStyle(.plain)
                
                Text("\(likeCount)")
                    .font(.caption2)
            }
            
            VStack {
                Button {
                    isBookmark.toggle()
                } label: {
                    if isBookmark {
                        Image(systemName: "bookmark.fill")
                    } else {
                        Image(systemName: "bookmark")
                    }
                }
                .buttonStyle(.plain)
                Text("400")
                    .font(.caption2)
            }
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
