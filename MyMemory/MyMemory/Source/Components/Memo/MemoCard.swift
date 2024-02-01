//
//  MemoCard.swift
//  MyMemory
//
//  Created by 김태훈 on 2/1/24.
//

import SwiftUI
import Kingfisher
struct MemoCard: View {
    @Binding var memo: Memo
    @State var isVisible: Bool = true
    @State var isTagExpended: Bool = false
    @State var showImageViewer: Bool = false
    @State var imgIndex: Int = 0

    var body: some View {
        
        VStack(alignment: .leading){
            // Pin condition
            if true {
                HStack{
                    Spacer()
                    Image(systemName: "pin.fill")
                        .resizable()
                        .frame(width: 15, height: 20)
                }
            }
            if memo.images.count > 0 {
                ImageGridView(width: UIScreen.main.bounds.width - 40,
                              touchEvent:$showImageViewer,
                              imgIndex: $imgIndex,
                              imgs: $memo.images)
                .frame(width: UIScreen.main.bounds.width - 40, height: (UIScreen.main.bounds.width - 40) * 1/2)
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
                .background(.white)
                .foregroundColor(.clear)
                .background(Color.deepGray)
                .padding(.top, 13)

            }
            Text("\(memo.description)")
                .multilineTextAlignment(.leading)
                .font(.medium14)
                .foregroundColor(.darkGray)
                .padding(.top, 15)
            HStack {
                if self.isTagExpended {
                    ForEach(memo.tags, id: \.self) { id in
                        Text("\(id)")
                            .font(.medium12)
                            .foregroundStyle(Color.deepGray)
                            .padding(.vertical, 5)
                            .padding(.horizontal,10)
                            .background(Color.backgroundColor)
                            .cornerRadius(3, corners: .allCorners)
                    }
                } else if !memo.tags.isEmpty{
                    Text("\(memo.tags[0])")
                        .font(.medium12)
                        .foregroundStyle(Color.deepGray)
                        .padding(.vertical, 5)
                        .padding(.horizontal,10)
                        .background(Color.backgroundColor)
                        .cornerRadius(3, corners: .allCorners)
                    if memo.tags.count > 1 {
                        Text("+\(memo.tags.count - 1)")
                            .font(.medium12)
                            .foregroundStyle(Color.deepGray)
                            .padding(.vertical, 5)
                            .padding(.horizontal,10)
                            .background(Color.backgroundColor)
                            .cornerRadius(3, corners: .allCorners)
                            .onTapGesture {
                                withAnimation{
                                    self.isTagExpended = true
                                }
                            }
                    }
                }
            }
            .padding(.top, 15)
            HStack {
                Button {
                    
                } label: {
                    // Like condition
                    Image(systemName: false ? "heart" : "heart.fill")
                }
                switch memo.likeCount {
                case 100..<1000 :
                    Text("\(memo.likeCount/100)00+")
                        .foregroundStyle(Color(hex: "#555459"))
                        .font(.medium12)
                case 1000... :
                    Text("\(memo.likeCount/1000)k+")
                        .foregroundStyle(Color(hex: "#555459"))
                        .font(.medium12)
                default:
                    Text("\(memo.likeCount)")
                        .foregroundStyle(Color(hex: "#555459"))
                        .font(.medium12)
                }
                
                Spacer()
                Text("\(memo.date.toSimpleStr)")
                    .foregroundStyle(Color(hex: "#555459"))
                    .font(.medium12)
                    .padding(.leading,5)
            }
            .padding(.top, 15)
            HStack {
                VStack(alignment:.leading) {
                    Text("\(memo.title)")
                        .font(.bold16)
                    Text("\(memo.address)")
                        .font(.regular12)
                }
                Spacer()
                Button {
                    
                } label: {
                    VStack{
                        Image(systemName: false ?  "bookmark" : "bookmark.fill")
                            .padding(.bottom, 5)
                        Text("저장")
                            .font(.medium12)
                            .foregroundStyle(false ? Color.textGray : Color.accentColor)
                    }
                }
                
            }
            .padding(13)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke()
                    .foregroundStyle(Color(hex: "#E9E9E9"))
            )
        }.padding(20)
            .background(Color.white)
            .fullScreenCover(isPresented: $showImageViewer) {
                ImgDetailView(selectedImage: $imgIndex, images: memo.images)
            }
    }
    
}

//#Preview {
//    MemoCard()
//}

struct ImageGridView: View {
    @State var width: CGFloat
    @Binding var touchEvent: Bool
    @Binding var imgIndex: Int
    @Binding var imgs: [Data]
    var body: some View {
        switch imgs.count {
            
        case 1:
            Image(uiImage: UIImage(data: imgs[0])!)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: width,height: width * 1/2)

                .background(Color.blue)

                .onTapGesture {
                    touchEvent.toggle()
                    imgIndex = 0
                }
        case 2:
            HStack(spacing: 2) {
                Image(uiImage: UIImage(data: imgs[0])!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width/2.0)

                    .onTapGesture {
                        touchEvent.toggle()
                        imgIndex = 0
                    }
                Image(uiImage: UIImage(data: imgs[1])!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width/2.0)

                    .onTapGesture {
                        touchEvent.toggle()
                        imgIndex = 1
                    }
            }
        case 3:
            HStack(spacing: 2) {
                Image(uiImage: UIImage(data: imgs[0])!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width * 2/3.0)

                    .onTapGesture {
                        touchEvent.toggle()
                        imgIndex = 0
                    }
                VStack(spacing:2){
                    Image(uiImage: UIImage(data: imgs[1])!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: width * 1/3.0)

                        .onTapGesture {
                            touchEvent.toggle()
                            imgIndex = 1
                        }
                    Image(uiImage: UIImage(data: imgs[2])!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: width * 1/3.0)

                        .onTapGesture {
                            touchEvent.toggle()
                            imgIndex = 2
                        }
                }
            }
        default:
            HStack(spacing: 2) {
                Image(uiImage: UIImage(data: imgs[0])!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width * 2/3.0)

                    .onTapGesture {
                        touchEvent.toggle()
                        imgIndex = 0
                    }
                VStack(spacing: 2){
                    Image(uiImage: UIImage(data: imgs[1])!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: width * 1/3.0)

                        .onTapGesture {
                            touchEvent.toggle()
                            imgIndex = 1
                        }
                    Image(uiImage: UIImage(data: imgs[2])!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: width * 1/3.0)

                        .overlay(
                            ZStack{
                                Color.black.opacity(0.6)
                                Text("+\(imgs.count-3)")
                                    .font(.bold18)
                                    .foregroundStyle(Color.white)
                            }
                        )
                        .onTapGesture {
                            touchEvent.toggle()
                            imgIndex = 2
                        }
                }
            }
        }
    }
}
