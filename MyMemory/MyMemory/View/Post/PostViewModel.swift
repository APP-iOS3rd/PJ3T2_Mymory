import Foundation
import CoreLocation
import _PhotosUI_SwiftUI
import KakaoMapsSDK


class PostViewModel: ObservableObject {
    @Published var memoData: [PostMemoModel] = []
    
    //view로 전달할 값 모음
    @Published var memoTitle: String = ""
    @Published var memoContents: String = ""
    @Published var memoAddressText: String = ""
    @Published var memoSelectedImageData: [Data] = []
    @Published var memoSelectedTags: [String] = []
    @Published var memoShare: Bool = false
    private var userCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 37.5125, longitude: 127.102778)
    
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
        
        
        let addressText = await GetAddress.shared.getAddressStr(location: .init(longitude: Double(userCoordinate.longitude), latitude: Double(userCoordinate.latitude)))
        
        DispatchQueue.main.async { [weak self] in
            self?.memoAddressText = addressText
            print("주소 테스트 \(addressText)")
        }
    }
    
    init() {
        // ViewModel이 생성될 때 사용자의 현재 위치를 가져오는 메서드를 호출합니다.
        getUserCurrentLocation()
    }
    
    
    func saveMemo() async {
        let newMemo = PostMemoModel(
            userCoordinateLatitude: Double(userCoordinate.latitude),
            userCoordinateLongitude: Double(userCoordinate.longitude),
            userAddress: memoAddressText,
            memoTitle: memoTitle,
            memoContents: memoContents,
            isPublic: memoShare,
            memoTagList: memoSelectedTags,
            memoLikeCount: 0,
            memoSelectedImageData: memoSelectedImageData,
            memoCreatedAt: Date().timeIntervalSince1970
        )

        memoData.append(newMemo)
        print(newMemo)
        
        // 메모 저장 후 필요한 초기화 작업 등을 수행할 수 있습니다.
        await MemoService.shared.uploadMemo(newMemo: newMemo)
        resetMemoFields()
    }

    private func resetMemoFields() {
        // 메모 저장 후 필요한 필드 초기화를 여기에 추가하세요.
        memoTitle = ""
        memoContents = ""
        memoAddressText = ""
        memoSelectedImageData = []
        memoSelectedTags = []
        memoShare = false
    }

}
