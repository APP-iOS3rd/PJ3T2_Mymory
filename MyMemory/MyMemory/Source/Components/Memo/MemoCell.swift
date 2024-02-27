//
//  MemoCell.swift
//  MyMemory
//
//  Created by 김소혜 on 1/15/24.
//

import SwiftUI
import CoreLocation
import Kingfisher
struct MemoCell: View {
    
    @State var isVisible: Bool = true
    @Binding var location: CLLocation?
    @EnvironmentObject var mainMapViewModel: MainMapViewModel
    
    @State var selectedMemoIndex: Int = 0
    @Binding var memo: Memo
    @Binding var memos: [Memo]
    
    @State var likeCount = 0
    @State var isMyMemo: Bool = false
    @State var isFromCo: Bool = false
    @State var profileImageUrl: String = ""
    var unAuthorized: (Bool) -> ()
    
    var body: some View {
        HStack(spacing: 16) {
            
            VStack {
                if let loc = location, selectedMemoIndex < memos.count {
                    
                    if (memos[selectedMemoIndex].location.distance(from: loc) <= MemoService.shared.readableArea) || isMyMemo || isFromCo {
                        
                        if !profileImageUrl.isEmpty {
                            KFImage(URL(string: profileImageUrl))
                                 .resizable()
                                 .scaledToFill()
                                 .clipped()
                                 .clipShape(.circle)
                                 .frame(width: 46, height: 46)
                        } else {
                            Image("profileImg") 
                                .resizable()
                                .scaledToFill()
                                .clipped()
                                .clipShape(.circle)
                                .frame(width: 46, height: 46)
                        }
                        
                        
                    } else {
                        Image(systemName: "lock")
                            .foregroundColor(.gray)
                            .frame(width: 46, height: 46)
                            .background(Color.bgColor)
                            .clipShape(Circle())
                            .onAppear {
                                self.isVisible = false
                            }
                    }
                }
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 6) {
                
            
                
                if isFromCo {
                    Text(memo.title)
                        .lineLimit(1)
                        .font(.black20)
                        .foregroundStyle(Color.textColor)
                } else {
                    if let loc = location, selectedMemoIndex < memos.count {
                        
                        Text((memos[selectedMemoIndex].location.distance(from: loc) <= MemoService.shared.readableArea)  || isMyMemo ? memo.title : "거리가 멀어서 볼 수 없어요.")
                            .lineLimit(1)
                            .font(.black20)
                            .foregroundStyle(Color.textColor)
                    }
                    //                Button {
                    //                    // 메모 정보 확인
                    //                    // 추후 디테일뷰 연결해서 메모 전달 해주면 될거같음
                    //                } label: {
                    //                    Text("\(memo.building ?? "해당 장소 메모보기")")
                    //                }
                    //                .buttonStyle(Pill.deepGray)
                    //.buttonStyle(isDark ? Pill.deepGray : Pill.lightGray)
                }
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
                .frame(height: 16)
                
                .foregroundColor(.gray)
                .font(.regular14)
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
                                .lineLimit(1)
                        } else {
                            Text("\(-1)m")
                                .lineLimit(1)
                        }
                        
                    }
                    .foregroundColor(.gray)
                    .font(.regular12)
                    
                    Spacer()
                    
                    
                    NavigationLink { // 버튼이랑 비슷함
                        if isFromCo {
                            MemoDetailView(memos: $memos,selectedMemoIndex: selectedMemoIndex, isFromCo: isFromCo)
                        } else {
                            DetailView(memo: $memo, isVisble: $isVisible, memos: $memos, selectedMemoIndex: selectedMemoIndex, isMyMemo: isMyMemo)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("메모보기")
                        }
                    }
                    
                    
                    
                }
                .buttonStyle(RoundedRect.primary)
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            
        }
        .padding(20)
        .background(Color.originColor)
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: false, vertical: true)
        .cornerRadius(20)
        .onAppear {
            if let distance = location?.coordinate.distance(from: memo.location) {
                if distance <= MemoService.shared.readableArea {
                    isVisible = true
                } else {
                    isVisible = false
                }
            }
            
            Task {
                await fetchlikeCount()
                isMyMemo = await MemoService().checkMyMemo(checkMemo: memo) // 메모 다 지우면 오류남
            }
            
            Task {
                self.profileImageUrl = await AuthService.shared.getProfileImg(uid: memo.userUid)
            }
        }
        .onChange(of: location) { oldValue, newValue in
            let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
                
                //                if let loc = newValue{
                //                    print("새값 : \(loc.coordinate)")
                //                    let dist = memos[selectedMemoIndex].location.distance(from: loc)
                //                    if dist <= MemoService.shared.readableArea {
                //                        self.isVisible = true
                //                    } else {
                //                        self.isVisible = false
                //                    }
                //                }
            }
        }
    }
    
    func fetchlikeCount() async{
        likeCount = await MemoService.shared.likeMemoCount(memo: memo)
    }

}

