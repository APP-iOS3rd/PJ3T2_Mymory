//
//  MemoDetailView.swift
//  MyMemory
//
//  Created by 김성엽 on 1/16/24.
//

import SwiftUI

struct MemoDetailView: View {
    @State private var selectedNum: String = ""
    @State private var isHeart: Bool = false
    @State private var isBookmark: Bool = false
    @State private var isShowingSheet: Bool = false
    @State private var isReported: Bool = false
    @State private var isShowingImgSheet: Bool = false
    @State private var images: [String] = ["https://firebasestorage.googleapis.com:443/v0/b/mymemory-94fc8.appspot.com/o/images%2F02ACAC65-3830-4B43-8EA9-E35AF7B5E184.jpg?alt=media&token=2b6db024-7ed6-4176-a6ad-0955925e906e", "https://firebasestorage.googleapis.com:443/v0/b/mymemory-94fc8.appspot.com/o/images%2F70F144B2-AB09-4A3F-8155-282733613B2D.jpg?alt=media&token=f2cdb0cd-de86-42f6-8cd6-56f7b99896f9", "https://firebasestorage.googleapis.com:443/v0/b/mymemory-94fc8.appspot.com/o/images%2F02ACAC65-3830-4B43-8EA9-E35AF7B5E184.jpg?alt=media&token=2b6db024-7ed6-4176-a6ad-0955925e906e"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                
                HStack {
                    Capsule()
                        .frame(width: 60, height: 30)
                    Capsule()
                        .frame(width: 60, height: 30)
                    Capsule()
                        .frame(width: 60, height: 30)
                }
                .padding(.top, 20)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("제목입니다")
                            .font(.title2)
                        Text("서울특별시 은평구")
                            .font(.caption)
                        Text("등록 수정일")
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
                .padding(.top, 15)
            }
            .padding()
            
            
            ScrollView(.horizontal) {
                HStack{
                    ForEach(images, id: \.self) { item in
                        AsyncImage(url: URL(string: item)) { phase in
                            switch phase {
                            case .success(let image):
                                image.imageModifier()
                            case .failure(_):
                                Image(systemName: "xmark.circle.fill").iconModifier()
                            case .empty:
                                Image(systemName: "photo.circle.fill").iconModifier()
                            @unknown default:
                                ProgressView()
                            }

                        }
                        .frame(height: 600)
                        .frame(maxWidth: 100, maxHeight: 100)
                        .onTapGesture { didTapImage(img: item) }
                        .fullScreenCover(isPresented: $isShowingImgSheet) {
                            ImgDetailView(isShownFullScreenCover: $isShowingImgSheet, imagUrl: $selectedNum, images: $images)
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
            
            Footer()
            
        }
      
    }
    
    func didTapImage(img: String) {
        selectedNum = img
        isShowingImgSheet.toggle()
    }
    
}

#Preview {
    MemoDetailView()
}

