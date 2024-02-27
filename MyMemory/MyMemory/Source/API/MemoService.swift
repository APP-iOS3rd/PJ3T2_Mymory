//
//  MemoService.swift
//  MyMemory
//
//  Created by 정정욱 on 1/17/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore 
import FirebaseStorage
import FirebaseAuth
import CoreLocation
import UIKit
final class MemoService {
    static let shared = MemoService()
    let storage = Storage.storage()
    var queryArea: Double = 500.0
    var readableArea: Double = 100.0
    var notificateArea: Double = 50.0
    init() {
        
        Task {
            let doc = try await COLLECTION_SETTING_VALUE.document("MapArea").getDocument()
            await updateQueryArea(doc["QueryArea"] as? Double ?? 500.0)
            await updateReadableArea(doc["ReadableArea"] as? Double ?? 100.0)
            await updateNotificateArea(doc["NotificateArea"] as? Double ?? 50.0)

        }
    }
    @MainActor
    private func updateQueryArea(_ newValue: Double) {
        self.queryArea = newValue
    }
    @MainActor
    private func updateReadableArea(_ newValue: Double) {
        self.readableArea = newValue
    }
    @MainActor
    private func updateNotificateArea(_ newValue: Double) {
        self.notificateArea = newValue
    }
}
//MARK: - Create Memos
extension MemoService {
    func uploadMemo(newMemo: PostMemoModel) async throws {
        var imageDownloadURLs: [String] = []
        var memoImageUUIDs: [String] = []  // 이미지 UUID를 저장할 배열 생성
        
        // 이미지 데이터 배열을 반복하면서 각 이미지를 업로드하고 URL과 UUID를 저장
        for imageData in newMemo.memoSelectedImageData {
            let (imageUrl, imageUUID) = try await uploadImage(originalImageData: imageData)  // uploadImage 함수가 (URL, UUID) 튜플을 반환하도록 수정
            imageDownloadURLs.append(imageUrl)
            memoImageUUIDs.append(imageUUID)  // 이미지 UUID 저장
            print("Image URL added: \(imageUrl)")
        }
        // 직접 문서 ID를 설정하여 참조 생성
        let memoDocumentRef = COLLECTION_MEMOS.document(newMemo.id) // 저장되는 아이디를 동일하게 맞춰주기
        
        let memoCreatedAtString = stringFromTimeInterval(newMemo.memoCreatedAt)
 
        
        // 생성된 참조에 데이터 저장
        try await memoDocumentRef.setData([
            "userUid" : newMemo.userUid,
            "userCoordinateLatitude": newMemo.userCoordinateLatitude,
            "userCoordinateLongitude": newMemo.userCoordinateLongitude,
            "userAddress": newMemo.userAddress,
            "buildingName": newMemo.userAddressBuildingName ?? "",
            "memoTitle": newMemo.memoTitle,
            "memoContents": newMemo.memoContents,
            "isPublic": newMemo.isPublic,
            "memoTagList": newMemo.memoTagList,
            "memoLikeCount": newMemo.memoLikeCount,
            "memoSelectedImageURLs": imageDownloadURLs,  // 이미지 URL 배열 저장
            "memoImageUUIDs" : memoImageUUIDs,  // 이미지 UUID 배열 저장
            "memoCreatedAt": memoCreatedAtString,
            "createdAtTimeInterval": newMemo.memoCreatedAt,
            "memoTheme": newMemo.memoTheme.rawValue,
            "memoFont": newMemo.memoFont.rawValue
        ])
        
        print("Document added with ID: \(newMemo.id)")
    }

