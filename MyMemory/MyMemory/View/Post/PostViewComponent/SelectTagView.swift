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
    @Binding var memoSelectedTags: [String]
    @Namespace private var customNamespace // 추가된 네임스페이스
    
    
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
                .frame(height: 40)
                .cornerRadius(10)
                .foregroundStyle(Color.gray.opacity(0.17))
                .overlay(
                    HStack(spacing: 5) {
                        // 태그 선택할때 마다 표시
                        ForEach(memoSelectedTags, id: \.self) { tag in
                            Text("#\(tag)")
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .background(
                                    Capsule()
                                        .foregroundColor(.pink)
                                )
                        }
                    }
                    .padding(5)
                )

        }  //:VSTACK
        .padding(.horizontal, 20)
        
        if isShowingView {
            // View that appears from bottom to top
            VStack {
                
                Text("어떤 태그를 선택하시겠어요?")
                /*
                 VStack 내부의 첫번째 ForEach는 행을 생성합니다. 각 행에는 최대 5개의 태그가 있으며, 전체 태그의 수를 5로 나눈 값이 행의 수를 결정합니다. 나머지가 있다면 행 하나를 더 추가해야 하므로 (TagType.allCases.count + 2) / 5를 사용하여 올림 연산을 수행합니다.

                 각 행은 HStack으로 구현됩니다.
                 
                 HStack 내부의 두 번째 ForEach는 각 행에 5개의 태그를 생성합니다. rowIndex * 5 + columnIndex를 통해 각 태그의 인덱스를 계산합니다.
                 */
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(0..<(TagType.allCases.count + 2) / 5) { rowIndex in
                            HStack(spacing: 20) {
                                ForEach(0..<5) { columnIndex in
                                    let index = rowIndex * 5 + columnIndex
                                    if index < TagType.allCases.count {
                                        let tag = TagType.allCases[index]
                                        Button(action: {
                                            withAnimation {
                                                toggleTag(tag)
                                            }
                                        }) {
                                            Text(tag.rawValue)
                                                .padding()
                                                .background(
                                                    Capsule()
                                                        .foregroundColor(memoSelectedTags.contains(tag.rawValue) ? .pink : .gray)
                                                )
                                                .foregroundColor(.white)
                                        }
                                    } else {
                                        Spacer()
                                    }
                                } // ForEach
                            } // HStack
                        }// ForEach
                    } // VStack
                    .padding()
                } // ScrollView

                .padding()
                
            } //:VSTACK
            .transition(.move(edge: .bottom))
            .animation(.easeInOut)
        }
        
    }
    
    private func toggleTag(_ tag: TagType) {
        // tag를 문자열로 변환하여 tagString 상수에 저장
        let tagString = tag.rawValue

        // 이미 선택된 태그인지 확인
        let isTagSelected = memoSelectedTags.contains(tagString)

        if isTagSelected {
            // 이미 선택된 경우, 해당 태그를 제거
            memoSelectedTags.removeAll { $0 == tagString }
        } else {
            // 선택되지 않은 경우, 최대 5개까지만 추가
            if memoSelectedTags.count < 5 {
                memoSelectedTags.append(tagString)
            }
        }
    }

    
}
#Preview {
    SelectTagView(memoSelectedTags: .constant(["태그1", "태그2"]))
}
