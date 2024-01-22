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

struct MemoService {
    static let shared = MemoService()
    let storage = Storage.storage()
    
    // 이미지를 업로드하고 URL을 반환하는 함수
    private func uploadImage(originalImageData: Data) async throws -> (String, String) {
        guard let image = UIImage(data: originalImageData) else {
            throw NSError(domain: "Invalid image data", code: 0, userInfo: nil)
        }
        
        guard let compressedImageData = image.jpegData(compressionQuality: 0.75) else {
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
            let storageRef = storage.reference()
            for imageName in deleteMemo.memoImageUUIDs {
                let imageRef = storageRef.child("images/\(imageName).jpg")
                imageRef.delete { error in
                    if let error = error {
                        print("Error deleting image: \(error)")
                    } else {
                        print("Image successfully deleted.")
                    }
                }
            }

        } catch {
            print("Error deleting document: \(error)")
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
    
    
    func fetchMyMemos() async -> [Memo] {
        do {
            let authResult = try await Auth.auth().signIn(withEmail: "test@test.com", password: "qwer1234!")
            let userID = authResult.user.uid
            
            let querySnapshot = try await COLLECTION_MEMOS.getDocuments()
            
            var memos = [Memo]()
            
            // 모든 메모를 돌면서 현제 로그인 한 사용자의 uid와 작성자 uid가 같은 것만을 추출해 담아 반환
            for document in querySnapshot.documents {
                let data = document.data()
                
                if let userUid = data["userUid"] as? String, userUid == userID {
                    if let memo = try await fetchMemoFromDocument(documentID: document.documentID, data: data) {
                        memos.append(memo)
                    }
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
            let authResult = try await Auth.auth().signIn(withEmail: "test@test.com", password: "qwer1234!")
            // 로그인 성공한 경우의 코드
            let userID = authResult.user.uid
            
            return checkMemo.userUid == userID
        } catch {
            // 오류 처리
            print("Error signing in: \(error.localizedDescription)")
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
              let memoCreatedAt = timeIntervalFromString(data["memoCreatedAt"] as? String ?? "") else {
            return nil
        }
        
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
            id: UUID(uuidString: documentID) ?? UUID(), // 해당 도큐먼트의 ID를 Memo 객체의 id로 설정
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
    
    
    
}
