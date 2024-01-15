//
//  SelectTagView.swift
//  MyMemory
//
//  Created by 정정욱 on 1/11/24.
//

import SwiftUI

enum TagType: String, CaseIterable {
    case date = "데이트"
    case restaurant = "맛집"
    case hotPlace = "핫플레이스"
    case star = "스타"
    case event = "이벤트"
    case whisper = "속닥속닥"
    case game = "게임"
    case humor = "유머"
    case fashionBeauty = "패션뷰티"
    case artWork = "예술작품"
    case graffiti = "그래피티"
    case education = "교육"
    case photo = "사진"
    case secretPlace = "나만알고싶은곳"
    case instagrammablePlace = "사진찍기좋은곳"
    case lifeShot = "인생샷"
}



struct SelectTagView: View {
    @State private var isShowingView: Bool = false
    @State private var selectedTags: [String] = []
    
    // 화면 그리드형식으로 채워줌
    let layout: [GridItem] = [
        GridItem(.flexible(maximum: 80)),
        GridItem(.flexible(maximum: 80)),
        GridItem(.flexible(maximum: 80))
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10){
            HStack(alignment: .lastTextBaseline, spacing: 200){
                Text("#어떤타입?")
                    .font(.bold20)
                    .bold()
                
                Button {
                    withAnimation {
                        // Toggle the view's visibility
                        isShowingView.toggle()
                    }
                    
                } label: {
                    Text("추가하기")
                        .foregroundStyle(Color(.blue))
                        .font(.subheadline)
                }
            }  //:HSTACK
            
            Rectangle()
                .frame(width: UIScreen.main.bounds.size.width * 0.90, height:40)
                .cornerRadius(10)
                .foregroundStyle(Color.gray.opacity(0.17))
        }  //:VSTACK
        
        if isShowingView {
            // View that appears from bottom to top
            VStack {
                
                Text("어떤 태그를 선택하시겠어요?")
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: layout, spacing: 20) {
                        ForEach(TagType.allCases, id: \.self) { tag in
                            Button(action: {
                                // 버튼 누르면 태그 배열의 추가
                                withAnimation {
                                    toggleTag(tag)
                                }
                            }) {
                                //현재 반복 중인 tag의 rawValue 즉, 문자열 값입니다.
                                Text(tag.rawValue)
                                    .padding()
                                    .background(
                                        Capsule()
                                            .foregroundColor(selectedTags.contains(tag.rawValue) ? .pink : .gray)
                                    )
                                    .foregroundColor(.white)
                                /*
                                 현재 태그가 selectedTags 배열에 포함되어 있는지 여부를 확인합니다.
                                 만약 포함되어 있다면, 조건이 참이므로 .pink를 사용하여 배경색을 핑크로 지정합니다.
                                 포함되어 있지 않다면, 조건이 거짓이므로 .gray를 사용하여 배경색을 그레이로 지정합니다.
                                 */
                            }
                        } // ForEach
                    }// LazyHGrid
                    .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 4)// 화면의 반의 반 비율
                }  //:SCROLL
                .padding()
                
            } //:VSTACK
            .transition(.move(edge: .bottom))
            .animation(.easeInOut)
        }
        
    }
    
    private func toggleTag(_ tag: TagType) {
        //tag를 문자열로 변환하여 tagString 상수에 저장
        let tagString = tag.rawValue
        
        //selectedTags에 tagString이 이미 존재한다면, 이는 해당 태그가 이미 선택되어 있다는 의미입니다. 따라서 해당 태그를 selectedTags 배열에서 제거
        if selectedTags.contains(tagString) {
            selectedTags.removeAll { $0 == tagString }
        } else {
            // 그렇지 않으면 추가
            selectedTags.append(tagString)
        }
    }
    
}
#Preview {
    SelectTagView()
}
