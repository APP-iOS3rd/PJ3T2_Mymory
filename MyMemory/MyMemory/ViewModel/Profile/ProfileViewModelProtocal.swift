//
//  MemoListViewModel.swift
//  MyMemory
//
//  Created by 정정욱 on 2/2/24.
//

import SwiftUI
import _PhotosUI_SwiftUI
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore



protocol ProfileViewModelProtocal: ObservableObject {
    
    var merkerMemoList: [Memo] { get set } 
    var memoList: [Memo] { get set }
    var selectedFilter: SortedTypeOfMemo { get set }
    var isShowingOptions: Bool { get set }
    var isCurrentUserLoginState: Bool { get set }
    var user: User? { get set }
    var currentLocation: CLLocation? { get set }
    var lastDocument: QueryDocumentSnapshot? { get set }


    func fetchDistanceOfUserAndMemo(myLocation: CLLocationCoordinate2D, memoLocation: Location) -> Double
    func sortMemoList(type: SortedTypeOfMemo)
    func fetchUserState()
    func fetchCurrentUserLoginState() -> Bool
    func fetchCurrentUserLocation(returnCompletion: @escaping (CLLocation?) -> Void)
    func pagenate(userID: String) async
}
