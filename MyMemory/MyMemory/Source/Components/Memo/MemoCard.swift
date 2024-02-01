//
//  MemoCard.swift
//  MyMemory
//
//  Created by 김태훈 on 2/1/24.
//

import SwiftUI
import Kingfisher
struct MemoCard: View {
    @State var imgs: [String] = ["https://img1.daumcdn.net/thumb/R658x0.q70/?fname=https://t1.daumcdn.net/news/202304/21/bemypet/20230421120037737gfub.jpg"
                                 ,"https://mblogthumb-phinf.pstatic.net/MjAxNzA0MDNfMjAg/MDAxNDkxMTg4Njg4MTQ0.kjtqiy0TcfdhhpOqiwXQiOwBqjiibjFItiFT_8K7leog.wM9LnbuIAhpvtKdNJeVbKyKTjJuDAclt_HByAHHhvgMg.JPEG.truthy2000/3bbcd721fc7b53e3a7655aa0b77b6441.jpg?type=w800"
                                 ,"https://godomall.speedycdn.net/09a3e8c0a817b72d1e313a19117c72e3/goods/1000000085/image/detail/1000000085_detail_025.jpg"
                                 ,"https://mblogthumb-phinf.pstatic.net/MjAxNjExMTVfMjg3/MDAxNDc5MTg3NTUzNjM1.7oGmT6c3RC-47Osli67OgybFdMiWkmRu5R5fss2OifYg.asvxgHbES67k4jQga3vk6IYHlg934o42AN6HRrdTOpkg.JPEG.eoulimah/fghhhhh.JPG?type=w800"
                                 ,"https://m.mscamping.co.kr/web/product/big/202204/a1cb273ec24a17fabdd6784172254bb5.jpg"
    ]
    @State var tags: [String] = ["🤣진짜 재밌어요!", "환상적인", "또 가고싶은"]
    var body: some View {
        GeometryReader{ proxy in
            
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
                if imgs.count > 0 {
                    ImageGridView(proxy: proxy,
                                  imgs: $imgs)
                    .frame(width: proxy.size.width, height: proxy.size.width * 1/2)
                    .cornerRadius(10)
                    .background()
                    .foregroundColor(.clear)
                    .background(Color.deepGray)
                    .padding(.top, 13)
                }
                Text("내가 다녀왔던 공간에 \n메모를 남겨보아요~")
                    .font(.medium14)
                    .foregroundColor(.darkGray)
                    .padding(.top, 15)
                HStack {
                    ForEach(tags, id: \.self) { id in
                        Text("\(id)")
                            .font(.medium12)
                            .foregroundStyle(Color.deepGray)
                            .padding(.vertical, 5)
                            .padding(.horizontal,10)
                            .background(Color.backgroundColor)
                            .cornerRadius(3, corners: .allCorners)
                    }
                }
                .padding(.top, 15)
                HStack {
                    Button {
                        
                    } label: {
                        // Like condition
                        Image(systemName: false ? "heart" : "heart.fill")
                    }
                    Text("\(100)+")
                        .foregroundStyle(Color(hex: "#555459"))
                        .font(.medium12)
                    Spacer()
                    Text("1.25 목")
                        .foregroundStyle(Color(hex: "#555459"))
                        .font(.medium12)
                        .padding(.leading,5)
                }
                .padding(.top, 15)
                HStack {
                    VStack(alignment:.leading) {
                        Text("호그와트 마법학교")
                            .font(.bold16)
                        Text("서울시 마포구 대흥동")
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
            }
        }.padding(.horizontal, 20)
    }
}

#Preview {
    MemoCard()
}

struct ImageGridView: View {
    @State var proxy: GeometryProxy
    @Binding var imgs: [String]
    var body: some View {
        switch imgs.count {
            
        case 1:
            KFImage(URL(string: imgs[0]))
                .resizable()
                
                .aspectRatio(contentMode: .fill)
        case 2:
            HStack(spacing: 2) {
                KFImage(URL(string: imgs[0]))
                    .resizable()
                    .frame(width: proxy.size.width/2.0)
                    .aspectRatio(contentMode: .fit)
                KFImage(URL(string: imgs[1]))
                    .resizable()
                    .frame(width: proxy.size.width/2.0)
                    .aspectRatio(contentMode: .fit)
            }
        case 3:
            HStack(spacing: 2) {
                KFImage(URL(string: imgs[0]))
                    .resizable()
                    .frame(width: proxy.size.width * 2/3.0)
                    .aspectRatio(contentMode: .fit)
                VStack(spacing:2){
                    KFImage(URL(string: imgs[1]))
                        .resizable()
                        .frame(width: proxy.size.width * 1/3.0)
                        .aspectRatio(contentMode: .fit)
                    KFImage(URL(string: imgs[2]))
                        .resizable()
                        .frame(width: proxy.size.width * 1/3.0)
                        .aspectRatio(contentMode: .fit)
                }
            }
        default:
            HStack(spacing: 2) {
                KFImage(URL(string: imgs[0]))
                    .resizable()
                    .frame(width: proxy.size.width * 2/3.0)
                    .aspectRatio(contentMode: .fit)
                VStack(spacing: 2){
                    KFImage(URL(string: imgs[1]))
                        .resizable()
                        .frame(width: proxy.size.width * 1/3.0)
                        .aspectRatio(contentMode: .fit)
                    KFImage(URL(string: imgs[2]))
                        .resizable()
                        .frame(width: proxy.size.width * 1/3.0)
                        .aspectRatio(contentMode: .fit)
                        .overlay(
                            ZStack{
                                Color.black.opacity(0.6)
                                Text("+\(imgs.count-3)")
                                    .font(.bold18)
                                    .foregroundStyle(Color.white)
                            }
                        )
                }
            }
        }
    }
}
