//
//  MyPageViewModel.swift
//  MyMemory
//
//  Created by 이명섭 on 1/4/24.
//

import Foundation
import _PhotosUI_SwiftUI
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import SwiftUI
import MapKit

class MypageViewModel: ObservableObject, ProfileViewModelProtocol {
    
    @Published var merkerMemoList: [Memo] = []
    @Published var memoList: [Memo] = []
    @Published var selectedFilter = SortedTypeOfMemo.last
    @Published var isShowingOptions = false
    @Published var selectedImage: PhotosPickerItem? = nil
    @Published var selectedPhotoData: Data? = nil
    @Published var isCurrentUserLoginState = false
    
    //  let db = Firestore.firestore()
    let memoService = MemoService.shared
    let locationHandler = LocationsHandler.shared
    @Published var user: User?
    @Published var userProfile: Profile? = nil
    @Published var currentLocation: CLLocation?  = nil
    @Published var isEmptyView = false

    var lastDocument: QueryDocumentSnapshot? = nil
    
    init() {
        fetchUserState()
        self.isCurrentUserLoginState = fetchCurrentUserLoginState()
        fetchUserMemo()

        
        // 해당 코드 블럭 로그인 이후 재 호출필요
        user = AuthService.shared.currentUser
        fetchCurrentUserLocation { location in
            if let location = location {
                self.currentLocation = location
            }
        }
        AuthService.shared.fetchUser{ user in
            self.user = user
        }
    }
    
    func fetchUserMemo(){
        if let userID = UserDefaults.standard.string(forKey: "userId") {
            DispatchQueue.main.async {
                Task {[weak self] in
                    guard let self = self else {return}
                    await self.pagenate(userID: userID)
                }
            }
        }
    }
    func fetchUserProfile() {
        guard let id = user?.id else {return}
        Task {
            self.userProfile = await AuthService.shared.memoCreatorfetchProfile(uid: id)
        }
    }
    
    func fetchCurrentUserLocation(returnCompletion: @escaping (CLLocation?) -> Void) {
        locationHandler.getCurrentLocation { [weak self] location in
            DispatchQueue.main.async {
                if let location = location {
                    print("현재 위치", location)
                    returnCompletion(CLLocation(
                        latitude: location.latitude,
                        longitude: location.longitude
                    ))
                    print("주소 불러오기 완료", LoadingManager.shared.phase)
                } else {
                    returnCompletion(nil)
                }
            }
        }
    }
    /// MypageView에서 사용하는 memolist에 페이지네이션한 개수만큼 추가하는 함수
    /// - Parameters:
    ///     - userID: 사용자 UID
    func pagenate(userID: String) async {
        let fetchedMemos = await self.memoService.fetchMyMemos(userID: userID, lastDocument: self.lastDocument) { last in
            self.lastDocument = last
        }
        
        await MainActor.run {
            self.memoList += fetchedMemos
            self.merkerMemoList = fetchedMemos
            
            self.isEmptyView = self.memoList.isEmpty

        }
    }
    
    // 마이페이지에서 수정, 삭제 에러나지 않도록
    func refreshPagenate() async {
        
        if let userID = UserDefaults.standard.string(forKey: "userId") {
            self.memoList = []
            self.merkerMemoList = []
            let fetchedMemos = await self.memoService.fetchMyMemos(userID: userID, lastDocument: nil) { last in
                self.lastDocument = last
            }
            
            await MainActor.run {
                self.memoList += fetchedMemos
                self.merkerMemoList = fetchedMemos
            }
        }
    }

}
