<div align="center">
    <h1>
      <img src="https://github.com/APP-iOS3rd/PJ3T2_Mymory/assets/144765545/16de6427-3cab-4015-af87-2f2a0e98d8aa" height=30 width=30> 모아MOAH
    </h1>
    <h3><b>당신의 추억, 세상과 함께 빛나다</b></h3>
    <h3>
        <a>
           <img src="https://img.shields.io/badge/language-swift-orange">
        </a>
        <a>
           <img src="https://img.shields.io/badge/launched-febuary%202024-teal">
        </a>
        <a href="https://apps.apple.com/kr/app/%EB%AA%A8%EC%95%84-moah/id6475282904">
            <img alt="iTunes App Store" src="https://img.shields.io/itunes/v/6475282904?label=version">
        </a>
        <a href="https://hits.seeyoufarm.com">
            <img src="https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2FAPPiOS3rd%2FPJ3T2_Mymory&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=hits&edge_flat=false"/>
        </a>
        <a href="#copyright">
            <img src="https://img.shields.io/badge/licence-%C2%A9-crimson">
        </a>
    </h3>
</div>

<div align="center">
<img src="https://github.com/APP-iOS3rd/PJ3T2_Mymory/assets/144765545/04e4bac9-ac01-4890-a5f7-75ef23918f34">

앱스토어: https://shorturl.at/qFMZ8

</br>
</br>
</div>




