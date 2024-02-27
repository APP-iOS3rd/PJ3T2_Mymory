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
    @State var isPlacePage: Bool = false
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
                    }
                    .padding(.horizontal, 20)
                } else {
                    HStack{
                        Spacer()
                        Text("내 메모")
                    }
                    //.padding(.horizontal, 20)
                }
            } else {
                HStack {
                    if let url = profile.profilePicture, !url.isEmpty {
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
                        Image("profileImg")
                            .resizable()
                            .frame(width: 37, height: 37)
                            .clipShape(.circle)
                            
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
                }
                
            }
            if memo.imagesURL.count > 0 {
                GeometryReader { geo in
                    ImageGridView(width: geo.size.width,
                                  touchEvent:$showImageViewer,
                                  imgIndex: $imgIndex,
                                  imgs: $memo.imagesURL)
                    .frame(maxWidth: geo.size.width, maxHeight: (geo.size.width) * 1/2)
                    .contentShape(Rectangle())
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(10)
                    .foregroundColor(.clear)
                    .padding(.top, 13)
                    .blur(radius: isPlacePage ? 5.0 : 0.0)
                   
                }
                .frame(height: (UIScreen.main.bounds.width * 3/5))
            }
            HStack {
                if isPlacePage {
                    Text("\(memo.description)")
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                        .font(.medium16)
                        .foregroundColor(.textDarkColor)
                } else {
                    Text("\(memo.description)")
                        .multilineTextAlignment(.leading)
                        .font(.medium16)
                        .foregroundColor(.textDarkColor)
                }
                Spacer()
            }
            .padding(.top, 15)
           // .padding(.horizontal, 20)
            HStack {
                if self.isTagExpended {
                    ForEach(memo.tags, id: \.self) { id in
                        Text("\(id)")
                            .font(.medium12)
                            .foregroundStyle(Color.textColor)
                            .padding(.vertical, 5)
                            .padding(.horizontal,10)
                            .background(Color(UIColor.systemGray5))
                            .cornerRadius(3, corners: .allCorners)
                    }
                } else if !memo.tags.isEmpty{
                    Text("\(memo.tags[0])")
                        .font(.medium12)
                        .foregroundStyle(Color.textColor)
                        .padding(.vertical, 5)
                        .padding(.horizontal,10)
                        .background(Color(UIColor.systemGray5))
                        .cornerRadius(3, corners: .allCorners)
                    if memo.tags.count > 1 {
                        Text("+\(memo.tags.count - 1)")
                            .font(.medium12)
                            .foregroundStyle(Color.textColor)
                            .padding(.vertical, 5)
                            .padding(.horizontal,10)
                            .background(Color(UIColor.systemGray5))
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
                        .font(.medium14)
                case 1000... :
                    Text("\(memo.likeCount/1000)k+")
                        .foregroundStyle(Color.textDeepColor)
                        .font(.medium14)
                default:
                    Text("\(memo.likeCount)")
                        .foregroundStyle(Color.textDeepColor)
                        .font(.medium14)
                }
                
                Spacer()
                Text("\(memo.date.toSimpleStr)")
                    .foregroundStyle(Color.textDeepColor)
                    .font(.medium14)
                    .padding(.leading,5)
            }
            .padding(.top, 15)
            
            if !isPlacePage {
                HStack {
                    VStack(alignment:.leading) {
                        
                        if let buildingName = memo.building, !buildingName.isEmpty {
                            Text(buildingName)
                                .font(.bold16)
                                .foregroundStyle(Color.textColor)
                        } else {
                            Text(lastStr)
                                .font(.bold16)
                                .foregroundStyle(Color.textColor)
                        }
                      
                        Text("\(memo.address)")
                            .font(.regular12)
                            .foregroundStyle(Color.textColor)
                    }
                    Spacer()
                    Button {
                        
                    } label: {
                        VStack{
                            Image(systemName: false ?  "bookmark" : "bookmark.fill")
                        }
                    }
                }
                
                .padding(13)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke()
                        .foregroundStyle(Color.borderColor)
                )
              
            }
            
        }
        .padding(24)
        .background(Color.bgColor)
        .border(width: 1, edges: [.bottom], color: .borderColor)
        .fullScreenCover(isPresented: $showImageViewer) {
            ImgDetailView(selectedImage: $imgIndex, images: memo.imagesURL)
        }
        
       
    }
    var lastStr: String{
        
        // 공백으로 문자열 분할
        let components = self.memo.address.components(separatedBy: " ")
 
        if components.count >= 2 {
            let secondLastComponent = components[components.count - 2]
            return secondLastComponent
        } else {
            return ""
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
                    .frame(width: width * 1/2, height: width * 1/2)
                    .clipped()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        touchEvent.toggle()
                        imgIndex = 0
                    }
                KFImage(URL(string: imgs[1]))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width * 1/2, height: width * 1/2)
                    .contentShape(Rectangle())
                    .clipped()
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
                    .clipped()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        touchEvent.toggle()
                        imgIndex = 0
                    }
                VStack(spacing:2){
                    KFImage(URL(string: imgs[1]))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: width * 1/3, height: width * 1/3)
                        .clipped()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            touchEvent.toggle()
                            imgIndex = 1
                        }
                    KFImage(URL(string: imgs[2]))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: width * 1/3, height: width * 1/3)
                        .clipped()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            touchEvent.toggle()
                            imgIndex = 2
                        }
                }
            }
        default:
            if !imgs.isEmpty{
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
}
