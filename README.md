# 프로젝트 명 : 나만의 메모리 내모리(가제)

> 나의 추억을 그 장소에 남겨보아요

[베타 앱](https://testflight.apple.com/join/gjLRpOwK)
## 프로젝트 필요성: 내모리를 써야 하는 이유!

1. 내 추억을 되살릴 수 있어요
2. 소중한 추억을 다른 사람들과 공유해 보아요
3. 다른 사람들의 소중한 추억을 함께 보아요
4. 낯선 장소에 가서도 핫플레이스를 바로 알 수 있어요

## 프로젝트 특징

#### 1. 위치 기반으로 메모를 작성하기

- 위치정보를 토대로 그 위치에 메모를 남깁니다.
- 사진과 함께 그 날의 추억을 작성해보아요!
- 여러 가지 태그를 통해 다양한 종류의 추억을 남겨 보아요

#### 2. 게시판 CRUD

- 메모리(게시글)을 관리하고, 태그를 통해 필터링 및 관리 하는 기능을 사용해 보아요!
- 부적절한 메모리(게시글)을 신고 할 수 있어요

#### 3. 추억 되살리고 공유하기

- 특정 시간이 지나고, 메모리를 남긴 장소에 우연히 다가간다면 알림으로 알려줘요!
- 다른 SNS에 공유해서 나의 추억을 되살려 볼 수 있어요

#### 4. 지도 기능 중심 활용

- 다양한 태그별 마크를 지도에 띄워 보아요
- 내 주변에 다른 사람이 남긴 메모리를 보는 등, 지도와 위치 기반 기능들을 사용해요

## 사용 기술

- 맵킷 혹은 NaverMap/ Kakao map
- SwiftUI
- Firebase
  - auth - 계정 관리
  - storage - 사진 관리
  - db - 게시글 관리
## 기대 효과

#### 1. 사용자의 메모데이터를 활용

- 메모를 작성한 위치 정보를 토대로 핫플레이스를 유추할 수 있습니다.
- 포함된 정보를 토대로 새로운 데이터를 창출해낼 수 있습니다.(예를 들어 지역별 키워드)
- 게시판 CRUD 기능을 구현해 볼 수 있습니다.
- 위치 기반 서비스 개발 경험을 얻을 수 있습니다.

#### 2. 앱 출시 경험

- 앱 출시를 할 수 있습니다.

## 디자인의 방항성
[피그마](https://www.figma.com/file/oAlKu3L9x2IlJhmBOGSeVo/%EB%82%B4%EB%AA%A8%EB%A6%AC-%EB%A9%94%EB%AA%BD?type=design&node-id=92%3A3058&mode=design&t=C8ZGjn458Y2uW9zI-1)


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
📦MyMemory
 ┣ 📂API
 ┃ ┣ 📜ImageUploader.swift
 ┃ ┗ 📜MemoService.swift
 ┣ 📂Cluster
 ┃ ┣ 📜ClusterBox.swift
 ┃ ┣ 📜Clustering.swift
 ┃ ┗ 📜QuadTree.swift
 ┣ 📂Model
 ┃ ┣ 📂Authentication
 ┃ ┃ ┗ 📜Report.swift
 ┃ ┣ 📜AddressData.swift
 ┃ ┣ 📜AddressModel.swift
 ┃ ┣ 📜Memo.swift
 ┃ ┗ 📜User.swift
 ┣ 📂Preview Content
 ┃ ┗ 📂Preview Assets.xcassets
 ┃ ┃ ┗ 📜Contents.json
 ┣ 📂Resource
 ┃ ┣ 📂Extension
 ┃ ┃ ┣ 📜Button+Extension.swift
 ┃ ┃ ┣ 📜CLLocation+Extension.swift
 ┃ ┃ ┣ 📜Color+Extension.swift
 ┃ ┃ ┣ 📜Fonts+Extension.swift
 ┃ ┃ ┣ 📜NavigationBar+Modifier.swift
 ┃ ┃ ┣ 📜String+Extension.swift
 ┃ ┃ ┗ 📜view+Extension.swift
 ┃ ┣ 📂Fonts
 ┃ ┃ ┣ 📜Pretendard-Black.otf
 ┃ ┃ ┣ 📜Pretendard-Bold.otf
 ┃ ┃ ┣ 📜Pretendard-ExtraBold.otf
 ┃ ┃ ┣ 📜Pretendard-ExtraLight.otf
 ┃ ┃ ┣ 📜Pretendard-Light.otf
 ┃ ┃ ┣ 📜Pretendard-Medium.otf
 ┃ ┃ ┣ 📜Pretendard-Regular.otf
 ┃ ┃ ┣ 📜Pretendard-SemiBold.otf
 ┃ ┃ ┗ 📜Pretendard-Thin.otf
 ┃ ┣ 📜Constants.swift
 ┃ ┗ 📜CornerShape.swift
 ┣ 📂Shared
 ┃ ┣ 📜GetAddress.swift
 ┃ ┣ 📜KakaoMapSimple.swift
 ┃ ┣ 📜LoadingManager.swift
 ┃ ┗ 📜LocationsHandler.swift
 ┣ 📂View
 ┃ ┣ 📂Authentication
 ┃ ┃ ┣ 📂Mypage
 ┃ ┃ ┃ ┣ 📜MypageMemoList.swift
 ┃ ┃ ┃ ┣ 📜MypageMemoListCell.swift
 ┃ ┃ ┃ ┣ 📜MypageTopView.swift
 ┃ ┃ ┃ ┣ 📜MypageView.swift
 ┃ ┃ ┃ ┗ 📜MypageViewModel.swift
 ┃ ┃ ┣ 📜LoginView.swift
 ┃ ┃ ┣ 📜LoginViewModel.swift
 ┃ ┃ ┣ 📜ProfileEditView.swift
 ┃ ┃ ┣ 📜ProfileEditViewModel.swift
 ┃ ┃ ┣ 📜RegisterView.swift
 ┃ ┃ ┣ 📜RegisterViewModel.swift
 ┃ ┃ ┗ 📜ReportView.swift
 ┃ ┣ 📂Components
 ┃ ┃ ┣ 📂Button
 ┃ ┃ ┃ ┣ 📜BackButton.swift
 ┃ ┃ ┃ ┣ 📜CloseButton.swift
 ┃ ┃ ┃ ┣ 📜CurrentSpotButton.swift
 ┃ ┃ ┃ ┗ 📜FilterButton.swift
 ┃ ┃ ┣ 📂Memo
 ┃ ┃ ┃ ┣ 📜MemoCell.swift
 ┃ ┃ ┃ ┣ 📜MemoList.swift
 ┃ ┃ ┃ ┗ 📜MemoListView.swift
 ┃ ┃ ┣ 📜FlexibleView.swift
 ┃ ┃ ┣ 📜LoadingView.swift
 ┃ ┃ ┣ 📜ReportMemoView.swift
 ┃ ┃ ┣ 📜SelectBox.swift
 ┃ ┃ ┣ 📜Textarea.swift
 ┃ ┃ ┗ 📜TopBarAddress.swift
 ┃ ┣ 📂Detail
 ┃ ┃ ┣ 📂DetailViewComponent
 ┃ ┃ ┃ ┣ 📜CertificationMap.swift
 ┃ ┃ ┃ ┣ 📜Footer.swift
 ┃ ┃ ┃ ┣ 📜GIFView.swift
 ┃ ┃ ┃ ┣ 📜ImgDetailView.swift
 ┃ ┃ ┃ ┣ 📜MiniMap.swift
 ┃ ┃ ┃ ┣ 📜NavigationBarItems.swift
 ┃ ┃ ┃ ┣ 📜ProgressBarView.swift
 ┃ ┃ ┃ ┗ 📜run4.gif
 ┃ ┃ ┣ 📜CertificationView.swift
 ┃ ┃ ┣ 📜CertificationViewModel.swift
 ┃ ┃ ┣ 📜DetailView.swift
 ┃ ┃ ┣ 📜MemoDetailView.swift
 ┃ ┃ ┗ 📜ReportView.swift
 ┃ ┣ 📂Main
 ┃ ┃ ┣ 📜ContentView.swift
 ┃ ┃ ┣ 📜MainTabView.swift
 ┃ ┃ ┣ 📜MainView.swift
 ┃ ┃ ┗ 📜MemoMapView.swift
 ┃ ┣ 📂Map
 ┃ ┃ ┣ 📂Subviews
 ┃ ┃ ┃ ┣ 📜ClusterSelectionView.swift
 ┃ ┃ ┃ ┣ 📜FileterListView.swift
 ┃ ┃ ┃ ┗ 📜MemoModel.swift
 ┃ ┃ ┣ 📜KakaoMap.swift
 ┃ ┃ ┣ 📜MainMapView.swift
 ┃ ┃ ┣ 📜MainMapViewModel.swift
 ┃ ┃ ┗ 📜MapViewRepresentable.swift
 ┃ ┣ 📂Onboarding
 ┃ ┃ ┣ 📜Onboarding.swift
 ┃ ┃ ┣ 📜OnboardingView.swift
 ┃ ┃ ┗ 📜OnboardingViewModel.swift
 ┃ ┣ 📂Post
 ┃ ┃ ┣ 📂Model
 ┃ ┃ ┃ ┗ 📜PostMemoModel.swift
 ┃ ┃ ┣ 📂PostViewComponent
 ┃ ┃ ┃ ┣ 📜FindAddressView.swift
 ┃ ┃ ┃ ┣ 📜PostViewFooter.swift
 ┃ ┃ ┃ ┣ 📜SelectPhotos.swift
 ┃ ┃ ┃ ┣ 📜SelectTagView.swift
 ┃ ┃ ┃ ┗ 📜addMemoSubView.swift
 ┃ ┃ ┣ 📂ViewModel
 ┃ ┃ ┃ ┗ 📜PostViewModel.swift
 ┃ ┃ ┣ 📜ChangeLocationView.swift
 ┃ ┃ ┣ 📜PostView.swift
 ┃ ┃ ┣ 📜PostView2.swift
 ┃ ┃ ┗ 📜PostViewModel.swift
 ┃ ┣ 📂Search
 ┃ ┃ ┣ 📜SearchBar.swift
 ┃ ┃ ┣ 📜SearchCell.swift
 ┃ ┃ ┗ 📜SearchView.swift
 ┃ ┗ 📂Setting
 ┃ ┃ ┣ 📂SettingMenu
 ┃ ┃ ┃ ┗ 📜WithdrawalView.swift
 ┃ ┃ ┣ 📜SettingMenuCell.swift
 ┃ ┃ ┣ 📜SettingView.swift
 ┃ ┃ ┗ 📜SettingViewModel.swift
 ┣ 📂ViewModel
 ┃ ┣ 📂Authentication
 ┃ ┃ ┗ 📜AuthViewModel.swift
 ┃ ┗ 📜AddressViewModel.swift
 ┣ 📜Launch Screen.storyboard
 ┣ 📜MyMemory.entitlements
 ┣ 📜MyMemoryApp.swift
 ┣ 📜SceneDelegate.swift
 ┗ 📜ViewRouter.swift
```


