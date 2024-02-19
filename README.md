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




## 목차
* [프로젝트 소개](#프로젝트-소개)
* [특징](#프로젝트-특징)
* [사용 기술](#사용-기술)
* [기대 효과](#기대-효과)
* [디자인의 방항성](#디자인의-방향성)
* [Firebase](#Firebase-데이터-다이어그램)
* [프로젝트 구조](#프로젝트-구조)


## 프로젝트 소개
**우리는 살아가며 소중한 순간들을 수 없이 마주하지만, 시간이 흐르면서 그 기억들은 점점 흐릿해지고 사라지게 됩니다. 모아MOAH는 소중한 추억들을 생생하게 기록하고 어디서나 볼 수 있는 일기장임과 동시에, 당신의 추억을 다른 사람들과 공유하고 소통할 수 있는 공간입니다.**
- 모아MOAH는 특정 위치에서의 추억을 기록하고 공유하는 SNS입니다.
- 소중한 추억들을 언제 어디서든 쉽게 확인하고 되새길 수 있습니다.
- 내 추억이 깃든 장소에 다른 사람들은 어떤 추억을 남겼는지 확인하고 소통할 수 있습니다.
- 다양한 유저들을 팔로우하며 마음에 드는 게시글을 저장하거나 좋아요를 누를 수 있습니다.


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
MyMemory
...
```