    // 이미지를 업로드하고 URL을 반환하는 함수
    private func uploadImage(originalImageData: Data) async throws -> (String, String) {
        guard let image = UIImage(data: originalImageData) else {
            throw NSError(domain: "Invalid image data", code: 0, userInfo: nil)
        }
        
        guard let compressedImageData = image.jpegData(compressionQuality: 0.2) else {
            throw NSError(domain: "Image compression failed.", code: 0, userInfo: nil)
        }
        
        let storageRef = storage.reference()
        let imageUUID = UUID().uuidString
        let imageRef = storageRef.child("images/\(imageUUID).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let _ = try await imageRef.putData(compressedImageData, metadata: metadata)
        
        var downloadURL: URL
        for _ in 1...3 {
            do {
                downloadURL = try await imageRef.downloadURL()
                print("Image uploaded with URL: \(downloadURL.absoluteString)")
                return (downloadURL.absoluteString, imageUUID)
            } catch {
                print("Retrying to get download URL...")
                try await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
        throw URLError(.cannotFindHost)
    }
}
//MARK: - Read Memos
extension MemoService {
    
    func fetchMemos() async throws -> [Memo] {
        var memos = [Memo]()
        
        // "Memos" 컬렉션에서 문서들을 가져옴
        let querySnapshot = try await COLLECTION_MEMOS
                                            .whereField("reportCount", isLessThan: 5)
                                            .getDocuments()
        
        // 각 문서를 PostMemoModel로 변환하여 배열에 추가
        for document in querySnapshot.documents.filter({doc in
            //공개인지?
            let isPublic = doc["isPublic"] as? Bool ?? true
            let memoUid = doc["userUid"] as? String ?? ""
            //내 메모인지?
            let isMyMemo = memoUid == AuthService.shared.currentUser?.id
            return isPublic || isMyMemo
        }) {
            let data = document.data()
            
            // 문서의 ID를 가져와서 fetchMemoFromDocument 호출
            if var memo = try await fetchMemoFromDocument(documentID: document.documentID, data: data) {
                let likeCount = await likeMemoCount(memo: memo)
                let memoLike = await checkLikedMemo(memo)
                memo.likeCount = likeCount
                memo.didLike = memoLike
                memos.append(memo)
            }
        }
        
        return memos
    }
    func fetchMemo(id: String) async throws -> Memo? {
        let querySnapshot = try await COLLECTION_MEMOS.document(id).getDocument()
        guard let data = querySnapshot.data() else { return nil }
        
        // 문서의 ID를 가져와서 fetchMemoFromDocument 호출
        if var memo = try await fetchMemoFromDocument(documentID: querySnapshot.documentID, data: data) {
            let likeCount = await likeMemoCount(memo: memo)
            let memoLike = await checkLikedMemo(memo)
            memo.likeCount = likeCount
            memo.didLike = memoLike
            return memo
        } else {return nil}
    }
    func fetchMemosOfWeek() async throws -> [Memo] {
        var memos: [Memo] = []
        let week = Date().timeIntervalSince1970 - (86400 * 7)
        do {
            let docs = try await COLLECTION_MEMOS
                .whereField("createdAtTimeInterval", isGreaterThan: week)
//                .order(by: "memoLikeCount", descending: true)
                .getDocuments()
            let filteredDocs = docs.documents.sorted(by: {first, second in
                let firstCount = first["memoLikeCount"] as? Int ?? 0
                let secondCount = second["memoLikeCount"] as? Int ?? 0
                return firstCount > secondCount
            })
            
            for doc in filteredDocs {
                if doc.exists {
                    let data = doc.data()
                    
                    // 문서의 ID를 가져와서 fetchMemoFromDocument 호출
                    if var memo = try await fetchMemoFromDocument(documentID: doc.documentID, data: data) {
                        let likeCount = await likeMemoCount(memo: memo)
                        let memoLike = await checkLikedMemo(memo)
                        memo.likeCount = likeCount
                        memo.didLike = memoLike
                        memos.append(memo)
                        //최대 상위 5개
                        if memos.count == 5 {
                            return memos
                        }
                    }
                }
            }
            
            return memos
        }
        catch {
            print(error.localizedDescription)
            return []
        }
    }
    func fetchBuildingMemos(of buildingName: String) async throws -> [Memo] {
        var memos: [Memo] = []
        let query = try await COLLECTION_MEMOS
            .whereField("buildingName", isEqualTo: buildingName)
            .getDocuments()
        for document in query.documents.filter({doc in
            //공개인지?
            let isPublic = doc["isPublic"] as? Bool ?? true
            let memoUid = doc["userUid"] as? String ?? ""
            //내 메모인지?
            let isMyMemo = memoUid == AuthService.shared.currentUser?.id
            return isPublic || isMyMemo
        }) {
            let data = document.data()
            
            // 문서의 ID를 가져와서 fetchMemoFromDocument 호
            if var memo = try await fetchMemoFromDocument(documentID: document.documentID, data: data) {
                let likeCount = await likeMemoCount(memo: memo)
                let memoLike = await checkLikedMemo(memo)
                memo.likeCount = likeCount
                memo.didLike = memoLike
                memos.append(memo)
            }
        }
        
        return memos
    }

    func buildingList() async throws -> [BuildingInfo]{
        var buildings: [BuildingInfo] = []
        let query = try await COLLECTION_MEMOS
            .order(by: "buildingName")
            .getDocuments()
        for document in query.documents {
            if let lat =  document["userCoordinateLatitude"] as? Double? ?? nil,
            let lon = document["userCoordinateLongitude"] as? Double? ?? nil,
            let name = document["buildingName"] as? String? ?? nil,
            let address = document["userAddress"] as? String{
                if let firstIndex = buildings.firstIndex(where: {$0.buildingName == name}) {
                    let count = buildings[firstIndex].count
                    buildings[firstIndex].count = count + 1
                } else {
                    let building = BuildingInfo(buildingName: name,
                                                address: address,
                                                count: 1,
                                                location: Location(latitude: lat, longitude: lon))
                   
                    buildings.append(building)
                    if buildings.count > 9 {
                        return buildings
                    }
                }
            }
        }  
        return buildings.sorted(by: {$0.count > $1.count})
    }
    // 영역 fetch
    func fetchMemos(_ current: [Memo] = [],in location: CLLocation?) async throws -> [Memo] {
        var memos: [Memo] = current
        var querySnapshot: QuerySnapshot
        let distanceInMeters: CLLocationDistance = self.queryArea
        // "Memos" 컬렉션에서 문서들을 가져옴
        if let location = location {
            let northEastCoordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude + (distanceInMeters / 111111), longitude: location.coordinate.longitude + (distanceInMeters / (111111 * cos(location.coordinate.latitude))))
            let southWestCoordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude - (distanceInMeters / 111111), longitude: location.coordinate.longitude - (distanceInMeters / (111111 * cos(location.coordinate.latitude))))
            // Firestore 쿼리 작성
            let query = COLLECTION_MEMOS
                .whereField("userCoordinateLatitude", isGreaterThanOrEqualTo: southWestCoordinate.latitude)
                .whereField("userCoordinateLatitude", isLessThanOrEqualTo: northEastCoordinate.latitude)
            
            querySnapshot = try await query.getDocuments()
            
            let filteredDocuments = querySnapshot.documents.filter { document in
                let longitude = document["userCoordinateLongitude"] as? Double ?? 0.0
                let reportCount = document["reportCount"] as? Int ?? 0
                // Firestore 쿼리는 부등식 쿼리가 단일 필드에서만 가능하다고 해서, filter 내부에 조건을 추가했습니다.
                if longitude >= southWestCoordinate.longitude && longitude <= northEastCoordinate.longitude && reportCount < 5 {
                    return true
                }
                return false
            }
            
            // 경도 필터링된 문서를 메모로 변환하여 배열에 추가
            for document in filteredDocuments.filter({doc in
                //공개인지?
                let isPublic = doc["isPublic"] as? Bool ?? true
                let memoUid = doc["userUid"] as? String ?? ""
                //내 메모인지?
                let isMyMemo = memoUid == AuthService.shared.currentUser?.id
                return isPublic || isMyMemo
            }) {
                let data = document.data()
                
                // 문서의 ID를 가져와서 fetchMemoFromDocument 호출
                if var memo = try await fetchMemoFromDocument(documentID: document.documentID, data: data) {
                    let likeCount = await likeMemoCount(memo: memo)
                    let memoLike = await checkLikedMemo(memo)
                    memo.likeCount = likeCount
                    memo.didLike = memoLike
                    memos.append(memo)
                }
            }
        } else {
            querySnapshot = try await COLLECTION_MEMOS
                                        .whereField("reportCount", isLessThan: 5)
                                        .getDocuments()
            // 각 문서를 PostMemoModel로 변환하여 배열에 추가
            for document in querySnapshot.documents {
                let data = document.data()
                
                // 문서의 ID를 가져와서 fetchMemoFromDocument 호출
                if var memo = try await fetchMemoFromDocument(documentID: document.documentID, data: data) {
                    let likeCount = await likeMemoCount(memo: memo)
                    let memoLike = await checkLikedMemo(memo)
                    memo.likeCount = likeCount
                    memo.didLike = memoLike
                    memos.append(memo)
                }
            }
        }
        
        //        // 👍 좋아요 누른 메모 체크
        //        for (index, memo) in memos.enumerated() {
        //            checkLikedMemo(memo) { didLike in
        //                print("didLike \(didLike)")
        //                memos[index].didLike = didLike
        //                print("memos[index].didLike \(memos[index].didLike)")
        //            }
        //        }
        
        
        return memos
    }
    
    func fetchPushMemo(_ current: [Memo] = [],in location: CLLocation) async throws -> Memo? {
        var memos: [Memo] = current
        var querySnapshot: QuerySnapshot
        var distanceInMeters: CLLocationDistance = self.notificateArea
        // "Memos" 컬렉션에서 문서들을 가져옴
        let northEastCoordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude + (distanceInMeters / 111111), longitude: location.coordinate.longitude + (distanceInMeters / (111111 * cos(location.coordinate.latitude))))
        let southWestCoordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude - (distanceInMeters / 111111), longitude: location.coordinate.longitude - (distanceInMeters / (111111 * cos(location.coordinate.latitude))))
        // Firestore 쿼리 작성
        let query = COLLECTION_MEMOS
            .whereField("userCoordinateLatitude", isGreaterThanOrEqualTo: southWestCoordinate.latitude)
            .whereField("userCoordinateLatitude", isLessThanOrEqualTo: northEastCoordinate.latitude)
        
