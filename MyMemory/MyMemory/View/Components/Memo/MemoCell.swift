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
    @State var isDark: Bool = false
    @Binding var location: CLLocation?
    
    @State var memo: Memo = Memo(userUid: "123", title: "ggg", description: "gggg", address: "서울시 @@구 @@동", tags: ["ggg", "Ggggg"], images: [], isPublic: false, date: Date().timeIntervalSince1970 - 1300, location: Location(latitude: 0, longitude: 0), likeCount: 10, memoImageUUIDs: [""])
    //var memo: Memo
    var body: some View {
        HStack(spacing: 16) {
            
            VStack{
                Image(systemName: isVisible ? "heart.fill": "lock")
                    .foregroundColor(.gray)
                    .frame(width: 46, height: 46)
                    .background(isDark ? .white : .lightGray)
                    .clipShape(Circle())
                
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
                Text(isVisible ? memo.title : "거리가 멀어서 볼 수 없어요.")
                    .lineLimit(1)
                    .font(.black20)
                    .foregroundStyle(isDark ? .white : .black)
                
                Button {
                    // 메모 정보 확인
                    // 추후 디테일뷰 연결해서 메모 전달 해주면 될거같음
                } label: {
                    Text("해당 장소 메모보기")
                }
                .buttonStyle(isDark ? Pill.deepGray : Pill.lightGray)
                
                Spacer()
                    .padding(.bottom, 12)
                
                
                
                
                HStack(alignment:  .center) {
                    HStack {
                        Image(systemName: "heart.fill")
                        Text("\(memo.likeCount)개")
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
                    
                    if isVisible {
                        NavigationLink { // 버튼이랑 비슷함
                            // destination : 목적지 -> 어디로 페이지 이동할꺼냐
                            MemoDetailView(memo: memo)
                        } label: {
                            HStack {
                                Image(systemName: "location.fill")
                                Text("메모보기")
                            }
                        }
                    } else {
                        NavigationLink {
                            CertificationView(memo: $memo)
                        } label: {
                            HStack {
                                Image(systemName: "location.fill")
                                Text("메모보기")
                            }
                        }
                    }  // : VStack
                    
                    
                }
                .buttonStyle(RoundedRect.primary)
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            
        }
        .padding(20)
        .background(isDark ? Color(UIColor.black) : .white)
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: false, vertical: true)
        .cornerRadius(20)
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
