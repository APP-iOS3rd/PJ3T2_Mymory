//
//  FirebaseProtocol.swift
//  MyMemory
//
//  Created by 김태훈 on 1/25/24.
//
import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import CoreLocation
import SwiftUI
/// 파이어베이스 관련 사항들을 구성하는 프로토콜
///
/// 파이어베이스를 사용하기 위해서 매핑할 수 있는 Collection type이 필요합니다.
///  
/// 프로토콜을 상속받으면 네 가지 요소들이 필수적으로 구현되어야 합니다.
/// 1. add() -> Create
/// 2. fetch() -> Read
/// 3. update() -> Update
/// 4. delete() -> Delete
protocol FirebaseProtocol{
    associatedtype DataType: Collection where DataType.Element == any Identifiable
    var COLLECTION_USERS: CollectionReference { get }
    var COLLECTION_MEMOS: CollectionReference { get }
    var storage: Storage { get }
    /// Create 하는 함수
    /// - Parameters:
    ///   - new : 새롭게 추가할 데이터 값
    /// - Returns: Result 타입, success(Bool), fail(Error) 로 분기처리
    func add(_ new: Self.DataType.Element) async -> Result<Bool, Error>
    
    /// Update 하는 함수
    /// - Parameters:
    ///   - new : 업데이트 할  데이터 값
    /// - Returns: Result 타입, success(Bool), fail(Error) 로 분기처리
    func update(_ new: Self.DataType.Element) async -> Result<Bool, Error>
    /// Delete 하는 함수
    /// - Returns: Result 타입, success(Bool), fail(Error) 로 분기처리
    func delete() async -> Result<Bool, Error>
    /// fetch 하는 함수
    /// - Returns: Result 타입, success([DataType]), fail(Error) 로 분기처리
    func fetch() async -> Result<Self.DataType, Error>
    
    /// refresh 하는 함수
    /// 이 함수에서는 현재 가지고 있는 DataType 콜렉션을 토대로 DB서버에
    /// 변경사항이 있는 값들만 추출해서 fetch를 수행합니다.
    /// - Parameters:
    ///   - current : refresh할 데이터 값
    /// - Returns: Result 타입, success(Bool), fail(Error) 로 분기처리
    func refresh(current: Self.DataType) async -> Result<Self.DataType, Error>
}
extension FirebaseProtocol {
    
    var COLLECTION_USERS: CollectionReference {
        return Firestore.firestore().collection("users")
    }
    var COLLECTION_MEMOS: CollectionReference {
        return Firestore.firestore().collection("Memos")
    }
    var storage: Storage{
        Storage.storage()
    }
}
//extension FirebaseProtocol where Self: MemoService {
//    typealias DataType = [Memo]
//}
//extension FirebaseProtocol where Self: UserManager {
//    typealias DataType = [User]
//}