        querySnapshot = try await query.getDocuments()
        
        let filteredDocuments = querySnapshot.documents.filter { [weak self]  document in
            let longitude = document["userCoordinateLongitude"] as? Double ?? 0.0
            let reportCount = document["reportCount"] as? Int ?? 0
            // Firestore 쿼리는 부등식 쿼리가 단일 필드에서만 가능하다고 해서, filter 내부에 조건을 추가했습니다.
            if longitude >= southWestCoordinate.longitude && longitude <= northEastCoordinate.longitude && reportCount < 5 {
                return true
            }
            return false
        }
        // 경도 필터링된 문서를 메모로 변환하여 배열에 추가
        for document in filteredDocuments {
            let data = document.data()
            
            // 문서의 ID를 가져와서 fetchMemoFromDocument 호출
            if let memo = try await fetchMemoFromDocument(documentID: document.documentID, data: data) {
                memos.append(memo)
            }
        }
        
        
        return memos.sorted(by: {$0.date > $1.date}).first
    }
    
    /// userID로 작성한 메모들을 모두 가져오는 메서드입니다.
    /// - Parameters:
    ///   - userID : 작성 메모를 모두 가져올 userID
    /// - Returns: [Memo] => userID가 작성한 모든 메모
    func fetchProfileMemos(userID: String) async -> [Memo] {
        do {
            // Memos 컬렉션에서 해당 userID와 일치하는 메모를 쿼리합니다.
            let querySnapshot = try await Firestore.firestore().collection("Memos").whereField("userUid", isEqualTo: userID).getDocuments()
            
            if querySnapshot.documents.isEmpty {
                return []
            }
            
            var memos = [Memo]()
            let documents = querySnapshot.documents.filter({doc in
                //사용자가 지정한 메모들인지?
                let isPinned = doc["isPinned"] as? Bool ?? false
                //내 메모인지?
                let isMyMemo = userID == AuthService.shared.currentUser?.id
                return isPinned || isMyMemo
            })
            // 각 문서를 돌면서 필요한 정보를 추출해 memos 배열에 추가합니다.
            for document in documents{
                let data = document.data()
                if var memo = try await fetchMemoFromDocument(documentID: document.documentID, data: data) {
                    let likeCount = await likeMemoCount(memo: memo)
                    let memoLike = await checkLikedMemo(memo)
                    memo.likeCount = likeCount
                    memo.didLike = memoLike
                    memos.append(memo)
                }
            }
            
            return memos
        } catch {
            // 오류 처리
            print("Error fetching profile memos: \(error.localizedDescription)")
            return []
        }
    }

    
    /// 사용자가 작성한 메모만 불러오는 함수입니다.
    /// - Parameters:
    ///     - userID: 사용자의 UID
    ///     - lastDocument: 불러온 Documents 중 가장 마지막 요소입니다. 이를 활용해 몇번째 메모까지 불렀는지 확인할 수 있습니다.
    ///     - completion: 각 View에서 사용하는 lastDocument에 현재 불러온 lastDocument를 덮어씌우는 closure입니다.
    /// - Returns: 사용자가 작성한 메모들을 lastDocument부터 사용자가 설정한 limits개의 documents를 Memo타입으로 변환하여 [Memo] 타입으로 반환합니다.
    func fetchMyMemos(userID: String, lastDocument: QueryDocumentSnapshot?, completion: (QueryDocumentSnapshot?) -> Void) async -> [Memo] {
        do {
            let querySnapshot = await pagenate(
                query: COLLECTION_MEMOS.whereField("userUid", isEqualTo: userID),
                limit: 5,
                lastDocument: lastDocument
            )
            
            if querySnapshot.documents.isEmpty {
                return []
            }
            
            completion(querySnapshot.documents.last)
            
            var memos = [Memo]()
            
            // 모든 메모를 돌면서 현제 로그인 한 사용자의 uid와 작성자 uid가 같은 것만을 추출해 담아 반환
            for document in querySnapshot.documents {
                let data = document.data()
                if var memo = try await fetchMemoFromDocument(documentID: document.documentID, data: data) {
                    let likeCount = await likeMemoCount(memo: memo)
                    let memoLike = await checkLikedMemo(memo)
                    memo.likeCount = likeCount
                    memo.didLike = memoLike
                    memos.append(memo)
                }
            }
            
            return memos
        } catch {
            // Handle errors
            print("Error signing in: \(error.localizedDescription)")
            return []
        }
    }
    /// 다른사용자가 작성한 메모만 불러오는 함수입니다.
    /// - Parameters:
    ///     - userID: 사용자의 UID
    ///     - lastDocument: 불러온 Documents 중 가장 마지막 요소입니다. 이를 활용해 몇번째 메모까지 불렀는지 확인할 수 있습니다.
    ///     - completion: 각 View에서 사용하는 lastDocument에 현재 불러온 lastDocument를 덮어씌우는 closure입니다.
    /// - Returns: 사용자가 작성한 메모들을 lastDocument부터 사용자가 설정한 limits개의 documents를 Memo타입으로 변환하여 [Memo] 타입으로 반환합니다.
    func fetchMemos(userID: String, lastDocument: QueryDocumentSnapshot?, completion: (QueryDocumentSnapshot?) -> Void) async -> [Memo] {
        do {
            let querySnapshot = await pagenate(
                query: COLLECTION_MEMOS.whereField("userUid", isEqualTo: userID),
                limit: 5,
                lastDocument: lastDocument
            )
            
            if querySnapshot.documents.isEmpty {
                return []
            }
            
            completion(querySnapshot.documents.last)
            
            var memos = [Memo]()
            let documents = querySnapshot.documents.filter({doc in
                //사용자가 지정한 메모들인지?
                let isPinned = doc["isPinned"] as? Bool ?? false
                //내 메모인지?
                let isMyMemo = userID == AuthService.shared.currentUser?.id
                return isPinned || isMyMemo
            })
            // 모든 메모를 돌면서 현제 로그인 한 사용자의 uid와 작성자 uid가 같은 것만을 추출해 담아 반환
            for document in documents {
                let data = document.data()
                if var memo = try await fetchMemoFromDocument(documentID: document.documentID, data: data) {
                    let likeCount = await likeMemoCount(memo: memo)
                    let memoLike = await checkLikedMemo(memo)
                    memo.likeCount = likeCount
                    memo.didLike = memoLike
                    memos.append(memo)
                }
            }
            
            return memos
        } catch {
            // Handle errors
            print("Error signing in: \(error.localizedDescription)")
            return []
        }
    }
    // 보고있는 메모의 작성자 uid와 로그인한 uid가 같다면 나의 메모 즉 수정, 삭제 가능
    func checkMyMemo(checkMemo: Memo) async -> Bool {
        do {
            guard let user = AuthService.shared.currentUser else { return false}
            // 로그인 성공한 경우의 코드
            let userID = user.id
            
            return checkMemo.userUid == userID
            //print("Error signing in: \(error.localizedDescription)")
            // 오류 처리
        } catch {
            return false
        }
    }
    
}
//MARK: - Update Memos
extension MemoService {
    func updateMemo(documentID: String, updatedMemo: PostMemoModel) async {
        var imageDownloadURLs: [String] = []
        var memoImageUUIDs: [String] = []
        
        for imageData in updatedMemo.memoSelectedImageData {
            do {
                let (imageUrl, imageUUID) = try await uploadImage(originalImageData: imageData)
                imageDownloadURLs.append(imageUrl)
                memoImageUUIDs.append(imageUUID)
                print("Image URL added: \(imageUrl)")
            } catch {
                print("Error uploading image: \(error)")
            }
        }
        
        do {
            let memoDocumentRef = COLLECTION_MEMOS.document(documentID)
            let memoCreatedAtString = stringFromTimeInterval(updatedMemo.memoCreatedAt)
            
            try await memoDocumentRef.setData([
                "userUid" : updatedMemo.userUid,
                "userCoordinateLatitude": updatedMemo.userCoordinateLatitude,
                "userCoordinateLongitude": updatedMemo.userCoordinateLongitude,
                "userAddress": updatedMemo.userAddress,
                "memoTitle": updatedMemo.memoTitle,
                "memoContents": updatedMemo.memoContents,
                "isPublic": updatedMemo.isPublic,
                "isPinned": updatedMemo.isPinned,
                "memoTagList": updatedMemo.memoTagList,
                "memoLikeCount": updatedMemo.memoLikeCount,
                "memoSelectedImageURLs": imageDownloadURLs,
                "memoImageUUIDs" : memoImageUUIDs,
                "memoCreatedAt": memoCreatedAtString,
                "createdAtTimeInterval": updatedMemo.memoCreatedAt,
                "memoTheme": updatedMemo.memoTheme.rawValue,
                "memoFont": updatedMemo.memoFont.rawValue
            ], merge: true)
            
            print("Document updated with ID: \(documentID)")
        } catch {
            print("Error updating document: \(error)")
        }
    }
}
//MARK: - Delete Memos
extension MemoService {
    func deleteMemo(documentID: String, deleteMemo: Memo) async {
        do {
            // Firestore에서 문서 삭제
            let memoDocumentRef = COLLECTION_MEMOS.document(documentID)
            try await memoDocumentRef.delete()
            print("Document successfully deleted.")
            
            // Storage에서 이미지 삭제
            deleteImage(deleteMemoImageUUIDS: deleteMemo.memoImageUUIDs)
            
        } catch {
            print("Error deleting document: \(error)")
        }
    }
    
    
    func deleteImage(deleteMemoImageUUIDS: [String]) {
        // Storage에서 이미지 삭제
        let storageRef = storage.reference()
        for imageName in deleteMemoImageUUIDS {
            let imageRef = storageRef.child("images/\(imageName).jpg")
            imageRef.delete { error in
                if let error = error {
                    print("Error deleting image: \(error)")
                } else {
                    print("Image successfully deleted.")
                }
            }
        }
    }
}