## 팀원
|[김태훈](https://github.com/iAmSomething)|[김소혜](https://github.com/xohxe)|[김성엽](https://github.com/RapidSloth)|[이명섭](https://github.com/Seobe95)|[여현서](https://github.com/Ahario)|[정정욱](https://github.com/jeonguk29)|
|-----------|-----------|-----------|------------|------------|------------|
|<img src="https://github.com/APP-iOS3rd/PJ3T2_Mymory/assets/144765545/572e6153-d68c-406e-aed8-70c4a661bc4b" width="100">|<img src="https://github.com/APP-iOS3rd/PJ3T2_Mymory/assets/144765545/2eaa3cc6-8db4-4428-8a23-41e4d397c416" width="100">|<img src="https://github.com/APP-iOS3rd/PJ3T2_Mymory/assets/144765545/a8f1fffb-aad3-47b4-90df-61b4dd90c7ec" width="100">|<img src="https://github.com/APP-iOS3rd/PJ3T2_Mymory/assets/144765545/9392566f-44dd-4724-9bfb-c2abe197d9e8" width="100">|<img src="https://github.com/APP-iOS3rd/PJ3T2_Mymory/assets/144765545/f128b3a2-1ceb-43a1-ab61-a5111dccc44c" width="100">|<img src="https://github.com/APP-iOS3rd/PJ3T2_Mymory/assets/144765545/c8ce0a8d-297e-4aac-ad22-8018b2115216" width="100">|

## 프로젝트 소개
[피그마](https://www.figma.com/file/oAlKu3L9x2IlJhmBOGSeVo/%EB%82%B4%EB%AA%A8%EB%A6%AC-%EB%A9%94%EB%AA%BD?type=design&node-id=92%3A3058&mode=design&t=C8ZGjn458Y2uW9zI-1)

- 모아MOAH는 특정 위치에서의 추억을 기록하고 공유하는 SNS입니다.
- 소중한 추억들을 언제 어디서든 쉽게 확인하고 되새길 수 있습니다.
- 내 추억이 깃든 장소에 다른 사람들은 어떤 추억을 남겼는지 확인하고 소통할 수 있습니다.
- 다양한 유저들을 팔로우하며 마음에 드는 게시글을 저장하거나 좋아요를 누를 수 있습니다.

## 기술 스택

### Environment
![Static Badge](https://img.shields.io/badge/xcode-%23147EFB?style=for-the-badge&logo=xcode&logoColor=white)  ![Static Badge](https://img.shields.io/badge/github-%23181717?style=for-the-badge&logo=github&logoColor=white)

### Development
![Static Badge](https://img.shields.io/badge/swift-%23F05138?style=for-the-badge&logo=swift&logoColor=white)   ![Static Badge](https://img.shields.io/badge/firebase-%23FFCA28?style=for-the-badge&logo=firebase&logoColor=white)


### Communication
![Static Badge](https://img.shields.io/badge/Notion-white?style=for-the-badge&logo=notion&logoColor=%23000000)    ![Static Badge](https://img.shields.io/badge/discord-%235865F2?style=for-the-badge&logo=discord&logoColor=white)   ![Static Badge](https://img.shields.io/badge/figma-%23F24E1E?style=for-the-badge&logo=figma&logoColor=white)

### Library
[![Kingfisher](https://img.shields.io/badge/Kingfisher-7.10.2-green)](https://github.com/onevcat/Kingfisher)
[![Alamofire](https://img.shields.io/badge/Alamofire-5.8.1-red)](https://github.com/Alamofire/Alamofire)
[![FLAnimatedImage](https://img.shields.io/badge/FLAnimatedImage-1.0.17-orange)](https://github.com/Flipboard/FLAnimatedImage)


## Firebase 데이터 다이어그램
### User

| 필드명 | Dtype | Nullable | 설명 |
| --- | --- | --- | --- |
| uid | string |  | user ID |
| name | string |  | user 이름 |
| email | string |  | email |
| profilePicture | string |  | Url 값 |
| isCurrentUser |  |  | 현재 로그인한 유저 확인 |
|  |  |  |  |

### User-Memo

| 필드명 | Dtype | Nullable | 설명 |
| --- | --- | --- | --- |
| memolist | [UUID] |  | 내가 작성한 메모 id들 |

### Memo

| 필드명 | Dtype | Nullable | 설명 |
| --- | --- | --- | --- |
| uid | UUID |  | Memo 구분 Uid |
| userCoordinateLatitude | Double |  | Memo 작성 위도 |
| userCoordinateLongitude | Double |  | Memo 작성 경도 |
| userAddress | String |  | 작성 주소 |
| memoTitle | String |  | 제목 |
| memoContents | String |  | 내용 |
| isPublic | Bool |  | 메모 공개여부 |
| memoTagList | [String] |  | 태그 목록 |
| memoLikeCount | Int |  | 좋아요 수 |
| memoSelectedImageData | [Data] |  | 메모 첨부 사진 |
| memoCreatedAt | TimeInterval |  | 작성 시간 |
| userId | string |  | 작성자 UUID |
|  |  |  |  |


## 프로젝트 구조
```
MyMemory
 ┣ API
 ┃ ┣ ImageUploader.swift
 ┃ ┗ MemoService.swift
 ┣ Assets.xcassets
 ┃ ┗ Contents.json
 ┣ Cluster
 ┃ ┣ ClusterBox.swift
 ┃ ┣ Clustering.swift
 ┃ ┗ QuadTree.swift
 ┣ Model
 ┃ ┣ Authentication
 ┃ ┃ ┗ Report.swift
 ┃ ┣ AddressData.swift
 ┃ ┣ AddressModel.swift
 ┃ ┗ User.swift
 ┣ Preview Content
 ┃ ┗ Preview Assets.xcassets
 ┃ ┃ ┗ Contents.json
 ┣ Resource
 ┃ ┣ Animation
 ┃ ┃ ┗ run4.gif
 ┃ ┣ Configure
 ┃ ┃ ┣ GoogleService-Info.plist
 ┃ ┃ ┣ Info.plist
 ┃ ┃ ┣ Localizable.xcstrings
 ┃ ┃ ┗ MyMemory.entitlements
 ┃ ┣ Extension
 ┃ ┃ ┣ Button+Extension.swift
 ┃ ┃ ┣ CLLocation+Extension.swift
 ┃ ┃ ┣ Color+Extension.swift
 ┃ ┃ ┣ NavigationBar+Modifier.swift
 ┃ ┃ ┣ String+Extension.swift
 ┃ ┃ ┗ view+Extension.swift
 ┃ ┣ Fonts
 ┃ ┃ ┣ Pretendard
 ┃ ┃ ┣ NeoDunggeunmo-Regular.ttf
 ┃ ┃ ┣ OwnglyphEuiyeonChae.ttf
 ┃ ┃ ┗ Yeongdeok Sea.otf
 ┃ ┣ Storyboard
 ┃ ┃ ┗ Launch Screen.storyboard
 ┃ ┣ Constants.swift
 ┃ ┗ CornerShape.swift
 ┣ Shared
 ┃ ┣ GetAddress.swift
 ┃ ┣ KakaoMapSimple.swift
 ┃ ┣ LoadingManager.swift
 ┃ ┗ LocationsHandler.swift
 ┣ Source
 ┃ ┣ API
 ┃ ┃ ┣ AuthService.swift
 ┃ ┃ ┣ Constants.swift
 ┃ ┃ ┣ FirebaseProtocol.swift
 ┃ ┃ ┣ ImageUploader.swift
 ┃ ┃ ┗ MemoService.swift
 ┃ ┣ Cluster
 ┃ ┃ ┣ ClusterBox.swift
 ┃ ┃ ┣ Clustering.swift
 ┃ ┃ ┗ QuadTree.swift
 ┃ ┣ Components
 ┃ ┃ ┣ Alert
 ┃ ┃ ┃ ┣ AlertButtonView.swift
 ┃ ┃ ┃ ┗ AlertView.swift
 ┃ ┃ ┣ Button
 ┃ ┃ ┃ ┣ BackButton.swift
 ┃ ┃ ┃ ┣ CloseButton.swift
 ┃ ┃ ┃ ┣ CurrentSpotButton.swift
 ┃ ┃ ┃ ┗ FilterButton.swift
 ┃ ┃ ┣ Memo
 ┃ ┃ ┃ ┣ MemoCard.swift
 ┃ ┃ ┃ ┣ MemoCell.swift
 ┃ ┃ ┃ ┗ MemoList.swift
 ┃ ┃ ┣ FlexibleView.swift
 ┃ ┃ ┣ LoadingView.swift
 ┃ ┃ ┣ MenuTabBar.swift
 ┃ ┃ ┣ ReportMemoView.swift
 ┃ ┃ ┣ SelectBox.swift
 ┃ ┃ ┣ Textarea.swift
 ┃ ┃ ┗ TopBarAddress.swift
 ┃ ┣ Extension
 ┃ ┃ ┣ Button+Extension.swift
 ┃ ┃ ┣ CLLocation+Extension.swift
 ┃ ┃ ┣ Color+Extension.swift
 ┃ ┃ ┣ CornerShape.swift
 ┃ ┃ ┣ Fonts+Extensions.swift
 ┃ ┃ ┣ NavigationBar+Modifier.swift
 ┃ ┃ ┣ String+Extension.swift
 ┃ ┃ ┣ Time+Extensions.swift
 ┃ ┃ ┣ UIApplication+Extesions.swift
 ┃ ┃ ┗ view+Extension.swift
 ┃ ┣ Model
 ┃ ┃ ┣ Authentication
 ┃ ┃ ┃ ┗ Report.swift
 ┃ ┃ ┣ AddressData.swift
 ┃ ┃ ┣ AddressModel.swift
 ┃ ┃ ┣ Memo.swift
 ┃ ┃ ┣ PostMemoModel.swift
 ┃ ┃ ┗ User.swift
 ┃ ┗ Shared
 ┃ ┃ ┣ FontManager.swift
 ┃ ┃ ┣ GetAddress.swift
 ┃ ┃ ┣ ImagePicker.swift
 ┃ ┃ ┣ LoadingManager.swift
 ┃ ┃ ┣ LocationsHandler.swift
 ┃ ┃ ┣ PushNotification.swift
 ┃ ┃ ┗ ThemeManager.swift
 ┣ View
 ┃ ┣ Authentication
 ┃ ┃ ┣ MyPage
 ┃ ┃ ┃ ┣ MapImageMarkerView.swift
 ┃ ┃ ┃ ┣ MyPageView.swift
 ┃ ┃ ┃ ┣ MypageTopView.swift
 ┃ ┃ ┃ ┗ ProfileEditView.swift
 ┃ ┃ ┣ OtherUser
 ┃ ┃ ┃ ┣ OtherUserProfileView.swift
 ┃ ┃ ┃ ┗ OtherUserTopView.swift
 ┃ ┃ ┣ GoogleSocialRegisterView.swift
 ┃ ┃ ┣ LoginView.swift
 ┃ ┃ ┣ LoginViewModel.swift
 ┃ ┃ ┣ MapImageMarkerView.swift
 ┃ ┃ ┣ MyPageEmptyView.swift
 ┃ ┃ ┣ ProfileEditViewModel.swift
 ┃ ┃ ┣ ProfileMemoList.swift
 ┃ ┃ ┣ ProfileMemoListCell.swift
 ┃ ┃ ┣ RegisterView.swift
 ┃ ┃ ┣ RegisterViewModel.swift
 ┃ ┃ ┣ ReportView.swift
 ┃ ┃ ┣ SocialRegisterView.swift
 ┃ ┃ ┗ UserStatusCell.swift
 ┃ ┣ Components
 ┃ ┃ ┣ Button
 ┃ ┃ ┃ ┣ BackButton.swift
 ┃ ┃ ┃ ┣ CloseButton.swift
 ┃ ┃ ┃ ┣ CurrentSpotButton.swift
 ┃ ┃ ┃ ┗ FilterButton.swift
 ┃ ┃ ┣ Memo
 ┃ ┃ ┃ ┣ MemoCell.swift
 ┃ ┃ ┃ ┣ MemoList.swift
 ┃ ┃ ┃ ┗ MemoListView.swift
 ┃ ┃ ┣ FlexibleView.swift
 ┃ ┃ ┣ LoadingView.swift
 ┃ ┃ ┣ SelectBox.swift
 ┃ ┃ ┣ Textarea.swift
 ┃ ┃ ┗ TopBarAddress.swift
 ┃ ┣ Detail
 ┃ ┃ ┣ DetailViewComponent
 ┃ ┃ ┃ ┣ CertificationMap.swift
 ┃ ┃ ┃ ┣ Footer.swift
 ┃ ┃ ┃ ┣ GIFView.swift
 ┃ ┃ ┃ ┣ ImgDetailView.swift
 ┃ ┃ ┃ ┣ MiniMap.swift
 ┃ ┃ ┃ ┣ NavigationBarItems.swift
 ┃ ┃ ┃ ┣ ProgressBarView.swift
 ┃ ┃ ┣ Subviews
 ┃ ┃ ┃ ┣ CertificationView.swift
 ┃ ┃ ┃ ┣ DetailBottomAddressView.swift
 ┃ ┃ ┃ ┣ DetailLockView.swift
 ┃ ┃ ┃ ┣ DetailViewListCell.swift
 ┃ ┃ ┃ ┣ DetailViewMemoMoveButton.swift
 ┃ ┃ ┃ ┣ Footer.swift
 ┃ ┃ ┃ ┣ GIFView.swift
 ┃ ┃ ┃ ┣ ImgDetailView.swift
 ┃ ┃ ┃ ┣ MiniMap.swift
 ┃ ┃ ┃ ┣ MoveUserProfileButton.swift
 ┃ ┃ ┃ ┣ NavigationBarItems.swift
 ┃ ┃ ┃ ┗ ProgressBarView.swift
 ┃ ┃ ┣ CertificationView.swift
 ┃ ┃ ┣ CertificationViewModel.swift
 ┃ ┃ ┣ DetailView.swift
 ┃ ┃ ┣ MemoDetailView.swift
 ┃ ┃ ┣ MoveUserProfileButton.swift
 ┃ ┃ ┗ ReportView.swift
 ┃ ┣ Main
 ┃ ┃ ┣ ContentView.swift
 ┃ ┃ ┣ MainTabView.swift
 ┃ ┃ ┣ MainView.swift
 ┃ ┃ ┗ MemoMapView.swift
 ┃ ┣ Map
 ┃ ┃ ┣ Subviews
 ┃ ┃ ┃ ┣ ClusterSelectionView.swift
 ┃ ┃ ┃ ┣ FileterListView.swift
 ┃ ┃ ┃ ┣ MapView.swift
 ┃ ┃ ┃ ┗ MemoModel.swift
 ┃ ┃ ┣ CommunityView.swift
 ┃ ┃ ┣ KakaoMap.swift
 ┃ ┃ ┣ MainMapView.swift
 ┃ ┃ ┣ MainMapViewModel.swift
 ┃ ┃ ┣ MainSectionsView.swift
 ┃ ┃ ┗ MapViewRepresentable.swift
 ┃ ┣ Onboarding
 ┃ ┃ ┣ Subviews
 ┃ ┃ ┃ ┗ IndexView.swift
 ┃ ┃ ┣ Onboarding.swift
 ┃ ┃ ┣ OnboardingView.swift
 ┃ ┃ ┗ OnboardingViewModel.swift
 ┃ ┣ Post
 ┃ ┃ ┣ Model
 ┃ ┃ ┃ ┗ PostMemoModel.swift
 ┃ ┃ ┣ PostViewComponent
 ┃ ┃ ┃ ┣ FindAddressView.swift
 ┃ ┃ ┃ ┣ SelectPhotos.swift
 ┃ ┃ ┃ ┗ SelectTagView.swift
 ┃ ┃ ┣ Subviews
 ┃ ┃ ┃ ┣ CustomPhotosPicker.swift
 ┃ ┃ ┃ ┣ FindAddressView.swift
 ┃ ┃ ┃ ┣ PostViewFooter.swift
 ┃ ┃ ┃ ┣ SelectPhotos.swift
 ┃ ┃ ┃ ┣ SelectTagView.swift
 ┃ ┃ ┃ ┗ addMemoSubView.swift
 ┃ ┃ ┣ ViewModel
 ┃ ┃ ┃ ┗ PostViewModel.swift
 ┃ ┃ ┣ ChangeLocationView.swift
 ┃ ┃ ┣ PostView.swift
 ┃ ┃ ┣ PostView2.swift
 ┃ ┃ ┗ PostViewModel.swift
 ┃ ┣ Search
 ┃ ┃ ┣ SearchBar.swift
 ┃ ┃ ┣ SearchCell.swift
 ┃ ┃ ┗ SearchView.swift
 ┃ ┗ Setting
 ┃ ┃ ┣ SettingMenu
 ┃ ┃ ┃ ┗ WithdrawalView.swift
 ┃ ┃ ┣ Style
 ┃ ┃ ┃ ┣ FontView.swift
 ┃ ┃ ┃ ┣ MemoThemeView.swift
 ┃ ┃ ┃ ┗ ThemeView.swift
 ┃ ┃ ┣ SubViews
 ┃ ┃ ┃ ┣ SettingMenuCell.swift
 ┃ ┃ ┃ ┗ TermsView.swift
 ┃ ┃ ┣ SettingMenuCell.swift
 ┃ ┃ ┣ SettingView.swift
 ┃ ┃ ┗ SettingViewModel.swift
 ┣ ViewModel
 ┃ ┣ Authentication
 ┃ ┃ ┣ AuthViewModel.swift
 ┃ ┃ ┣ LoginViewModel.swift
 ┃ ┃ ┣ ProfileEditViewModel.swift
 ┃ ┃ ┗ RegisterViewModel.swift
 ┃ ┣ Detail
 ┃ ┃ ┣ CertificationViewModel.swift
 ┃ ┃ ┣ DetailViewModel.swift
 ┃ ┃ ┗ ReportViewModel.swift
 ┃ ┣ Map
 ┃ ┃ ┣ AddressViewModel.swift
 ┃ ┃ ┣ CommunityViewModel.swift
 ┃ ┃ ┗ MainMapViewModel.swift
 ┃ ┣ Onboarding
 ┃ ┃ ┗ OnboardingViewModel.swift
 ┃ ┣ Post
 ┃ ┃ ┣ PhotosViewModel.swift
 ┃ ┃ ┗ PostViewModel.swift
 ┃ ┣ Profile
 ┃ ┃ ┣ MyPage
 ┃ ┃ ┃ ┗ MypageViewModel.swift
 ┃ ┃ ┣ MyProfile
 ┃ ┃ ┃ ┗ MypageViewModel.swift
 ┃ ┃ ┣ OtherUser
 ┃ ┃ ┃ ┗ OtherUserViewModel.swift
 ┃ ┃ ┗ ProfileViewModelProtocol.swift
 ┃ ┣ Setting
 ┃ ┃ ┣ SettingViewModel.swift
 ┃ ┃ ┗ ThemeViewModel.swift
 ┃ ┗ AddressViewModel.swift
 ┣ Launch Screen.storyboard
 ┣ MyMemory.entitlements
 ┣ MyMemoryApp.swift
 ┣ MyMemoryDebug.entitlements
 ┣ SceneDelegate.swift
 ┗ ViewRouter.swift
```


