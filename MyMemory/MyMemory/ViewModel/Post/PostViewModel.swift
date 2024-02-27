import Foundation
import FirebaseAuth
import CoreLocation
import _PhotosUI_SwiftUI
import _MapKit_SwiftUI
import Combine

class PostViewModel: ObservableObject {
    //@Published var memoData: [PostMemoModel] = []
    //Map 관련
    @Published var mapPosition: MapCameraPosition
    //view로 전달할 값 모음
    @Published var memoTitle: String = ""
    @Published var memoContents: String = ""
    @Published var memoAddressText: String = ""
    @Published var memoAddressBuildingName: String? = nil
    @Published var tempAddressText: String = ""
    @Published var memoSelectedImageData: [String:Data] = [:]
    @Published var memoSelectedTags: [String] = []
    @Published var memoShare: Bool = false
    @Published var beforeEditMemoImageUUIDs: [String] = [] // 이미지 수정 하면  Firestore 기존 Storage에 이미지를 지우고 업데이트
    @Published var selectedItemsCounts: Int = 0
    @Published var loading: Bool = false
    @Published var uploaded: Bool = false
    @Published var memoTheme: ThemeType = .system
    @Published var memoFont: FontType = .Regular
    @Published var scrollTag: Int = 0
    var fromEdit: Bool = false
    let dismissPublisher = PassthroughSubject<Bool, Never>()
    var userCoordinate: CLLocationCoordinate2D? = nil
    
    // 사용자 위치 값 가져오기
    var locationsHandler = LocationsHandler.shared
    
    // 사용자의 현재 위치의 위도와 경도를 가져오는 메서드
    init() {
        self.mapPosition = MapCameraPosition.userLocation(fallback: .automatic)
        DispatchQueue.main.async {
            if let loc = self.locationsHandler.location{
                self.mapPosition = MapCameraPosition.camera(.init(centerCoordinate: .init(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude), distance: 500))
            } else {
                
                self.mapPosition = MapCameraPosition.userLocation(fallback: .automatic)
            }
        }
            getUserCurrentLocation()
    }
    func getUserCurrentLocation() {
        if let loc = locationsHandler.location {
            self.getAddress(with: .init(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude))
        }
        locationsHandler.getCurrentLocation { [weak self] location in
            DispatchQueue.main.async {
                if let location = location {
                    print("User's current location - Latitude: \(location.latitude), Longitude: \(location.longitude)")
                    if self?.userCoordinate == nil {
                        self?.userCoordinate = location
                    }
                    // 주소 변환 로직이나 추가 작업을 여기에 구현
                    
                    // getUserCurrentLocation 작업이 완료되면 getAddress 호출
                    Task {
                        await self?.getAddress()
                    }
                } else {
                    print("Unable to retrieve user's current location.")
                }
            }
        }
    }
    
    func getAddress() async {
        guard userCoordinate != nil else { return }
        let addressText = await GetAddress.shared.getAddressStr(location: .init(longitude: Double(userCoordinate!.longitude), latitude: Double(userCoordinate!.latitude)))
        let buildingName = await GetAddress.shared.getBuildingStr(location: .init(longitude: Double(userCoordinate!.longitude), latitude: Double(userCoordinate!.latitude)))
        DispatchQueue.main.async { [weak self] in
            
            self?.memoAddressText = addressText
            self?.memoAddressBuildingName = buildingName
            
            print("주소 테스트 \(addressText)")
        }
    }
    func getAddress(with loc : Location) {
        Task{ @MainActor in
            let addressText = await GetAddress.shared.getAddressStr(location: .init(longitude: Double(loc.longitude), latitude: Double(loc.latitude)))
            let buildingName = await GetAddress.shared.getBuildingStr(location: .init(longitude: Double(loc.longitude), latitude: Double(loc.latitude)))
            DispatchQueue.main.async { [weak self] in
                self?.tempAddressText = addressText
                self?.memoAddressBuildingName = buildingName
                print("주소 테스트 \(addressText)")
            }
        }
    }
    
