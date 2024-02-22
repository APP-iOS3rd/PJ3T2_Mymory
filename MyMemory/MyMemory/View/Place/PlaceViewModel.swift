//
//  PlaceViewModel.swift
//  MyMemory
//
//  Created by 김소혜 on 2/21/24.
//

import Foundation
import SwiftUI
import Combine
import MapKit
import CoreLocation
import _MapKit_SwiftUI
import KakaoMapsSDK

final class PlaceViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
  
    override init(){
        super.init()
        self.fetchOperation = BlockOperation(block: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.refreshMemos()
            }
        })
    }
    //private var firstLocationUpdated = false
    private var fetchOperation: Operation? = nil
    var firstLocation: CLLocation? {
        didSet{
            fetchMemos()
        }
    }
    
    @Published var location: CLLocation? {
        didSet{
            if location != nil {
                fetchOperation?.start()
            }
            if self.location != nil{
                self.firstLocation = self.location
            }
            
        }
    }

   // = CLLocation(latitude: 37.402101, longitude: 127.108478)
 
    func setLocation(location: CLLocation) {
        self.location = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
      //  print("현재 장소는 \(location)")
    }
    
    let memoService = MemoService.shared
    @Published var isLoading = false
    @Published var buildingName: String = ""
    @Published var placeAddress: String = ""
    
    @Published var memoList: [Memo] = []
    @Published var filterList: Set<String> = Set() {
        didSet {
            filteredMemoList = memoList.filter{ [weak self] memo in
                guard let self = self else { return false }
                if self.filterList.isEmpty { return true }
                var preset = false
                for f in self.filterList {
                    preset = memo.tags.contains(f) || preset
                }
                return preset
            }
        }
    }
    
    @Published var filteredProfileList: [Profile] = []
    @Published var memoWriterList: [Profile] = []
    @Published var filteredMemoList: [Memo] = [] {
        didSet {
            self.filteredProfileList = self.memoWriterList.filter{ profile in
                filteredMemoList.contains(where: {$0.userUid == profile.id})
            }
        }
    }
 
    func fetchMemoProfiles() {
        self.isLoading = true
        Task { @MainActor in
            self.memoWriterList = await AuthService.shared.memoCreatorfetchProfiles(memos: memoList)
            print("이지역 작성자\(memoWriterList)")
            self.isLoading = false
        }
    }

    func fetchMemos() {
        isLoading = true
        guard self.location != nil else {
            isLoading = false
            return
        }
        Task { @MainActor in
            do {
              
                let fetched = try await MemoService.shared.fetchMemos(in: location)
                
                memoList = fetched
                //print("이지역 memoList \(memoList)")
                for (index, memo) in memoList.enumerated() {
                    MemoService.shared.checkLikedMemo(memo) { didLike in
                        self.memoList[index].didLike = didLike
                    }
                }
                self.fetchMemoProfiles()
                isLoading = false
                
            } catch {
                isLoading = false
                print("이지역 Error fetching memos: \(error)")
            }
        }
    }
    
    func refreshMemos(){
        guard self.location != nil else {
            return
        }
        Task { @MainActor in
            do {
                let fetched = try await MemoService.shared.fetchMemos(in: location)
                memoList = fetched
                for (index, memo) in memoList.enumerated() {
                    MemoService.shared.checkLikedMemo(memo) { didLike in
                        self.memoList[index].didLike = didLike
                    }
                }
            } catch {
                print("Error fetching memos: \(error)")
            }
        }
    }
 
    func sortByDistance(_ distance: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            
            memoList.sort(by: {$0.date > $1.date})
            filteredMemoList.sort(by: {$0.date > $1.date})
            
            if filteredProfileList.count == filteredProfileList.count {
                var filtered: [Profile] = []
                
                for (idx, memo) in filteredMemoList.enumerated() {
                    if filteredProfileList[idx].id == memo.userUid {
                        filtered.append(filteredProfileList[idx])
                    } else {
                        if let new = filteredProfileList.first(where: {$0.id == memo.userUid}) {
                            filtered.append(new)
                        }
                    }
                }
                filteredProfileList = filtered
            }
            if memoWriterList.count == memoList.count {
                var temp: [Profile] = []
                
                for (idx, memo) in memoList.enumerated() {
                    if memoWriterList[idx].id == memo.userUid {
                        temp.append(memoWriterList[idx])
                    } else {
                        if let new = memoWriterList.first(where: {$0.id == memo.userUid}) {
                            temp.append(new)
                        }
                    }
                }
                memoWriterList = temp
                
            }
        }
    }
 
}
