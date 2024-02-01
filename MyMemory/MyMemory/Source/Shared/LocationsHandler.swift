//
//  LocationsHandler.swift
//  MyMemory
//
//  Created by 정정욱 on 1/18/24.
//

import Foundation
import CoreLocation
import Combine
import UserNotifications
// 💁 사용자 위치추적 및 권한허용 싱글톤 구현 위치 임시지정
class LocationsHandler: NSObject, CLLocationManagerDelegate, ObservableObject {
    static let shared = LocationsHandler()
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation? = nil
    @Published var heading: Double = 0.0

    var completion: ((CLLocationCoordinate2D?) -> Void)?
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("푸시 알림 권한이 허용되었습니다.")
            } else {
                print("푸시 알림 권한이 거부되었습니다.")
            }
        }
    }
    
    func getCurrentLocation(completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        self.completion = completion
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    ///  Push 서버에 쿼리 날리는 부분입니다. location기준으로 특정 영역(50미터) 이내의 메모들 중 가장 최신 메모를 선택했어요
    /// - Parameters:
    ///   - location : 위치값입니다 CLLocation
    /// - Returns: void, 메모 성공하면 push 를 보냅니다.
    func sendQueryToServer(with location: CLLocation) {
        let content = UNMutableNotificationContent()
        Task{
            do {
                if let memo = try await MemoService.shared.fetchPushMemo(in: location) {
                    content.title = "근처에 새로운 메모가 있어요!"
                    content.body = "\(memo.title)"
                    content.sound = UNNotificationSound.default
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                    let request = UNNotificationRequest(identifier:memo.id ?? UUID().uuidString, content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request) { error in
                        if let error = error {
                            print("푸시 알림 예약 중 오류가 발생했습니다: \(error.localizedDescription)")
                        } else {
                            print("푸시 알림이 예약되었습니다.")
                        }
                    }
                }
            } catch {
                print(error.localizedDescription)
            }

        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.location = location
            completion?(location.coordinate)
        }
        completion?(nil)
        // 서버에 쿼리 날리기 30초에 한번?
        #if DEBUG
        let timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] t in
            guard let loc = self?.location else { return }
            self?.sendQueryToServer(with: loc)
        }
        #endif
    }
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.heading = newHeading.trueHeading
        completion?(nil)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        completion?(nil)
    }
}

