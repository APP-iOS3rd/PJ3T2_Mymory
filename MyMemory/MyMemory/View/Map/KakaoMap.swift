//
//  KakaoMap.swift
//  MyMemory
//
//  Created by 김태훈 on 1/15/24.
//

import SwiftUI
import KakaoMapsSDK
import CoreLocation
struct KakaoMapView: UIViewRepresentable {
    @Binding var draw: Bool
    @Binding var isUserTracking: Bool
    @Binding var userLocation: CLLocation?
    @Binding var clusters: [MemoCluster]
    @EnvironmentObject var viewModel: MainMapViewModel
    /// UIView를 상속한 KMViewContainer를 생성한다.
    /// 뷰 생성과 함께 KMControllerDelegate를 구현한 Coordinator를 생성하고, 엔진을 생성 및 초기화한다.
    func makeUIView(context: Self.Context) -> KMViewContainer {
        let view: KMViewContainer = KMViewContainer()
        view.sizeToFit()
        view.setDelegate(context.coordinator)
        context.coordinator.createController(view)
        context.coordinator.controller?.initEngine()
        
        return view
    }
    
    
    /// Updates the presented `UIView` (and coordinator) to the latest
    /// configuration.
    /// draw가 true로 설정되면 엔진을 시작하고 렌더링을 시작한다.
    /// draw가 false로 설정되면 렌더링을 멈추고 엔진을 stop한다.
    func updateUIView(_ uiView: KMViewContainer, context: Self.Context) {
        if isUserTracking {
            // 유저 트래킹 모드 재설정
            context.coordinator.resetLocation(latitude: userLocation?.coordinate.latitude, longitude: userLocation?.coordinate.longitude)
        }
        context.coordinator.createPois(clusters: clusters)
        if draw {
            context.coordinator.controller?.startEngine()
            context.coordinator.controller?.startRendering()
        }
        else {
            context.coordinator.controller?.stopRendering()
            context.coordinator.controller?.stopEngine()
        }
    }
    
    /// Coordinator 생성
    func makeCoordinator() -> KakaoMapCoordinator {
        return KakaoMapCoordinator(self)
    }
    
    /// Cleans up the presented `UIView` (and coordinator) in
    /// anticipation of their removal.
    static func dismantleUIView(_ uiView: KMViewContainer, coordinator: KakaoMapCoordinator) {
        
    }
    
    /// Coordinator 구현. KMControllerDelegate를 adopt한다.
    class KakaoMapCoordinator: NSObject, MapControllerDelegate, KakaoMapEventDelegate, K3fMapContainerDelegate {
        var parent: KakaoMapView
        var controller: KMController?
        var first: Bool
        init(_ parent: KakaoMapView) {
            

            first = true
            self.parent = parent
        }
        
        // KMController 객체 생성 및 event delegate 지정
        func createController(_ view: KMViewContainer) {
            controller = KMController(viewContainer: view)
            controller?.delegate = self
        }
        func createLabelLayer() {
            let view = controller?.getView("mapview") as! KakaoMap
            let manager = view.getLabelManager()
            let layerOption = LabelLayerOptions(layerID: "PoiLayer", competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 0)
            let _ = manager.addLabelLayer(option: layerOption)
        }
        // KMControllerDelegate Protocol method구현
        
        /// 엔진 생성 및 초기화 이후, 렌더링 준비가 완료되면 아래 addViews를 호출한다.
        /// 원하는 뷰를 생성한다.
        func addViews() {
            let defaultPosition: MapPoint = MapPoint(longitude: 127.108678, latitude: 37.402001)
            let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition)
            if controller?.addView(mapviewInfo) == Result.OK {
                let map = controller?.getView("mapview") as! KakaoMap
                map.eventDelegate = self
                createLabelLayer()

                
            }
        }
        func resetLocation(latitude: Double?, longitude: Double?) {
            if let mapView: KakaoMap = controller?.getView("mapview") as? KakaoMap {
                let cameraUpdate: CameraUpdate = CameraUpdate.make(target: MapPoint(longitude: longitude ??  127.108678, latitude: latitude ?? 37.402001), zoomLevel: 16, mapView: mapView)
                mapView.animateCamera(cameraUpdate: cameraUpdate, options: .init())
                let trackingManager = mapView.getTrackingManager()
                if trackingManager.isTracking {
                    
                }
            }
        }
        
        func createPois(clusters: [MemoCluster]) {
            if let view = controller?.getView("mapview") as? KakaoMap {
                let manager = view.getLabelManager()
                let layer = manager.getLabelLayer(layerID: "PoiLayer")
                let poiOption = PoiOptions(styleID: "PerLevelStyle")
                poiOption.rank = 0
                if let currentPoi = layer?.getAllPois() {
                    layer?.removePois(poiIDs: currentPoi.map{$0.itemID})
                }
                for c in clusters {
                    let tempPoi = layer?.addPoi(option: poiOption, at: MapPoint(longitude: c.center.longitude,
                                                                                latitude: c.center.latitude))
                    let badge = PoiBadge(badgeID: "\(c.id)", image: UIImage(systemName: "car")!, offset: CGPoint(x: 0, y: 0), zOrder: 1)
                    tempPoi?.addBadge(badge)
                    tempPoi?.show()
                    tempPoi?.showBadge(badgeID: "\(c.id)")
                    tempPoi?.clickable = true
                    
                }
            }
        }
        /// KMViewContainer 리사이징 될 때 호출.
        func containerDidResized(_ size: CGSize) {
            let mapView: KakaoMap? = controller?.getView("mapview") as? KakaoMap
            mapView?.viewRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)
            if first {
                let cameraUpdate: CameraUpdate = CameraUpdate.make(target: MapPoint(longitude: 127.108678, latitude: 37.402001), zoomLevel: 16, mapView: mapView!)
                mapView?.moveCamera(cameraUpdate)
                first = false
            }

        }
        func cameraDidStopped(kakaoMap: KakaoMap, by: MoveBy) {
            switch by {
            case .doubleTapZoomIn, .rotateZoom, .twoFingerTapZoomOut, .zoom, .oneFingerZoom:
                print("줌 레벨 변경")
                let dist = kakaoMap.cameraHeight
                parent.viewModel.updateAnnotations(cameraDistance: dist)
            default:
                return
            }
        }
        func cameraWillMove(kakaoMap: KakaoMap, by: MoveBy) {
            switch by {
            case .doubleTapZoomIn, .rotateZoom, .twoFingerTapZoomOut, .zoom, .oneFingerZoom:
                return
            default:
                let trackingManager = kakaoMap.getTrackingManager()

                if parent.isUserTracking {
                    
                    if trackingManager.isTracking {
                        
                    }
                    parent.isUserTracking = trackingManager.isTracking

                } else {
                    trackingManager.stopTracking()
//                    parent.isUserTracking = true
                }
                print("화면 위치 변경")
            }
        }
        func kakaoMapDidTapped(kakaoMap: KakaoMap, point: CGPoint) {
            print("호출")
        }
    }
}
