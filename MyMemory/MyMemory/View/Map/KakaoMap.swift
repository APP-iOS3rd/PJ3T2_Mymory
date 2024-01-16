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
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(context.coordinator.test)))
        view.isMultipleTouchEnabled = true
        view.setDelegate(context.coordinator)
        view.sizeToFit()
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
        
        var _mapTapEventHandler: DisposableEventHandler?       
        init(_ parent: KakaoMapView) {
            

            first = true
            self.parent = parent
        }
        @objc func test() {
            print("touch")
        }
        //여기서 touch event 처리
        func poiTouched(_ poi: Poi) {
            parent.viewModel.selectedCluster = parent.viewModel.clusters.first(where: {$0.id.uuidString == poi.itemID})
        }
         func touchesBegan(_ touches: Set<AnyHashable>) {
             if let touch = touches.first as? UITouch {
                 let radius = touch.majorRadius
                 let touchedCenter = touch.location(in: touch.window)
                 // touch major radius기준으로 거리 재기 위한 임시 Point
                 let withRadius = CGPoint(x: touchedCenter.x + radius, y: touchedCenter.y)
                 if let point = getPosition(touchedCenter),
                 let withRadiusPoint = getPosition(withRadius)
                 {
                     // 거리 계산
                     let latdist = (point.wgsCoord.latitude - withRadiusPoint.wgsCoord.latitude)
                     let longdist = (point.wgsCoord.longitude - withRadiusPoint.wgsCoord.longitude)
                     let powdDist = latdist * latdist + longdist * longdist
                     let dist = sqrt(powdDist) // radius의 map상에서의 거리
                     
                     if let touchedPoi = touchedPOI(point.wgsCoord, dist) {
                         poiTouched(touchedPoi)
                     }
                 }
             }
        }
        private func touchedPOI(_ coord: GeoCoordinate, _ dist: Double) -> Poi? {
            if let map = controller?.getView("mapview") as? KakaoMap {
                let manager = map.getLabelManager()
                let layer = manager.getLabelLayer(layerID: "PoiLayer")
                guard let pois = layer?.getAllPois() else {return nil}
                var touchedPois: [Poi : Double] = [:] // value = distance
                for poi in pois {
                    let latdist = (coord.latitude - poi.position.wgsCoord.latitude)
                    let longdist = (coord.longitude - poi.position.wgsCoord.longitude)
                    let powdDist = latdist * latdist + longdist * longdist
                    let distWithPoi = sqrt(powdDist)
                    // touched radius 반경 안에 있는 경우
                    if distWithPoi < dist {
                        touchedPois[poi] = distWithPoi
                    }
                }
                if touchedPois.isEmpty { return nil }
                else { return touchedPois.sorted(by: {$0.value < $1.value}).first!.key} // 가장 가까운 poi를 리턴합니다.
            }
            return nil
        }
        private func getPosition(_ point: CGPoint) -> MapPoint? {
            let mapView: KakaoMap? = controller?.getView("mapview") as? KakaoMap

            guard let map = mapView else
            {return nil}
           return map.getPosition(point)
        }
        // KMController 객체 생성 및 event delegate 지정
        func createController(_ view: KMViewContainer) {
            
            controller = KMController(viewContainer: view)
            
            controller?.delegate = self
        }
        func createLabelLayer() {
            let view = controller?.getView("mapview") as! KakaoMap
            let manager = view.getLabelManager()
            
            let layerOption = LabelLayerOptions(layerID: "PoiLayer", competitionType: .none, competitionUnit: .poi, orderType: .rank, zOrder: 10001)
            let _ = manager.addLabelLayer(option: layerOption)
        }

        // KMControllerDelegate Protocol method구현
        
        /// 엔진 생성 및 초기화 이후, 렌더링 준비가 완료되면 아래 addViews를 호출한다.
        /// 원하는 뷰를 생성한다.
        func addViews() {
            let defaultPosition: MapPoint = MapPoint(longitude: 127.108678, latitude: 37.402001)
            let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition, enabled: true)
            if controller?.addView(mapviewInfo) == Result.OK {
                let map = controller?.getView("mapview") as! KakaoMap
                map.poiClickable = true
                map.eventDelegate = self
                map.setGestureEnable(type: .doubleTapZoomIn, enable: true)
                map.setCompassPosition(origin: GuiAlignment(vAlign: .bottom, hAlign: .left), position: CGPoint(x: 10.0, y: 10.0))
                map.showCompass()  //나침반을 표시한다.
                createLabelLayer()

                _mapTapEventHandler = map.addMapTappedEventHandler(target: self, handler: KakaoMapCoordinator.mapDidTapped)
            }
        }
        func mapDidTapped(_ param: ViewInteractionEventParam) {
            let mapView = param.view as! KakaoMap
            let position = mapView.getPosition(param.point)
            
            print("Tapped: \(position.wgsCoord.latitude), \(position.wgsCoord.latitude)")
            
            _mapTapEventHandler?.dispose()
        }
        func compassDidTapped(kakaoMap: KakaoMap) {
            print("나침반")
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
                layer?.setClickable(true)
                if let currentPoi = layer?.getAllPois() {
                    layer?.removePois(poiIDs: currentPoi.map{$0.itemID})
                }
                for c in clusters {
                    let poiOption = PoiOptions(styleID: "PerLevelStyle", poiID: c.id.uuidString)
                    poiOption.rank = 0
                    poiOption.clickable = true

                    let tempPoi = layer?.addPoi(option: poiOption, at: MapPoint(longitude: c.center.longitude,
                                                                                latitude: c.center.latitude))
                    let badge = PoiBadge(badgeID: "\(c.id)", image: UIImage(systemName: "car")!, offset: CGPoint(x: 0.1, y: 0.1), zOrder: 1)
                    
                    tempPoi?.clickable = true
                    
                    
                    let _ = tempPoi?.addPoiTappedEventHandler(target: self, handler: KakaoMapCoordinator.poiTappedHandler)
                    tempPoi?.addBadge(badge)
                    tempPoi?.show()
                    tempPoi?.showBadge(badgeID: "\(c.id)")
                    
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
        func poiTappedHandler(_ param: PoiInteractionEventParam) {
            param.poiItem.hide()
        }
        func poiDidTapped(kakaoMap: KakaoMap, layerID: String, poiID: String, position: MapPoint) {
            print("터치")
        }
        func terrainDidTapped(kakaoMap: KakaoMap, position: MapPoint) {
            print("ff")
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
