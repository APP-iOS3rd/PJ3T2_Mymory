//
//  FileterListView.swift
//  MyMemory
//
//  Created by 김태훈 on 1/18/24.
//

import SwiftUI

struct FileterListView: View {
    let data = ["슬픔","기쁨","화남","ㅁㅁㅁ","ㅈㅈㅈㅈ","ㅊㅊㅊㅊㅊ","ㅁㅋㅋㄴ","슬픔2","기쁨2","화남2","ㅁㅁㅁ2","ㅈㅈㅈㅈ2","ㅊㅊㅊㅊㅊ2","ㅁㅋㅋㄴ2"]
    @Binding var filteredList: Set<String>
    var body: some View {
        Rectangle()
            .frame(width: 100,height: 3)
            .foregroundStyle(Color.lightGray)
            .cornerRadius(1)
            .padding(.vertical, 10)
        
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()),
                             GridItem(.flexible()),
                             GridItem(.flexible()),
                             GridItem(.flexible())], spacing: 20) {
                ForEach(data, id: \.self){ d in
                    Button(action: {
                        print(d)
                        if filteredList.contains(d) {
                            filteredList.remove(d)
                        } else {
                            filteredList.insert(d)
                        }
                    }, label: {
                        Text("#\(d)")
                    }).buttonStyle(
                        filteredList.contains(d) ?                     Pill.standard : Pill.lightGray
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .aspectRatio(contentMode: .fit)
                }
            }
        }
    }
}

#Preview {
    FileterListView(filteredList: .constant([]))
}
