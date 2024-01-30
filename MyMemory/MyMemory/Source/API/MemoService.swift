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
struct MemoService {
    static let shared = MemoService()
    let storage = Storage.storage()
    
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
            //print("memoCreatedAt\(memoCreatedAt)")
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
    
    
    
    
    // Memo 모델을 넘기자
    func uploadMemo(newMemo: PostMemoModel) async {
        var imageDownloadURLs: [String] = []
        var memoImageUUIDs: [String] = []  // 이미지 UUID를 저장할 배열 생성
        
        // 이미지 데이터 배열을 반복하면서 각 이미지를 업로드하고 URL과 UUID를 저장
           for imageData in newMemo.memoSelectedImageData {
               do {
                   let (imageUrl, imageUUID) = try await uploadImage(originalImageData: imageData)  // uploadImage 함수가 (URL, UUID) 튜플을 반환하도록 수정
                   imageDownloadURLs.append(imageUrl)
                   memoImageUUIDs.append(imageUUID)  // 이미지 UUID 저장
                   print("Image URL added: \(imageUrl)")
               } catch {
                   print("Error uploading image: \(error)")
               }
           }
        
        do {
               // 직접 문서 ID를 설정하여 참조 생성
               let memoDocumentRef = COLLECTION_MEMOS.document(newMemo.id) // 저장되는 아이디를 동일하게 맞춰주기
               
               let memoCreatedAtString = stringFromTimeInterval(newMemo.memoCreatedAt)
               
               // 생성된 참조에 데이터 저장
               try await memoDocumentRef.setData([
                   "userUid" : newMemo.userUid,
                   "userCoordinateLatitude": newMemo.userCoordinateLatitude,
                   "userCoordinateLongitude": newMemo.userCoordinateLongitude,
                   "userAddress": newMemo.userAddress,
                   "memoTitle": newMemo.memoTitle,
                   "memoContents": newMemo.memoContents,
                   "isPublic": newMemo.isPublic,
                   "memoTagList": newMemo.memoTagList,
                   "memoLikeCount": newMemo.memoLikeCount,
                   "memoSelectedImageURLs": imageDownloadURLs,  // 이미지 URL 배열 저장
                   "memoImageUUIDs" : memoImageUUIDs,  // 이미지 UUID 배열 저장
                   "memoCreatedAt": memoCreatedAtString,
               ])
            
            print("Document added with ID: \(newMemo.id)")
        } catch {
            print("Error adding document: \(error)")
        }
    }
    
    
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
                "memoTagList": updatedMemo.memoTagList,
                "memoLikeCount": updatedMemo.memoLikeCount,
                "memoSelectedImageURLs": imageDownloadURLs,
                "memoImageUUIDs" : memoImageUUIDs,
                "memoCreatedAt": memoCreatedAtString,
            ], merge: true)
            
            print("Document updated with ID: \(documentID)")
        } catch {
            print("Error updating document: \(error)")
        }
    }

    
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
    
    
    
    
    
    // Firestore에서 모든 메모들을 가져오는 메서드
    
    func fetchMemos() async throws -> [Memo] {
        var memos = [Memo]()
        
        // "Memos" 컬렉션에서 문서들을 가져옴
        let querySnapshot = try await COLLECTION_MEMOS.getDocuments()
        
        // 각 문서를 PostMemoModel로 변환하여 배열에 추가
        for document in querySnapshot.documents {
            let data = document.data()
            
            // 문서의 ID를 가져와서 fetchMemoFromDocument 호출
            if let memo = try await fetchMemoFromDocument(documentID: document.documentID, data: data) {
                memos.append(memo)
            }
        }
        
        return memos
    }
    // 영역 fetch
    func fetchMemos(_ current: [Memo] = [],in location: CLLocation?, withRadius distanceInMeters: CLLocationDistance = 1000) async throws -> [Memo] {
        var memos: [Memo] = current
        var querySnapshot: QuerySnapshot
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
                return longitude >= southWestCoordinate.longitude && longitude <= northEastCoordinate.longitude
            }
            // 경도 필터링된 문서를 메모로 변환하여 배열에 추가
            for document in filteredDocuments {
                let data = document.data()
                
                // 문서의 ID를 가져와서 fetchMemoFromDocument 호출
                if let memo = try await fetchMemoFromDocument(documentID: document.documentID, data: data) {
                    memos.append(memo)
                }
            }
        } else {
            querySnapshot = try await COLLECTION_MEMOS.getDocuments()
            // 각 문서를 PostMemoModel로 변환하여 배열에 추가
            for document in querySnapshot.documents {
                let data = document.data()
                
                // 문서의 ID를 가져와서 fetchMemoFromDocument 호출
                if let memo = try await fetchMemoFromDocument(documentID: document.documentID, data: data) {
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
    func fetchMyMemos(userID: String) async -> [Memo] {
        do {
            let querySnapshot = try await COLLECTION_MEMOS.whereField("userUid", isEqualTo: userID).getDocuments()
            var memos = [Memo]()
            
            // 모든 메모를 돌면서 현제 로그인 한 사용자의 uid와 작성자 uid가 같은 것만을 추출해 담아 반환
            for document in querySnapshot.documents {
                let data = document.data()
                if let memo = try await fetchMemoFromDocument(documentID: document.documentID, data: data) {
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
            guard let user = AuthViewModel.shared.currentUser else { return false}
            // 로그인 성공한 경우의 코드
            let userID = user.id
            
            return checkMemo.userUid == userID
            //print("Error signing in: \(error.localizedDescription)")
            // 오류 처리
        } catch {
            return false
        }
    }
    
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
              let memoCreatedAt = timeIntervalFromString(data["memoCreatedAt"] as? String ?? "") else { return nil }
        
        // Convert image URLs to Data asynchronously
        /*
         
         withThrowingTaskGroup는 비동기로 실행되는 여러 작업들을 그룹으로 묶어 처리할 수 있게 해주는 Swift의 도구입니다.
         withThrowingTaskGroup를 사용하면 여러 비동기 작업을 병렬로 실행하고, 각 작업이 독립적으로 진행됩니다.
         각 작업은 서로에게 영향을 주지 않고 동시에 진행됩니다.
         
         이 작업 그룹을 사용하면 병렬로 여러 비동기 작업을 실행하고 결과를 모아서 반환할 수 있습니다.
         이 코드를 통해 여러 이미지 URL을 병렬로 처리하여 이미지 데이터를 모아 배열로 만들 수 있습니다.
         이렇게 병렬로 작업을 수행하면 각 이미지를 순차적으로 다운로드하는 것보다 효율적으로 시간을 활용할 수 있습니다.
         */
        let imageDataArray: [Data] = try await withThrowingTaskGroup(of: Data.self) { group in
            for url in memoSelectedImageURLs {
                group.addTask {
                    return try await downloadImageData(from: url)
                }
            }
            
            var dataArray = [Data]()
            for try await data in group {
                dataArray.append(data)
            }
            
            return dataArray
        }
        
        let location = Location(latitude: userCoordinateLatitude, longitude: userCoordinateLongitude)
        
        return Memo(
          //  id: UUID(uuidString: documentID) ?? UUID(), // 해당 도큐먼트의 ID를 Memo 객체의 id로 설정
            id: documentID,
            userUid: userUid,
            title: memoTitle,
            description: memoContents,
            address: userAddress,
            tags: memoTagList,
            images: imageDataArray,
            isPublic: isPublic,
            date: memoCreatedAt,
            location: location,
            likeCount: memoLikeCount, 
            memoImageUUIDs: memoImageUUIDs
        )
    }
    
 
    /// 좋아요를 누르는 함수
    /// - Parameters:
    ///   - Memo : 현 사용자가 좋아요를 누를 메모
    /// - Returns: 에러를 리턴
    func likeMemo(memo: Memo, completion: @escaping (Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid, let memoID = memo.id else {
            completion(NSError(domain: "Auth Error", code: 401, userInfo: nil))
            return
        }
        
        /*
         COLLECTION_MEMO_LIKES 키 값으로 메모 uid 및에 좋아요 누른 사용자 uid들을 저장
         COLLECTION_USER_LIKES 키 값으로 사용자 uid 값에 좋아요 누른 사용자 메모 uid들을 저장
         */
        if memo.didLike {
                COLLECTION_USER_LIKES.document(uid).updateData([String(memo.id ?? "") : FieldValue.delete()])
                COLLECTION_MEMO_LIKES.document(memo.id ?? "").updateData([uid : FieldValue.delete()])
            } else {
                COLLECTION_USER_LIKES.document(uid).setData([String(memo.id ?? "") : "LikeMemoUid"], merge: true)
                COLLECTION_MEMO_LIKES.document(memo.id ?? "").setData([uid : "LikeUserUid"], merge: true)
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
        let memoID = memo.id ?? ""
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
        
        print(likeCount)
        return likeCount
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
                print("데이터 \(dataArray)")
                print("메모 ID \(memoID)")
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




    
}
