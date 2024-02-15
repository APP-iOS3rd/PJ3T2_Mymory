//
//  MemoCard.swift
//  MyMemory
//
//  Created by 김태훈 on 2/1/24.
//

import SwiftUI
import Kingfisher
enum actionType {
    case follow
    case like
    case unAuthorized
    case pinned(successed: Bool)
    case navigate(profile: Profile)
}
struct MemoCard: View {
    
    @Binding var memo: Memo
    @State var isVisible: Bool = true
    @State var isTagExpended: Bool = false
    @State var showImageViewer: Bool = false
    @State var imgIndex: Int = 0
    @Binding var profile: Profile
    @State var isMyPage: Bool = false

    var completion: (actionType) -> ()
    var body: some View {
        
        VStack(alignment: .leading){
            // Pin condition
            if memo.userUid == AuthService.shared.currentUser?.id {
                if isMyPage {
                    HStack{
                        Spacer()
                        Image(systemName: memo.isPinned ? "pin.fill" : "pin")
                            .resizable()
                            .frame(width: 15, height: 20)
                            .onTapGesture {
                                if profile.pinCount < 6 {
                                    if memo.isPinned {
                                        profile.pinCount -= 1
                                    } else {
                                        profile.pinCount += 1
                                    }
                                    memo.isPinned.toggle()
                                    
                                    Task{
                                        await AuthService.shared.pinMyMemo(with:memo)
                                        completion(.pinned(successed: true))
                                    }
                                } else {
                                    //Pin 제한 갯수 알려주는 Alert?
                                    completion(.pinned(successed: false))
                                }
                            }
                    }.padding(.horizontal, 20)
                } else {
                    HStack{
                        Spacer()
                        Text("내 메모")
                    }.padding(.horizontal, 20)
                }
            } else {
                HStack {
                    if let url = profile.profilePicture {
                        Button /* NavigationLink */ {
                            completion(.navigate(profile: profile))
                        } label: {
                            KFImage(URL(string: url))
                                .resizable()
                                .scaledToFill()
                                .clipped()
                                .clipShape(.circle)
                                .frame(width: 37,height: 37)
                                .contentShape(Circle())
                                .cornerRadius(19)
                        }
                    } else {
                        Circle()
                            .frame(width: 37,height: 37)
                    }
                    VStack(alignment: .leading){
                        Text("\(profile.name)")
                            .font(.semibold14)
                            .foregroundStyle(Color.textColor)
                        Text("메모수 \(profile.memoCount) - 팔로워 \(profile.followerCount)")
                            .font(.regular14)
                            .foregroundStyle(Color.textDeepColor)
                    }
                    Spacer()
                    if !isMyPage {
                        Button {
                            if AuthService.shared.currentUser == nil {
                                self.completion(.unAuthorized)
                                return
                            }
                            if self.profile.isFollowing {
                                AuthService.shared.userUnFollow(followUser: profile) { error in
                                    print(error?.localizedDescription)
                                }
                            } else {
                                AuthService.shared.userFollow(followUser: profile) { error in
                                    print(error?.localizedDescription)
                                }
                            }
                            self.profile.isFollowing.toggle()
                            self.completion(.follow)
                        } label: {
                            Text(self.profile.isFollowing ? "팔로잉" : "팔로우")
                        }.buttonStyle(self.profile.isFollowing ? RoundedRect.standard : RoundedRect.follow)
                    }
                }.padding(.horizontal, 20)
            }
            if memo.imagesURL.count > 0 {
                ImageGridView(width: UIScreen.main.bounds.width - 40,
                              touchEvent:$showImageViewer,
                              imgIndex: $imgIndex,
                              imgs: $memo.imagesURL)
                .frame(maxWidth: UIScreen.main.bounds.width - 40, maxHeight: (UIScreen.main.bounds.width - 40) * 1/2)
                .contentShape(Rectangle())
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
                .background(Color.originColor)
                .foregroundColor(.clear)
                .background(Color.deepGray)
                .padding(.top, 13)
                .padding(.horizontal, 20)
                
            }
            HStack {
                Text("\(memo.description)")
                    .multilineTextAlignment(.leading)
                    .font(.medium14)
                    .foregroundColor(.textDarkColor)
                
                Spacer()
            }
            .padding(.top, 15)
            .padding(.horizontal, 20)
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
            .padding(.horizontal, 20)

            HStack {
                Button {
                    if AuthService.shared.currentUser == nil {
                        self.completion(.unAuthorized)
                        return
                    }
                    if !self.memo.didLike {
                        self.memo.likeCount += 1
                        Task{@MainActor in
                            await MemoService.shared.likeMemo(memo: memo)
                        }
                        memo.didLike = true
                        completion(.like)
                    } else {
                        self.memo.likeCount -= 1
                        Task{@MainActor in
                            await MemoService.shared.likeMemo(memo: memo)
                        }
                        memo.didLike = false
                        completion(.like)
                    }
                } label: {
                    // Like condition
                    Image(systemName: memo.didLike ? "heart.fill" : "heart")
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
            }.padding(.horizontal, 20)
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
            ).padding(.horizontal, 20)
            
        }.padding(20)
            .background(Color.originColor)
            .fullScreenCover(isPresented: $showImageViewer) {
                ImgDetailView(selectedImage: $imgIndex, images: memo.imagesURL)
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
    @Binding var imgs: [String]
    var body: some View {
        switch imgs.count {
            
        case 1:
            KFImage(URL(string: imgs[0]))
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
                KFImage(URL(string: imgs[0]))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width/2.0)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        touchEvent.toggle()
                        imgIndex = 0
                    }
                KFImage(URL(string: imgs[1]))
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
                KFImage(URL(string: imgs[0]))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width * 2/3.0)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        touchEvent.toggle()
                        imgIndex = 0
                    }
                VStack(spacing:2){
                    KFImage(URL(string: imgs[1]))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: width * 1/3.0)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            touchEvent.toggle()
                            imgIndex = 1
                        }
                    KFImage(URL(string: imgs[2]))
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
                KFImage(URL(string: imgs[0]))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width * 2/3.0)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        touchEvent.toggle()
                        imgIndex = 0
                    }
                VStack(spacing: 2){
                    KFImage(URL(string: imgs[1]))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: width * 1/3.0)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            touchEvent.toggle()
                            imgIndex = 1
                        }
                    KFImage(URL(string: imgs[2]))
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