//MARK: - Like, Report, Pin
extension MemoService {
    /// 좋아요를 누르는 함수
    /// - Parameters:
    ///   - Memo : 현 사용자가 좋아요를 누를 메모
    /// - Returns: 에러를 리턴
    func likeMemo(memo: Memo) async {
        guard let uid = Auth.auth().currentUser?.uid, let memoID = memo.id else {
            return
        }
        /*
         COLLECTION_MEMO_LIKES 키 값으로 메모 uid 및에 좋아요 누른 사용자 uid들을 저장
         COLLECTION_USER_LIKES 키 값으로 사용자 uid 값에 좋아요 누른 사용자 메모 uid들을 저장
         */
        do {
            if !memo.didLike {
                try await COLLECTION_USER_LIKES.document(uid).updateData([String(memoID ?? "") : FieldValue.delete()])
                try await COLLECTION_MEMO_LIKES.document(memoID).updateData([uid : FieldValue.delete()])
            } else {
                try await COLLECTION_USER_LIKES.document(uid).setData([String(memo.id ?? "") : "LikeMemoUid"], merge: true)
                try await COLLECTION_MEMO_LIKES.document(memo.id ?? "").setData([uid : "LikeUserUid"], merge: true)
            }
            let memocount = await self.likeMemoCount(memo: memo)
            try await COLLECTION_MEMOS.document(memoID).updateData(["memoLikeCount": memocount])
        }catch {
            print(error.localizedDescription)
        }
        /*
         setData 메서드는 주어진 문서 ID에 대해 전체 문서를 설정하거나 대체합니다. 만약 특정 필드만 추가하거나 변경하려면 updateData 메서드를 사용할 수 있습니다.
         
         그러나 updateData는 문서가 이미 존재할 경우에만 작동합니다. 따라서 문서가 존재하지 않을 경우에는 setData를 사용하고, merge 옵션을 true로 설정하여 기존 문서에 데이터를 병합해야 합니다.
         setData 메서드의 두 번째 매개변수로 merge: true를 전달하면 Firestore는 기존 문서와 새 데이터를 병합합니다.
         즉, 특정 필드만 추가하거나 변경하면서도 기존 필드를 유지할 수 있습니다. 만약 문서가 존재하지 않으면 새 문서를 생성합니다.
         */
    }
    /// 좋아요 개수를 표시하는 함수
    /// - Parameters:
    ///   - memo : 해당 메모의 좋아요 총 개수를 표시하는 함수
    /// - Returns: 좋아요 받은 총 개수
    func likeMemoCount(memo: Memo) async -> Int {
        guard let memoID = memo.id else {return 0}
        var likeCount = 0
        
        do {
            let document = try await COLLECTION_MEMO_LIKES.document(memoID).getDocument()
            
            if document.exists {
                let fieldCount = document.data()?.count ?? 0
                likeCount = fieldCount
            }
        } catch {
            print("에러 발생: \(error)")
        }
        
        return likeCount
    }
    
    
    
