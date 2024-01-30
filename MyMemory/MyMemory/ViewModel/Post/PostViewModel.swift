import Foundation
import FirebaseAuth
import CoreLocation
import _PhotosUI_SwiftUI
import _MapKit_SwiftUI
import Combine

class PostViewModel: ObservableObject {
    //@Published var memoData: [PostMemoModel] = []
    //Map 관련
    @Published var mapPosition = MapCameraPosition.userLocation(fallback: .automatic)
    //view로 전달할 값 모음
    @Published var memoTitle: String = ""
    @Published var memoContents: String = ""
    @Published var memoAddressText: String = ""
    @Published var tempAddressText: String = ""
    @Published var memoSelectedImageData: [Data] = []
    @Published var memoSelectedTags: [String] = []
    @Published var memoShare: Bool = false
    @Published var beforeEditMemoImageUUIDs: [String] = [] // 이미지 수정 하면  Firestore 기존 Storage에 이미지를 지우고 업데이트
    @Published var selectedItemsCounts: Int = 0
    let dismissPublisher = PassthroughSubject<Bool, Never>()
    var userCoordinate: CLLocationCoordinate2D? = nil
    
    // 사용자 위치 값 가져오기
    var locationsHandler = LocationsHandler.shared
    
    // 사용자의 현재 위치의 위도와 경도를 가져오는 메서드
   
    func getUserCurrentLocation() {
        locationsHandler.getCurrentLocation { [weak self] location in
            DispatchQueue.main.async {
                if let location = location {
                    print("User's current location - Latitude: \(location.latitude), Longitude: \(location.longitude)")
                    self?.userCoordinate = location
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
        
        DispatchQueue.main.async { [weak self] in
            self?.memoAddressText = addressText
            print("주소 테스트 \(addressText)")
        }
    }
    func getAddress(with loc : Location) {
        Task{ @MainActor in
            let addressText = await GetAddress.shared.getAddressStr(location: .init(longitude: Double(loc.longitude), latitude: Double(loc.latitude)))
            
            DispatchQueue.main.async { [weak self] in
                self?.tempAddressText = addressText
                print("주소 테스트 \(addressText)")
            }
        }
    }
    
    func setAddress() {
        if !tempAddressText.isEmpty {
            self.memoAddressText = self.tempAddressText
        }
    }
    init() {
        // ViewModel이 생성될 때 사용자의 현재 위치를 가져오는 메서드를 호출합니다.
        getUserCurrentLocation()
    }
    
    
    func saveMemo() async {
        do {
            guard let user = AuthViewModel.shared.currentUser else { return }
            let newMemo = PostMemoModel(
                userUid: user.id ?? "",
                userCoordinateLatitude: Double(userCoordinate!.latitude),
                userCoordinateLongitude: Double(userCoordinate!.longitude),
                userAddress: memoAddressText,
                memoTitle: memoTitle,
                memoContents: memoContents,
                isPublic: memoShare,
                memoTagList: memoSelectedTags,
                memoLikeCount: 0,
                memoSelectedImageData: memoSelectedImageData,
                memoCreatedAt: Date().timeIntervalSince1970
            )
            
            await MemoService.shared.uploadMemo(newMemo: newMemo)
            resetMemoFields()
            dismissPublisher.send(true)
            LoadingManager.shared.phase = .success
        } catch {
            // 오류 처리
            LoadingManager.shared.phase = .fail(msg: error.localizedDescription)
            print("Error signing in: \(error.localizedDescription)")
        }
    }


    func fetchEditMemo(memo: Memo)  {
        self.memoTitle = memo.title
        self.memoContents = memo.description
        self.memoAddressText = memo.address
        self.memoSelectedImageData = memo.images
        self.memoSelectedTags = memo.tags
        self.memoShare = memo.isPublic
        self.beforeEditMemoImageUUIDs = memo.memoImageUUIDs
        // memo.location
    }
 
    func editMemo(memo: Memo) async {
        do {
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
                memoSelectedImageData: memoSelectedImageData,
                memoCreatedAt: Date().timeIntervalSince1970
            )
            // 버튼 눌리면  Firestore 기존 Storage에 이미지를 지우고 업데이트
            MemoService.shared.deleteImage(deleteMemoImageUUIDS: beforeEditMemoImageUUIDs)
            await MemoService.shared.updateMemo(documentID: documentID, updatedMemo: editMemo)
            resetMemoFields()
            LoadingManager.shared.phase = .success
        } catch {
            // 오류 처리
            LoadingManager.shared.phase = .fail(msg: error.localizedDescription)
            print("Error signing in: \(error.localizedDescription)")
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
    
    private func resetMemoFields() {
        // 메모 저장 후 필요한 필드 초기화를 여기에 추가하세요.
        memoTitle = ""
        memoContents = ""
        memoAddressText = ""
        memoSelectedImageData = []
        memoSelectedTags = []
        memoShare = false
        selectedItemsCounts = 0
    }
    
    

    

}
