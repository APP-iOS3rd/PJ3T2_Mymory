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

struct MemoService {
    static let shared = MemoService()
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    // 이미지를 업로드하고 URL을 반환하는 함수
    private func uploadImage(originalImageData: Data) async throws -> String {
        // Data에서 UIImage를 생성
        guard let image = UIImage(data: originalImageData) else {
            throw NSError(domain: "Invalid image data", code: 0, userInfo: nil)
        }

        // UIImage를 압축하여 새로운 Data 객체를 생성
        guard let compressedImageData = image.jpegData(compressionQuality: 0.75) else {
            throw NSError(domain: "Image compression failed.", code: 0, userInfo: nil)
        }

        let storageRef = storage.reference()
        let imageRef = storageRef.child("images/\(UUID().uuidString).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // 압축된 이미지 데이터를 업로드
        let _ = try await imageRef.putData(compressedImageData, metadata: metadata)
        
        // 업로드된 이미지의 URL 가져오기를 몇 번 시도 (처리가 좀 늦는 경우를 대비)
        var downloadURL: URL
        for _ in 1...3 {
            do {
                downloadURL = try await imageRef.downloadURL()
                print("Image uploaded with URL: \(downloadURL.absoluteString)")
                return downloadURL.absoluteString
            } catch {
                print("Retrying to get download URL...")
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1초 대기
            }
        }
        throw URLError(.cannotFindHost) // 적절한 에러 처리 필요
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


    
    // Memo 모델을 넘기자
    func uploadMemo(newMemo: PostMemoModel) async {
        var imageDownloadURLs: [String] = []
        
        // 이미지 데이터 배열을 반복하면서 각 이미지를 업로드하고 URL을 저장
          for imageData in newMemo.memoSelectedImageData {
              do {
                  let imageUrl = try await uploadImage(originalImageData: imageData)
                  imageDownloadURLs.append(imageUrl)
                  print("Image URL added: \(imageUrl)")
              } catch {
                  print("Error uploading image: \(error)")
              }
          }
        
       
        // Firestore에 메모와 이미지 URL을 저장
        do {
            let memoCreatedAtString = stringFromTimeInterval(newMemo.memoCreatedAt)
            let ref = try await db.collection("Memos").addDocument(data: [
                "uid": newMemo.id,
                "userCoordinateLatitude": newMemo.userCoordinateLatitude,
                "userCoordinateLongitude": newMemo.userCoordinateLongitude,
                "userAddress": newMemo.userAddress,
                "memoTitle": newMemo.memoTitle,
                "memoContents": newMemo.memoContents,
                "isPublic": newMemo.isPublic,
                "memoTagList": newMemo.memoTagList,
                "memoLikeCount": newMemo.memoLikeCount,
                "memoSelectedImageURLs": imageDownloadURLs,  // 이미지 URL 배열 저장
                "memoCreatedAt": memoCreatedAtString,
            ])
            print("Document added with ID: \(ref.documentID)")
        } catch {
            print("Error adding document: \(error)")
        }
    }
    
    // Firestore에서 메모들을 가져오는 메서드
       func fetchMemos() async throws -> [PostMemoModel] {
           var memos = [PostMemoModel]()
           
           // "Memos" 컬렉션에서 문서들을 가져옴
           let querySnapshot = try await db.collection("Memos").getDocuments()
           
           // 각 문서를 PostMemoModel로 변환하여 배열에 추가
           for document in querySnapshot.documents {
               let data = document.data()
               
               // 필요한 데이터를 추출하여 PostMemoModel을 생성
               if let id = data["uid"] as? String,
                  let userCoordinateLatitude = data["userCoordinateLatitude"] as? Double,
                  let userCoordinateLongitude = data["userCoordinateLongitude"] as? Double,
                  let userAddress = data["userAddress"] as? String,
                  let memoTitle = data["memoTitle"] as? String,
                  let memoContents = data["memoContents"] as? String,
                  let isPublic = data["isPublic"] as? Bool,
                  let memoTagList = data["memoTagList"] as? [String],
                  let memoLikeCount = data["memoLikeCount"] as? Int,
                  let memoSelectedImageURLs = data["memoSelectedImageURLs"] as? [String],
                  let memoCreatedAt = timeIntervalFromString( data["memoCreatedAt"] as? String ?? "") {

                   let memo = PostMemoModel(
                       id: id,
                       userCoordinateLatitude: userCoordinateLatitude,
                       userCoordinateLongitude: userCoordinateLongitude,
                       userAddress: userAddress,
                       memoTitle: memoTitle,
                       memoContents: memoContents,
                       isPublic: isPublic,
                       memoTagList: memoTagList,
                       memoLikeCount: memoLikeCount,
                       memoSelectedImageData: [], // 이 부분은 실제 URL이나 이미지 데이터로 대체해야 함
                       memoCreatedAt: memoCreatedAt
                   )
                   memos.append(memo)
               }
           }
           
           return memos
       }
}