    func checkLikedMemo(_ memo: Memo) async -> Bool {
        guard let uid = Auth.auth().currentUser?.uid,
              let memoID = memo.id else {
            return false
        }
        do {
            let userLikesRef = try await COLLECTION_USER_LIKES.document(uid).getDocument()
            if userLikesRef.exists,
               let dataArray = userLikesRef.data() as? [String: String] {
                if dataArray.keys.contains(memoID) {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    /// 현재 로그인한 사용자가 보여지는 메모에 좋아요(like)했는지 확인하는 기능을 구현한 함수입니다
    /// - Parameters:
    ///   - memo : 사용자가 좋아요 누른 메모가 맞는지 확인 할 메모
    /// - Returns: 좋아요 누른 여부 ture,false(해당 값을 메모의 didLike에 넣어서 MemoCell의 UI를 표시)
    func checkLikedMemo(_ memo: Memo, completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        let memoID = memo.id ?? ""
        
        let userLikesRef = COLLECTION_USER_LIKES.document(uid)
        userLikesRef.getDocument { (document, error) in
            if let error = error {
                print("사용자 좋아요 문서를 가져오는 중 오류가 발생했습니다: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if let document = document, document.exists, let dataArray = document.data() as? [String: String] {
                if dataArray.keys.contains(memoID) {
                    completion(true)
                } else {
                    completion(false)
                }
            } else {
                completion(false)
            }
        }
    }
    
    /// 메모를 신고하는 기능입니다.
    /// - Parameters:
    ///     - memo: 신고할 메모입니다.
    ///     - type: 신고 종류입니다.
    ///     - reason: 사용자가 입력한 구체적 신고 사유입니다.
    /// - Returns: 신고 성공 시 true를 반환하고, 실패시 각 상황에 맞는 Error를 반환합니다. Error는 invalidMemo, isNotLogin, firebaseError, firebaseError으로 나누어 사용하고 있습니다.
    func fetchReportMemo(memo: Memo, type: String, reason: String) async -> Result<Bool, ReportError> {
        guard let reportedUser = Auth.auth().currentUser else {
            return .failure(.isNotLogin)
        }
        
        guard let memoid = memo.id else {
            return .failure(.invalidMemo)
        }
        
        let reportRef = COLLECTION_MEMO_REPORT.document(memoid)
        let memoRef = COLLECTION_MEMOS.document(memoid)
        
        let memoData: [String : Any] = [
            "types": [type],
            "reasons": [reason],
            "isCompleted": false,
            "reportUserUids": [reportedUser.uid],
            "reportCount": 1
        ]
        
        do {
            let reportDocument = try await reportRef.getDocument()
            // 신고 메모가 이미 신고된 이력이 있을 경우를 위한 분기처리
            if reportDocument.exists {
                let data = reportDocument.data()
                // 신고자의 아이디가 신고자 배열에 속해있는 경우 Error를 반환합니다.
                if let uids = data?["reportUserUids"] as? [String], uids.contains(where: { $0 == reportedUser.uid }) {
                    return .failure(.duplicatedReport)
                }
                // 기존에 신고된 이력이 있는 메모가 다시 신고받는 경우 업데이트 및 성공시 true를 반환합니다.
                try await reportRef.updateData([
                    "types": FieldValue.arrayUnion([type]),
                    "reasons": FieldValue.arrayUnion([reason]),
                    "reportUserUids": FieldValue.arrayUnion([reportedUser.uid]),
                    "reportCount": FieldValue.increment(Int64(1))
                ])
            } else {
                try await reportRef.setData(memoData)
            }
            try await memoRef.updateData([
                "reportCount": FieldValue.increment(Int64(1))
            ])
            return .success(true)
        } catch {
            return .failure(.firebaseError)
        }
    }    
}
//MARK: - Environment
extension MemoService {
    // 사람이 읽기 쉬운 날짜 형태로 파이어베이스에 저장하기 위한 함수
    func stringFromTimeInterval(_ timeInterval: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR") // 한국어 로케일 설정
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 HH시 mm분" // 원하는 날짜 형식
        return dateFormatter.string(from: date)
    }
    
    //  사람이 읽기 쉬운 날짜 형태를 다시 코드상에서 활용하기 좋게 변환 하는 함수
    func timeIntervalFromString(_ dateString: String) -> TimeInterval? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR") // 한국어 로케일 설정
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 HH시 mm분" // 입력받을 날짜 형식
        
        if let date = dateFormatter.date(from: dateString) {
            return date.timeIntervalSince1970
        } else {
            return nil // 문자열이 올바른 날짜 형식이 아닌 경우 nil 반환
        }
    }
    
    // 파이어베이스에서 이미지 저장 URL을 Data타입으로 변환하기 위한 함수
    func downloadImageData(from url: String) async throws -> Data {
        guard let imageURL = URL(string: url) else {
            throw URLError(.badURL)  // Use URLError for invalid URL
        }
        
        let (data, _) = try await URLSession.shared.data(from: imageURL)
        return data
    }
    // Firestore에서 모든 메모들을 가져오는 메서드


    
    // 공통 코드를 기반으로 Memo 객체 생성
    private func fetchMemoFromDocument(documentID: String, data: [String: Any]) async throws -> Memo? {
        guard let userUid = data["userUid"] as? String,
              let userCoordinateLatitude = data["userCoordinateLatitude"] as? Double,
              let userCoordinateLongitude = data["userCoordinateLongitude"] as? Double,
              let userAddress = data["userAddress"] as? String,
              let memoTitle = data["memoTitle"] as? String,
              let memoContents = data["memoContents"] as? String,
              let isPublic = data["isPublic"] as? Bool,
              let memoTagList = data["memoTagList"] as? [String],
              let memoLikeCount = data["memoLikeCount"] as? Int,
              let memoSelectedImageURLs = data["memoSelectedImageURLs"] as? [String],
              let memoImageUUIDs = data["memoImageUUIDs"] as? [String],
              let memoCreatedAt = data["createdAtTimeInterval"] as? Double else { return nil }
 
        let isPinned = data["isPinned"] as? Bool ?? false
        let buildingName = data["buildingName"] as? String? ?? nil
        let memoTheme = data["memoTheme"] as? ThemeType.RawValue ?? "System"
        let memoFont = data["memoFont"] as? FontType.RawValue ?? "Pretendard-Regular"
        // Convert image URLs to Data asynchronously
        /*
         
         withThrowingTaskGroup는 비동기로 실행되는 여러 작업들을 그룹으로 묶어 처리할 수 있게 해주는 Swift의 도구입니다.
         withThrowingTaskGroup를 사용하면 여러 비동기 작업을 병렬로 실행하고, 각 작업이 독립적으로 진행됩니다.
         각 작업은 서로에게 영향을 주지 않고 동시에 진행됩니다.
         
         이 작업 그룹을 사용하면 병렬로 여러 비동기 작업을 실행하고 결과를 모아서 반환할 수 있습니다.
         이 코드를 통해 여러 이미지 URL을 병렬로 처리하여 이미지 데이터를 모아 배열로 만들 수 있습니다.
         이렇게 병렬로 작업을 수행하면 각 이미지를 순차적으로 다운로드하는 것보다 효율적으로 시간을 활용할 수 있습니다.
         */
//        let imageDataArray: [Data] = try await withThrowingTaskGroup(of: Data.self) { group in
//            for url in memoSelectedImageURLs {
//                group.addTask {
//                    return try await downloadImageData(from: url)
//                }
//            }
//            
//            var dataArray = [Data]()
//            for try await data in group {
//                dataArray.append(data)
//            }
//            
//            return dataArray
//        }
        
        let location = Location(latitude: userCoordinateLatitude, longitude: userCoordinateLongitude)
        let memoThemefromString = ThemeType(rawValue: memoTheme) ?? .system
        let memoFontfromString = FontType(rawValue: memoFont) ?? .Regular
        
        return Memo(
            //  id: UUID(uuidString: documentID) ?? UUID(), // 해당 도큐먼트의 ID를 Memo 객체의 id로 설정
            id: documentID,
            userUid: userUid,
            title: memoTitle,
            description: memoContents,
            address: userAddress,
            building: buildingName,
            tags: memoTagList,
            imagesURL: memoSelectedImageURLs,
            isPublic: isPublic,
            isPinned: isPinned,
            date: memoCreatedAt,
            location: location,
            likeCount: memoLikeCount,
            memoImageUUIDs: memoImageUUIDs,
            memoTheme: memoThemefromString,
            memoFont: memoFontfromString
        )
    }
    

    
    /// firestore의 Document를 페이지네이션화하는 함수. 기본적으로 최신순으로 데이터를 받아온다.
    /// - Parameters:
    ///     - query: Document Query
    ///     - limit: fetch 시 받아올 데이터의 개수
    ///     - lastDocument: 현재 불러온 데이터의 마지막 요소. 이 파라미터를 통해 query의 커서(불러올 순서)를 정할 수 있다.
    /// - Returns: query에서 정렬된 Documents들을 lastDocument부터 limits의 값만큼 Return
    func pagenate(query: Query, limit: Int, lastDocument: QueryDocumentSnapshot?) async -> QuerySnapshot {  
        do {
            var query: Query = query.order(by: "memoCreatedAt", descending: true)
                .limit(to: limit)
            
            if let lastDocument = lastDocument {
                query = query.start(afterDocument: lastDocument)
            }
            
            let querySnapshot = try await query.getDocuments()
            
            return querySnapshot
        } catch {
            fatalError("ERROR: querysnapshot \(error)")
        }
    }
    
    
    /// 사용자의 모든 기록을 지우는 메서드
    /// - Parameters:
    ///   - uid : 모든 기록을 삭제할 현재 사용자 uid 값
    /// - Returns: 없음
    func removeUserAllData(uid: String) {
        /*
           Memos - 사용자가 작성한 메모 지우기
           Memo-likes - 사용자가 작성한 메모 좋아요, 기록 지우기
           User-likes - 사용자가 좋아요. 누른 기록 지우기
           User-Following - 사용자가 팔로잉하는 목록 지우기
           User-Followers - 사용자를 팔로우하는 목록 지우기
           users - 사용자 지우기
           Authentication - 사용자 인증 기록 지우기
         
         */
        Task {
            self.removeMemoData(uid: uid)
            self.removeUserLikes(uid: uid)
            self.removeUserFollowingAndFollowData(uid: uid)
            let deleteImageResult = await AuthService.shared.removeUserProfileImage(uid: uid)
            if let _ = try? deleteImageResult.get() {
                print("사진 삭제 성공")
            }
            self.removeUser(uid: uid)
        }
        // Authentication 계정 삭제
        if let currentUser = Auth.auth().currentUser {
            currentUser.delete { error in
                if let error = error {
                    print("사용자 삭제 실패: \(error.localizedDescription)")
                } else {
                    print("사용자 삭제 성공")
                }
            }
        } else {
            print("현재 로그인된 사용자가 없습니다.")
        }
      
    }

    /// 사용자가 작성한 메모, 좋아요 누른 메모 기록 지우기
    /// - Parameters:
    ///   - uid : 모든 기록을 삭제할 현재 사용자 uid 값
    /// - Returns: 없음
    /*
     동작 원리
       1. 내 메모 지우기전 Storage에 저장된 메모 이미지 지우기
       2. 매모 삭제
       3. 내 메모 좋아요 기록 지우기
       4. 내가 다른 메모에 누른 좋아요 기룩 지우기
     */
    func removeMemoData(uid: String) {

        // Memos 컬렉션에서 문서를 가져와서 조건을 확인하고 삭제
        COLLECTION_MEMOS.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }

            // Memos 컬렉션의 각 문서에 대해 조건 확인 후 삭제
            for document in documents {
                // 문서의 데이터 가져오기
                let data = document.data()

                // 데이터 중 userUid 필드와 주어진 uid가 일치하는지 확인
                if let userUid = data["userUid"] as? String, userUid == uid {
                    // 일치하는 경우 해당 문서 삭제
                    let memoID = document.documentID
                    if let memoImageUUIDs = data["memoImageUUIDs"] as? [String] {
                        // 메모 이미지 UUIDs를 deleteImage 함수에 전달하여 이미지 삭제
                        MemoService.shared.deleteImage(deleteMemoImageUUIDS: memoImageUUIDs)
                    }

                    COLLECTION_MEMOS.document(memoID).delete { error in
                        if let error = error {
                            print("Error removing Memo document: \(error)")
                        } else {
                            print("Memo document successfully removed!")

                            // Memo-likes 컬렉션에서도 해당 Memo에 대한 문서 삭제
                            self.removeMemoLikes(memoID: memoID)
                        }
                    }
                }
            }
        }
        
        
        // 내가 다른 메모에 누른 좋아요 기룩 삭제
        COLLECTION_MEMO_LIKES.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting Memo Likes documents: \(error)")
                return
            }
            
            guard let memoLikesDocuments = snapshot?.documents else {
                print("No Memo Likes documents found")
                return
            }
            
            
            // 별도 분리 필요 위에는 메모 삭제할때이고 사용자 uid 값으로 파악하고 지워야함
            // Memo Likes 컬렉션의 각 문서에서 memoID 필드 삭제 또는 문서 삭제
            for memoLikesDocument in memoLikesDocuments {
                let documentData = memoLikesDocument.data()
                
                // 마지막 필드인 경우 문서 삭제
                print("documentData : \(documentData)")
                print("uid : \(uid)")
                
                if documentData.count == 1 && documentData.contains(where: { $0.key == uid }) {
                    memoLikesDocument.reference.delete { error in
                        if let error = error {
                            print("Error deleting Memo Likes document: \(error)")
                        } else {
                            print("Memo Likes document successfully deleted!")
                        }
                    }
                } else {
                    // 마지막 필드가 아닌 경우 memoID 필드 삭제
                    var updatedData = documentData
                    updatedData.removeValue(forKey: uid)
                    
                    memoLikesDocument.reference.updateData(updatedData) { error in
                        if let error = error {
                            print("Error removing field from Memo Likes document: \(error)")
                        } else {
                            print("Field successfully removed from Memo Likes document!")
                        }
                    }
                }
            }
        }
        
    }


