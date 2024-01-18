//
//  MemoCell.swift
//  MyMemory
//
//  Created by 김소혜 on 1/15/24.
//

import SwiftUI

struct MemoCell: View {
    
    @State var isVisible: Bool = true
    @State var isDark: Bool = false
    @State var Memo: PostMemoModel = PostMemoModel(userCoordinateLatitude: 37.5125, userCoordinateLongitude: 127.102778,
                                                   userAddress: "대한민국 서울특별시 송파구 올림픽로 300 (신천동 29)",
                                                   memoTitle: "오늘의 메모",
                                                   memoContents: "메모메모메모메모메모메모",
                                                   isPublic: false,
                                                   memoTagList: ["데이트장소", "맛집"],
                                                   memoLikeCount: 0,
                                                   memoSelectedImageData: [/* initialize your PhotosPickerItem array here */],
                                                   memoCreatedAt: Date().timeIntervalSince1970)
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
                    // memoTagList의 앞에서부터 최대 3개의 원소를 가져옴
                    ForEach(Array(Memo.memoTagList.prefix(3)), id: \.self) { tag in
                        Text("#\(tag)")
                    }
                }

                .foregroundColor(.gray)
                .font(.regular14)
                
                Text(isVisible ? Memo.memoTitle : "거리가 멀어서 볼 수 없어요.")
                    .font(.black20)
                    .foregroundStyle(isDark ? .white : .black)
                
                Button {
                    // 메모 정보 확인
                    // 추후 디테일뷰 연결해서 메모 전달 해주면 될거같음 
                    print(Memo)
                } label: {
                    Text("해당 장소 메모보기")
                }
                .buttonStyle(isDark ? Pill.deepGray : Pill.lightGray)
                
                Spacer()
                    .padding(.bottom, 12)
                
                
                
                
                HStack(alignment:  .center) {
                    HStack {
                        Image(systemName: "heart.fill")
                        Text("0개")
                        Text("|")
                        Image(systemName: "location.fill")
                        Text("0m")
                    }
                    .foregroundColor(.gray)
                    .font(.regular12)
                    
                    Spacer()
                    
                    if isVisible {
                        
                        Button {
                            // 디테일 뷰로 이동
                        } label: {
                            HStack {
                                Image(systemName: "location.fill")
                                Text("방문하기")
                            }
                            
                        }
                    }
                    
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
        MemoCell(isVisible: true, isDark: true)
        MemoCell(isVisible: true, isDark: false)
        MemoCell(isVisible: false, isDark: true)
        MemoCell(isVisible: false, isDark: false)
    }
    
}