    func setAddress() {
        if !tempAddressText.isEmpty {
            self.memoAddressText = self.tempAddressText
            
        }
    }
    func setLocation(locatioin: CLLocation) {
        self.userCoordinate = locatioin.coordinate
    }
    
    
    func saveMemo() {
        Task{@MainActor in
            
            do {
                loading = true
                guard let user = AuthService.shared.currentUser else {
                    loading = false
                    LoadingManager.shared.phase = .fail(msg: "로그인 중이 아님")
                    return
                }
                let newMemo = PostMemoModel(
                    userUid: user.id ?? "",
                    userCoordinateLatitude: Double(userCoordinate!.latitude),
                    userCoordinateLongitude: Double(userCoordinate!.longitude),
                    userAddress: memoAddressText,
                    userAddressBuildingName: memoAddressBuildingName,
                    memoTitle: memoTitle,
                    memoContents: memoContents,
                    isPublic: !memoShare,
                    memoTagList: memoSelectedTags,
                    memoLikeCount: 0,
                    memoSelectedImageData: Array(memoSelectedImageData.values),
                    memoCreatedAt: Date().timeIntervalSince1970,
                    memoTheme: memoTheme,
                    memoFont: memoFont
                )
                
                do {
                    try await MemoService.shared.uploadMemo(newMemo: newMemo)
                    loading = false
                    LoadingManager.shared.phase = .success
                }
                dismissPublisher.send(true)
                loading = false
                LoadingManager.shared.phase = .success
            } catch {
                // 오류 처리
                loading = false
                LoadingManager.shared.phase = .fail(msg: error.localizedDescription)
                print("Error signing in: \(error.localizedDescription)")
            }
            resetMemoFields()
        }
    }
    
    
    func fetchEditMemo(memo: Memo)  {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.memoTitle = memo.title
            self.memoContents = memo.description
            self.memoAddressText = memo.address
            self.memoAddressBuildingName = memo.building
            self.memoSelectedTags = memo.tags
            self.memoShare = memo.isPublic
            self.beforeEditMemoImageUUIDs = memo.memoImageUUIDs
            self.memoTheme = memo.memoTheme
            self.memoFont = memo.memoFont
            self.fromEdit = true
        }
        
        Task{@MainActor in
            for imageURL in memo.imagesURL {
                guard let url = URL(string: imageURL) else {
                    continue
                }
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    
                    let key = UUID().uuidString
                    self.memoSelectedImageData[key] = data
                } catch {
                    print("Failed to load image data: \(error)")
                }
            }
        }
        // memo.location
    }
    
    func editMemo(memo: Memo) {
        Task{ @MainActor in
            
            do {
                loading = true
                
                // UUID를 String으로 변환 해당 값으로 수정할때 새로 생성하지 않고 업데이트 되도록 구현
                //  let documentID = memo.id.uuidString
                guard let documentID = memo.id else { return }
                /*
                 새로 업데이트 된 내용을 반영시키기 위해 몇몇 부분 Published 된 값으로 다시 생성
                 */
                let editMemo = PostMemoModel(
                    userUid: memo.userUid,
                    userCoordinateLatitude: Double(memo.location.latitude),
                    userCoordinateLongitude: Double(memo.location.longitude),
                    userAddress: memoAddressText,
                    memoTitle: memoTitle,
                    memoContents: memoContents,
                    isPublic: memoShare,
                    memoTagList: memoSelectedTags,
                    memoLikeCount: memo.likeCount,
                    memoSelectedImageData: Array(memoSelectedImageData.values),
                    memoCreatedAt: Date().timeIntervalSince1970,
                    memoTheme: memoTheme,
                    memoFont: memoFont
                )
                // 버튼 눌리면  Firestore 기존 Storage에 이미지를 지우고 업데이트
                MemoService.shared.deleteImage(deleteMemoImageUUIDS: beforeEditMemoImageUUIDs)
                await MemoService.shared.updateMemo(documentID: documentID, updatedMemo: editMemo)
                LoadingManager.shared.phase = .success
                loading = false
                dismissPublisher.send(true)
            } catch {
                // 오류 처리
                loading = false
                
                LoadingManager.shared.phase = .fail(msg: error.localizedDescription)
                print("Error signing in: \(error.localizedDescription)")
            }
            resetMemoFields()
        }
    }
    
    func deleteMemo(memo: Memo) async {
        do{
            //1. UUID를 String으로 변환 해당 값으로 메모를 삭제
            //2. deleteMemo를 굳이 만든 이유 Storage안에 저장 되어있는 메모 이미지를 삭제하기 위함
            guard let documentID = memo.id else { return }
            //.uuidString
            
            await MemoService.shared.deleteMemo(documentID: documentID, deleteMemo: memo)
        }
        catch {
            // 오류 처리
            print("Error signing in: \(error.localizedDescription)")
        }
    }
    
    func resetMemoFields() {
        // 메모 저장 후 필요한 필드 초기화를 여기에 추가하세요.
        memoTitle = ""
        memoContents = ""
        memoAddressText = ""
        memoSelectedImageData = [:]
        memoSelectedTags = []
        memoShare = false
        selectedItemsCounts = 0
        memoTheme = .system
        memoFont = .Regular
    }
}