    /// 사용자가 작성한 메모의 받은 좋아요 기록을 삭제하는 메서드
    /// - Parameters:
    ///   - memoID  : 삭제할 사용자가 작성한 메모의 ID
    /// - Returns: 없음
    func removeMemoLikes(memoID: String) {
        
        COLLECTION_MEMO_LIKES.document(memoID).delete { error in
            if let error = error {
                print("Error removing Memo-likes document: \(error)")
            } else {
                print("Memo-likes document successfully removed!")
            }
        }
    }

    

    /// 사용자가 누른 메모 기록을 삭제하는 메서드
    /// - Parameters:
    ///   - uid  : 삭제할 사용자가 누른 메모 기록
    /// - Returns: 없음
    func removeUserLikes(uid: String) {
        // User-likes 컬렉션에서 uid가 일치하는 문서 삭제
        COLLECTION_USER_LIKES.document(uid).delete { error in
            if let error = error {
                print("Error removing Memo-likes document: \(error)")
            } else {
                print("Memo-likes document successfully removed!")
            }
        }
        
    }

    
    

    /// 사용자가 팔로잉한 사용자를 팔로우한 사람들의 데이터를 삭제하는 메서드
    /// - Parameters:
    ///   - uid : 팔로우, 팔로잉 기록을 삭제할 uid
    /// - Returns: 없음
    func removeUserFollowingAndFollowData(uid: String) {
        // User-Following 컬렉션에서 uid가 일치하는 문서 삭제
        COLLECTION_USER_Following.document(uid).delete { error in
            if let error = error {
                print("Error removing Memo-likes document: \(error)")
            } else {
                print("Memo-likes document successfully removed!")
            }
        }
        
        
        
        // User-Followers 컬렉션에서 uid가 일치하는 문서의 필드 삭제 또는 문서 삭제 (필드가 하나 밖에 없다면 필드만 삭제 할 수 없음)
        COLLECTION_USER_Followers.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting Followers documents: \(error)")
                return
            }
            
