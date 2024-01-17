//
//  MemoDetailView.swift
//  MyMemory
//
//  Created by 김성엽 on 1/16/24.
//

import SwiftUI

struct MemoDetailView: View {
    @State private var isHeart: Bool = false
    @State private var isBookmark: Bool = false
    @State private var isShowingSheet: Bool = false
    @State private var isReported: Bool = false
    @State private var isShowingImgSheet: Bool = false
    
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Rectangle()
                    .frame(height: 250)
                    .padding()
                
                HStack {
                    Capsule()
                        .frame(width: 60, height: 30)
                    Capsule()
                        .frame(width: 60, height: 30)
                    Capsule()
                        .frame(width: 60, height: 30)
                }
                .padding(.horizontal, 20)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("제목입니다")
                        .font(.title2)
                    Text("서울특별시 은평구")
                        .font(.caption)
                    Text("제목입니다")
                        .font(.caption)
                }
                
                Spacer()
                
                VStack {
                    Button {
                        isShowingSheet.toggle()
                    } label: {
                        Image(systemName: "light.beacon.max")
                        
                    }
                    .buttonStyle(.plain)
                    .sheet(isPresented: $isShowingSheet) {
                        ReportView()
                            .presentationDragIndicator(.visible)
                            .presentationDetents([.medium, .large])
                    }
                    
                    Text(" ")
                        .font(.caption2)

                }
                
                VStack {
                    Button {
                        isHeart.toggle()
                    } label: {
                        if isHeart {
                            Image(systemName: "suit.heart.fill")
                        } else {
                            Image(systemName: "suit.heart")
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Text("1k")
                        .font(.caption2)
                }
                
                VStack {
                    Button {
                        isBookmark.toggle()
                    } label: {
                        if isBookmark {
                            Image(systemName: "bookmark.fill")
                        } else {
                            Image(systemName: "bookmark")
                        }
                    }
                    .buttonStyle(.plain)
                    Text("400")
                        .font(.caption2)
                }
            }//: HSTACK
            .padding()
            
            ScrollView(.horizontal) {
                HStack{
                    ForEach(1..<4) { item in
                        Rectangle()
                            .frame(width: 100, height: 100)
                            .onTapGesture(perform: didTapImage)
                            .fullScreenCover(isPresented: $isShowingImgSheet) {
                             ImgDetailView(isShownFullScreenCover: $isShowingImgSheet)
                            }
                    }
                }
            }
            .padding()
            
            Text("""
Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.

""")
            .multilineTextAlignment(.leading)
            .padding()
        }
    }
    
    func didTapImage() {
        isShowingImgSheet.toggle()

    }
    
}

#Preview {
    MemoDetailView()
}
