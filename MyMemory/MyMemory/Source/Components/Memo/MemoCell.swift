//
//  MemoCell.swift
//  MyMemory
//
//  Created by 김소혜 on 1/15/24.
//

import SwiftUI
import CoreLocation

struct MemoCell: View {
    
    @State var isVisible: Bool = true
    @Binding var location: CLLocation?
    
    @State var selectedMemoIndex: Int = 0
    @State var memo: Memo = Memo(userUid: "123", title: "ggg", description: "gggg", address: "서울시 @@구 @@동", tags: ["ggg", "Ggggg"], images: [], isPublic: false, date: Date().timeIntervalSince1970 - 1300, location: Location(latitude: 0, longitude: 0), likeCount: 10, memoImageUUIDs: [""])
    @State var memos: [Memo] = [Memo(userUid: "123", title: "ggg", description: "gggg", address: "서울시 @@구 @@동", tags: ["ggg", "Ggggg"], images: [], isPublic: false, date: Date().timeIntervalSince1970 - 1300, location: Location(latitude: 0, longitude: 0), likeCount: 10, memoImageUUIDs: [""])]
    
    @State var likeCount = 0
    @State var isMyMemo: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            
            VStack{
                if isVisible || isMyMemo {
                    Button(action: {
                        MemoService.shared.likeMemo(memo: memo) { err in
                            guard err == nil else {
                                return
                            }
                        }
                        self.memo.didLike.toggle()
                        Task {
                            await fetchlikeCount()
                        }
                        //print("\(memo.didLike)")
                        //memo.didLike.toggle()
                        //print("\(memo.didLike)")
                    }) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(memo.didLike ? .red : .gray)
                            .frame(width: 46, height: 46)
                            .background(Color.bgColor)
                            .clipShape(Circle())
                          
                    }
                } else {
                    Image(systemName: "lock")
                    .foregroundColor(.gray)
                    .frame(width: 46, height: 46)
                    .background(Color.bgColor)
                    .clipShape(Circle())
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 6) {
                
                // Tag는 세 개까지 표시
                HStack {
                    if memo.tags.count > 3 {
                        ForEach(memo.tags[0..<3], id: \.self) { str in
                            Text("#\(str)")
                        }
                    } else {
                        ForEach(memo.tags, id: \.self) { str in
                            Text("#\(str)")
                        }
                    }
                }
                .foregroundColor(.gray)
                .font(.regular14)
                
                Text(isVisible || isMyMemo ? memo.title : "거리가 멀어서 볼 수 없어요.")
                    .lineLimit(1)
                    .font(.black20)
                    .foregroundStyle(Color.textColor)
                
//                Button {
//                    // 메모 정보 확인
//                    // 추후 디테일뷰 연결해서 메모 전달 해주면 될거같음
//                } label: {
//                    Text("해당 장소 메모보기")
//                }
//                .buttonStyle(Pill.deepGray)
                //.buttonStyle(isDark ? Pill.deepGray : Pill.lightGray)
                
                Spacer()
                    .padding(.bottom, 12)
                
                
                
                
                HStack(alignment:  .center) {
                    HStack {
                        Image(systemName: "heart.fill")
                        Text("\(likeCount)개")
                        Text("|")
                        Image(systemName: "location.fill")
                        if let loc = location {
                            Text("\(memo.location.distance(from: loc).distanceToMeters())")
                        } else {
                            Text("\(-1)m")
                                .lineLimit(1)
                        }
                        
                    }
                    .foregroundColor(.gray)
                    .font(.regular12)
                    
                    Spacer()
                    
                    
                    NavigationLink { // 버튼이랑 비슷함
                        DetailView(memo: $memo, isVisble: $isVisible, memos: $memos, selectedMemoIndex: selectedMemoIndex, isMyMemo: isMyMemo)
                        
                    } label: {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("메모보기")
                        }
                    }
                    
                    
                    
                }
                .buttonStyle(RoundedRect.primary)
                
            }
            .frame(maxWidth: .infinity)
            .frame(height: 130)
            
        }
        .padding(20)
        .frame(maxWidth: .infinity)
       // .fixedSize(horizontal: false, vertical: true)
        .background(Color.cardColor)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.borderColor)
        )
        .onAppear {
            if let distance = location?.coordinate.distance(from: memo.location) {
                if distance <= 50 {
                    isVisible = true
                } else {
                    isVisible = false
                }
            }
    
            Task {
                await fetchlikeCount()
                isMyMemo = await MemoService().checkMyMemo(checkMemo: memo)
            }
            
        }
        .onChange(of: location) { oldValue, newValue in
            if let distance = newValue?.coordinate.distance(from: memo.location) {
                if distance <= 50 {
                    isVisible = true
                } else {
                    isVisible = false
                }
            }
        }
    }
    
    func fetchlikeCount() async{
            likeCount = await MemoService.shared.likeMemoCount(memo: memo)
    }
}


#Preview {
    VStack {
        //        MemoCell(isVisible: true, isDark: true)
        //        MemoCell(isVisible: true, isDark: false)
        //        MemoCell(isVisible: false, isDark: true)
        //        MemoCell(isVisible: false, isDark: false)
    }
    
}