            guard let followersDocuments = snapshot?.documents else {
                print("No Followers documents found")
                return
            }
            
            // User-Followers 컬렉션의 각 문서에서 uid 필드 삭제 또는 문서 삭제
            for followersDocument in followersDocuments {
                let documentData = followersDocument.data()
                
                // 마지막 필드인 경우 문서 삭제
                if documentData.count == 1 && documentData.contains(where: { $0.key == uid }) {
                    followersDocument.reference.delete { error in
                        if let error = error {
                            print("Error deleting Followers document: \(error)")
                        } else {
                            print("Followers document successfully deleted!")
                        }
                    }
                } else {
                    // 마지막 필드가 아닌 경우 uid 필드 삭제
                    var updatedData = documentData
                    updatedData.removeValue(forKey: uid)
                    
                    followersDocument.reference.updateData(updatedData) { error in
                        if let error = error {
                            print("Error removing field from Followers document: \(error)")
                        } else {
                            print("Field successfully removed from Followers document!")
                        }
                    }
                }
            }
        }
    }


    /// 사용자 삭제 메서드
    /// - Parameters:
    ///   - uid : users 컬렉션에서 사용자 삭제를 위한 메서드
    /// - Returns: 없음
    func removeUser(uid: String) {
        // users 컬렉션에서 uid와 일치하는 문서를 찾아 삭제
        
        COLLECTION_USERS.document(uid).delete { error in
            if let error = error {
                print("Error removing Memo-likes document: \(error)")
            } else {
                print("Memo-likes document successfully removed!")
            }
        }
    }
}
