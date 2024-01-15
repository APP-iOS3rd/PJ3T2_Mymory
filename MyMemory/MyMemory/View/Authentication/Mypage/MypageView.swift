//
//  MyPageView.swift
//  MyMemory
//
//  Created by 이명섭 on 1/4/24.
//

import SwiftUI

struct MypageView: View {
    @StateObject var memoManager = MemoManager.shared
    
    var body: some View {
        NavigationStack {
            VStack{
                HStack(alignment: .center) {
                    Text("My Memo")
                        .font(.bold34)
                    Spacer()
                    
                    NavigationLink {
                        SettingView()
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 24))
                        //                        .padding(.trailing, 10)
                            .foregroundStyle(.black)
                    }
                }
                
                ScrollView {
                    VStack(alignment: .leading) {
                        HStack(alignment: .lastTextBaseline) {
                            Text("내 주변 메모")
                                .font(.semibold20)
                            
                            Text("반경 1km 안에 있는 메모를 보여줍니다.")
                                .font(.regular12)
                                .foregroundStyle(Color(UIColor.systemGray))
                        }
                        .padding(.top, 38)
                        
                        MemoList(memoList: memoManager.memoList)
                    }
                    
                    VStack(alignment: .leading) {
                        HStack(alignment: .lastTextBaseline) {
                            Text("모든 메모")
                                .font(.semibold20)
                            
                            Text("모든 메모를 최신순으로 보여줍니다.")
                                .font(.regular12)
                                .foregroundStyle(Color(UIColor.systemGray))
                            
                            Spacer()
                            
                            Image(systemName: "line.2.horizontal.decrease.circle")
                                .font(.system(size: 24))
                                .foregroundStyle(Color(UIColor.systemGray))
                            
                        }
                        .padding(.top, 24)
                        
                        MemoList(memoList: memoManager.memoList)
                    }
                }
            }.padding(.horizontal, 16)
        }
    }
}
