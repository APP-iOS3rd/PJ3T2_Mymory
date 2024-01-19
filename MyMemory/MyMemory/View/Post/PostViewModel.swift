import Foundation
import FirebaseAuth
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
        do {
            let authResult = try await Auth.auth().signIn(withEmail: "test@test.com", password: "qwer1234!")
            // 로그인 성공한 경우의 코드
            let userID = authResult.user.uid
            print("userID \(userID)")
            
            let newMemo = PostMemoModel(
                userUid: userID,
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
            
            print(newMemo)
            
            await MemoService.shared.uploadMemo(newMemo: newMemo)
            resetMemoFields()
        } catch {
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
    }
    
    
    

}
