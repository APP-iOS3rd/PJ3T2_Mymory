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
            HStack(alignment: .lastTextBaseline){
                Text("태그")
                    .font(.bold20)
                    .bold()
                Spacer()
                Button {
                    withAnimation {
                        // Toggle the view's visibility
                        isShowingView.toggle()
                    }
                    
                } label: {
                    Text("+")
                        .rotationEffect(isShowingView ? .init(degrees: 45) : .zero)
                        .foregroundStyle(Color.textColor)
                }.buttonStyle(.plain)
            }  //:HSTACK
            Rectangle()
                .frame(height: 0.5)
            Rectangle()
                .frame(height: 40)
                .cornerRadius(10)
                .foregroundStyle(Color.gray.opacity(0.17))
                .overlay(
                    ScrollView(.horizontal) {
                        HStack(spacing: 5) {
                            // 태그 선택할때 마다 표시
                            ForEach(memoSelectedTags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.bold14)
                                    .padding(5)
                                    .foregroundColor(.lightPeach)
                                    .padding(.horizontal, 8)
                                    .background(
                                        Capsule()
                                            .foregroundColor(Color.peach)
                                    )
                                    .onTapGesture {
                                        memoSelectedTags.removeAll(where: {$0 == tag})
                                    }
                            }
                        }
                        .padding(5)
                    }
                )
                .onTapGesture {
                    if isShowingView == false {
                        withAnimation {
                            // Toggle the view's visibility
                            isShowingView.toggle()
                        }
                    }
                }
            
            
            if isShowingView {
                // View that appears from bottom to top
                VStack {
                    
                    Text("어떤 태그를 선택하시겠어요?")
                        .font(.bold18)
                    VStack {
                        GeometryReader { GeometryProxy in
                            FlexibleView(availableWidth: GeometryProxy.size.width,
                                         data: TagType.allCases,
                                         spacing: 15,
                                         alignment: .center) { item in
                                Button(action: {
                                    toggleTag(item)
                                }, label: {
                                    Text("#\(item.rawValue)")
                                }).buttonStyle(
                                    memoSelectedTags.contains(item.rawValue) ?                     Pill.selected : Pill.lightGray
                                )
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .aspectRatio(contentMode: .fit)
                            }.frame(maxWidth: .infinity)
                            
                        } // VStack
                    } // ScrollView

                } //:VSTACK
                .transition(.move(edge: .bottom))
                .animation(.easeInOut)
                .padding(.bottom , 60)
            }
        }
        .onAppear {
            isShowingView = false
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
    SelectTagView(memoSelectedTags: .constant(["태그1", "그2","태1", "태그277","1", "태그52","태그yy1", "태그7802"]))
}
