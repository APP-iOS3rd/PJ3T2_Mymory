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
    @State var following: Bool = false
    @State var memoWriter: User? = nil
    @State var userMemoCount: Int = 0
    @State var userFollowerCount: Int = 0
    var body: some View {
        
        VStack(alignment: .leading){
            // Pin condition
            if memo.userUid == AuthService.shared.currentUser?.id {
                HStack{
                    Spacer()
                    Image(systemName: "pin.fill")
                        .resizable()
                        .frame(width: 15, height: 20)
                }
            } else {
                HStack {
                    if let url = memoWriter?.profilePicture {
                        KFImage(URL(string: url))
                            .resizable()
                            .frame(width: 37,height: 37)
                            .cornerRadius(19)
                    } else {
                        Circle()
                            .frame(width: 37,height: 37)
                    }
                    VStack(alignment: .leading){
                        Text("\(memoWriter?.name ?? "")")
                            .font(.semibold14)
                            .foregroundStyle(Color.textColor)
                        Text("메모수 \(userMemoCount) - 팔로워 \(userFollowerCount)")
                            .font(.regular14)
                            .foregroundStyle(Color.textDeepColor)
                    }
                    Spacer()
                    Button {
                        guard let user = memoWriter else { return }
                        if self.following {
                            AuthService.shared.userUnFollow(followUser: user) { error in
                                print(error?.localizedDescription)
                            }
                        } else {
                            AuthService.shared.userFollow(followUser: user) { error in
                                print(error?.localizedDescription)
                            }
                        }
                        self.following.toggle()

                    } label: {
                        Text(self.following ? "팔로잉" : "팔로우")
                    }.buttonStyle(self.following ? RoundedRect.standard : RoundedRect.follow)
                }
            }
            if memo.images.count > 0 {
                ImageGridView(width: UIScreen.main.bounds.width - 40,
                              touchEvent:$showImageViewer,
                              imgIndex: $imgIndex,
                              imgs: $memo.images)
                .frame(width: UIScreen.main.bounds.width - 40, height: (UIScreen.main.bounds.width - 40) * 1/2)
                .contentShape(Rectangle())

                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
                .background(Color.originColor)
                .foregroundColor(.clear)
                .background(Color.deepGray)
                .padding(.top, 13)

            }
            Text("\(memo.description)")
                .multilineTextAlignment(.leading)
                .font(.medium14)
                .foregroundColor(.textDarkColor)
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
                        .foregroundStyle(Color.textDeepColor)
                        .font(.medium12)
                case 1000... :
                    Text("\(memo.likeCount/1000)k+")
                        .foregroundStyle(Color.textDeepColor)
                        .font(.medium12)
                default:
                    Text("\(memo.likeCount)")
                        .foregroundStyle(Color.textDeepColor)
                        .font(.medium12)
                }
                
                Spacer()
                Text("\(memo.date.toSimpleStr)")
                    .foregroundStyle(Color.textDeepColor)
                    .font(.medium12)
                    .padding(.leading,5)
            }
            .padding(.top, 15)
            HStack {
                VStack(alignment:.leading) {
                    Text("\(memo.title)")
                        .font(.bold16)
                        .foregroundStyle(Color.textColor)
                    Text("\(memo.address)")
                        .font(.regular12)
                        .foregroundStyle(Color.textColor)
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
            .background(Color.originColor)
            .fullScreenCover(isPresented: $showImageViewer) {
                ImgDetailView(selectedImage: $imgIndex, images: memo.images)
            }
            .onAppear{
                AuthService.shared.memoCreatorfetchUser(uid: memo.userUid) { user in
                    self.memoWriter = user
                }
                AuthService.shared.followCheck(with: memo.userUid) { isFollow in
                    self.following = isFollow == true
                }
                Task{ @MainActor in
                    self.userFollowerCount = await AuthService.shared.fetchUserFollowerCount(with: memo.userUid)
                    self.userMemoCount = await AuthService.shared.fetchUserMemoCount(with: memo.userUid)
                }
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
                .contentShape(Rectangle())
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
                    .contentShape(Rectangle())
                    .onTapGesture {
                        touchEvent.toggle()
                        imgIndex = 0
                    }
                Image(uiImage: UIImage(data: imgs[1])!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width/2.0)
                    .contentShape(Rectangle())
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
                    .contentShape(Rectangle())
                    .onTapGesture {
                        touchEvent.toggle()
                        imgIndex = 0
                    }
                VStack(spacing:2){
                    Image(uiImage: UIImage(data: imgs[1])!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: width * 1/3.0)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            touchEvent.toggle()
                            imgIndex = 1
                        }
                    Image(uiImage: UIImage(data: imgs[2])!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: width * 1/3.0)
                        .contentShape(Rectangle())
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
                    .contentShape(Rectangle())
                    .onTapGesture {
                        touchEvent.toggle()
                        imgIndex = 0
                    }
                VStack(spacing: 2){
                    Image(uiImage: UIImage(data: imgs[1])!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: width * 1/3.0)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            touchEvent.toggle()
                            imgIndex = 1
                        }
                    Image(uiImage: UIImage(data: imgs[2])!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: width * 1/3.0)
                        .contentShape(Rectangle())
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
