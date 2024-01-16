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
                    Text("#핫플레이스")
                    Text("#맛집")
                    Text("#종합쇼핑몰")
                }
                .foregroundColor(.gray)
                .font(.regular14)
                
                Text(isVisible ? "메모제목" : "거리가 멀어서 볼 수 없어요.")
                    .font(.black20)
                    .foregroundStyle(isDark ? .white : .black)
                
                Button {
                    
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
