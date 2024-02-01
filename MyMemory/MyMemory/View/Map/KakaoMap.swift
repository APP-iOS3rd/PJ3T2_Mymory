//
//  KakaoMap.swift
//  MyMemory
//
//  Created by 김태훈 on 1/15/24.
//

import SwiftUI
import KakaoMapsSDK
import CoreLocation
enum Mode: Int {
    case hidden = 0,
         show,
         tracking
}
struct KakaoMapView: UIViewRepresentable {
    @Binding var draw: Bool
    @Binding var isUserTracking: Bool
    @Binding var userLocation: CLLocation?
    @Binding var userDirection: Double
    @Binding var clusters: [MemoCluster]
    @Binding var selectedID: UUID?
    @EnvironmentObject var viewModel: MainMapViewModel
    /// UIView를 상속한 KMViewContainer를 생성한다.
    /// 뷰 생성과 함께 KMControllerDelegate를 구현한 Coordinator를 생성하고, 엔진을 생성 및 초기화한다.
    func makeUIView(context: Self.Context) -> KMViewContainer {
        let view: KMViewContainer = KMViewContainer()
        view.isUserInteractionEnabled = true
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
        //UI 업데이트가 Global에서 되는 현상 해결

        DispatchQueue.main.async {
            
            if isUserTracking {
                // 유저 트래킹 모드 재설정
                context.coordinator.resetLocation(latitude: userLocation?.coordinate.latitude, longitude: userLocation?.coordinate.longitude)
                
            }
            if let id = selectedID {
                if let cluster = clusters.first(where: {$0.memos.contains(where: {$0.id == id})}) {
                    context.coordinator.resetLocation(latitude: cluster.center.latitude, longitude: cluster.center.longitude, withAnimation: true)
                    
                    selectedID = nil
                }
            }
            context.coordinator._currentHeading = userDirection
            context.coordinator._currentPosition = GeoCoordinate(longitude: userLocation?.coordinate.longitude ?? 1, latitude: userLocation?.coordinate.latitude ?? 1)
            if viewModel.clusteringDidChanged {
                context.coordinator.createPois(clusters: clusters, viewModel.selectedCluster)
            }
            if draw {
                context.coordinator.controller?.startEngine()
                context.coordinator.controller?.startRendering()
            }
            else {
                context.coordinator.controller?.stopRendering()
                context.coordinator.controller?.stopEngine()
            }
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
    class KakaoMapCoordinator: NSObject, MapControllerDelegate, KakaoMapEventDelegate, K3fMapContainerDelegate, CLLocationManagerDelegate {
        var parent: KakaoMapView
        var controller: KMController?
        var first: Bool
        init(_ parent: KakaoMapView) {
            _currentHeading = 0
            _currentPosition = GeoCoordinate()
            _moveOnce = false
            first = true
            self.parent = parent
        }
        
        /// 엔진 생성 및 초기화 이후, 렌더링 준비가 완료되면 아래 addViews를 호출한다.
        /// 원하는 뷰를 생성한다.
        func addViews() {
            let defaultPosition: MapPoint
            if let curent = parent.userLocation {
                defaultPosition  = MapPoint(longitude: curent.coordinate.longitude, latitude: curent.coordinate.latitude)
            } else {
                defaultPosition = MapPoint(longitude: 127.108678, latitude: 37.402001)
            }
            let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition, enabled: true)
            if controller?.addView(mapviewInfo) == Result.OK {
                let map = controller?.getView("mapview") as! KakaoMap
                map.poiClickable = true
                map.eventDelegate = self
                map.setGestureEnable(type: .doubleTapZoomIn, enable: true)
                
                createLabelLayer()
                createPoiStyle()
                createUserPois()
                startTracking()
            }
        }
        // KMController 객체 생성 및 event delegate 지정
        func createController(_ view: KMViewContainer) {
            
            controller = KMController(viewContainer: view)
            
            controller?.delegate = self
        }
        func poiDidTapped(kakaoMap: KakaoMap, layerID: String, poiID: String, position: MapPoint) {
            print("poiDidTapped")
        }
        //MARK: - 현위치 마커
        // 현위치마커 버튼 GUI
        func startTracking() {
            _timer = Timer.init(timeInterval: 0.3, target: self, selector: #selector(self.updateCurrentPositionPOI), userInfo: nil, repeats: true)
            RunLoop.current.add(_timer!, forMode: RunLoop.Mode.common)
            _currentPositionPoi?.show()
            _currentDirectionArrowPoi?.show()
            _currentArea?.show()
            _moveOnce = true
        }
        @objc func updateCurrentPositionPOI() {
            _currentPositionPoi?.moveAt(MapPoint(longitude: _currentPosition.longitude, latitude: _currentPosition.latitude), duration: 150)
            _currentDirectionArrowPoi?.rotateAt(_currentHeading, duration: 150)
            
            if _moveOnce {
                let mapView: KakaoMap = controller?.getView("mapview") as! KakaoMap
                mapView.moveCamera(CameraUpdate.make(target: MapPoint(longitude: _currentPosition.longitude, latitude: _currentPosition.latitude), mapView: mapView))
                _moveOnce = false
            }
        }
        //MARK: - POI Touch Event Flow
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
        private func cameraRect() -> AreaRect? {
            if let map = controller?.getView("mapview") as? KakaoMap {
                
                let minX = map.viewRect.minX
                let minY = map.viewRect.minY
                let maxX = map.viewRect.maxX
                let maxY = map.viewRect.maxY
                if let southWest = getPosition(.init(x: minX, y: minY)) ,
                   let northEast =  getPosition(.init(x: maxX, y: maxY)) {
                    return .init(southWest: southWest,
                                 northEast: northEast)
                }
                return nil
            } else { return nil }
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
        
        //MARK: - POI생성 및 관리 flow
        func createLabelLayer() {
            let view = controller?.getView("mapview") as! KakaoMap
            let manager = view.getLabelManager()
            let positionLayerOption = LabelLayerOptions(layerID: "PositionPoiLayer", competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 0)
            let _ = manager.addLabelLayer(option: positionLayerOption)
            let directionLayerOption = LabelLayerOptions(layerID: "DirectionPoiLayer", competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 10)
            let _ = manager.addLabelLayer(option: directionLayerOption)
            let layerOption = LabelLayerOptions(layerID: "PoiLayer", competitionType: .none, competitionUnit: .poi, orderType: .rank, zOrder: 10001)
            let _ = manager.addLabelLayer(option: layerOption)
        }
        func createPoiStyle() {
            let view = controller?.getView("mapview") as! KakaoMap
            let manager = view.getLabelManager()
            
            let marker = PoiIconStyle(symbol: UIImage(named: "map_ico_marker"))
            let perLevelStyle1 = PerLevelPoiStyle(iconStyle: marker, level: 0)
            let poiStyle1 = PoiStyle(styleID: "positionPoiStyle", styles: [perLevelStyle1])
            manager.addPoiStyle(poiStyle1)
            
            let direction = PoiIconStyle(symbol: UIImage(named: "map_ico_marker_direction"), anchorPoint: CGPoint(x: 0.5, y: 0.995))
            let perLevelStyle2 = PerLevelPoiStyle(iconStyle: direction, level: 0)
            let poiStyle2 = PoiStyle(styleID: "directionArrowPoiStyle", styles: [perLevelStyle2])
            manager.addPoiStyle(poiStyle2)
            
            let area = PoiIconStyle(symbol: UIImage(named: "map_ico_direction_area"), anchorPoint: CGPoint(x: 0.5, y: 0.995))
            let perLevelStyle3 = PerLevelPoiStyle(iconStyle: area, level: 0)
            let poiStyle3 = PoiStyle(styleID: "directionPoiStyle", styles: [perLevelStyle3])
            manager.addPoiStyle(poiStyle3)
            
            // 지도 위 클러스터 마커
            let memoDef = PoiIconStyle(symbol: UIImage(named: "marker_default"))
            let memoSelected = PoiIconStyle(symbol: UIImage(named: "marker_selected"))
            let memoMine = PoiIconStyle(symbol: UIImage(named: "marker_mine"))
            let memoMineSelected = PoiIconStyle(symbol: UIImage(named: "maker_mine_selected"))
            
            let perLevelStyleDef = PerLevelPoiStyle(iconStyle: memoDef, level: 0)
            let perLevelStyleSelected = PerLevelPoiStyle(iconStyle: memoSelected, level: 1)
            let perLevelStyleMine = PerLevelPoiStyle(iconStyle: memoMine, level: 2)
            let perLevelStyleMineSelected = PerLevelPoiStyle(iconStyle: memoMineSelected, level: 3)
            
            
            let poiStyleDef = PoiStyle(styleID: "memoPoiStyle1", styles: [perLevelStyleDef])
            let poiStyleSelected = PoiStyle(styleID: "memoPoiStyle2", styles: [perLevelStyleSelected])
            let poiStyleMine = PoiStyle(styleID: "memoPoiStyle3", styles: [perLevelStyleMine])
            let poiStyleMineSelected = PoiStyle(styleID: "memoPoiStyle4", styles: [perLevelStyleMineSelected])
            
            manager.addPoiStyle(poiStyleDef)
            manager.addPoiStyle(poiStyleSelected)
            manager.addPoiStyle(poiStyleMine)
            manager.addPoiStyle(poiStyleMineSelected)
            
        }
        func createUserPois() {
            let view = controller?.getView("mapview") as! KakaoMap
            let manager = view.getLabelManager()
            let positionLayer = manager.getLabelLayer(layerID: "PositionPoiLayer")
            let directionLayer = manager.getLabelLayer(layerID: "DirectionPoiLayer")
            
            // 현위치마커의 몸통에 해당하는 POI
            let poiOption = PoiOptions(styleID: "positionPoiStyle", poiID: "PositionPOI")
            poiOption.rank = 1
            poiOption.transformType = .decal    //화면이 기울여졌을 때, 지도를 따라 기울어져서 그려지도록 한다.
            let position: MapPoint = MapPoint(longitude: 127.108678, latitude: 37.402001)
            
            _currentPositionPoi = positionLayer?.addPoi(option:poiOption, at: position)
            
            // 현위치마커의 방향표시 화살표에 해당하는 POI
            let poiOption2 = PoiOptions(styleID: "directionArrowPoiStyle", poiID: "DirectionArrowPOI")
            poiOption2.rank = 3
            poiOption2.transformType = .absoluteRotationDecal
            
            _currentDirectionArrowPoi = positionLayer?.addPoi(option:poiOption2, at: position)
            
            // 현위치마커의 부채꼴모양 방향표시에 해당하는 POI
            let poiOption3 = PoiOptions(styleID: "directionPoiStyle", poiID: "DirectionPOI")
            poiOption3.rank = 2
            poiOption3.transformType = .decal
            
            _currentDirectionPoi = directionLayer?.addPoi(option:poiOption3, at: position)
            
            _currentPositionPoi?.shareTransformWithPoi(_currentDirectionArrowPoi!)  //몸통이 방향표시와 위치 및 방향을 공유하도록 지정한다. 몸통 POI의 위치가 변경되면 방향표시 POI의 위치도 변경된다. 반대는 변경안됨.
            _currentDirectionArrowPoi?.shareTransformWithPoi(_currentDirectionPoi!) //방향표시가 부채꼴모양과 위치 및 방향을 공유하도록 지정한다.
        }
        func createWaveShape() {
            let view = controller?.getView("mapview") as! KakaoMap
            let manager = view.getShapeManager()
            let layer = manager.addShapeLayer(layerID: "shapeLayer", zOrder: 10001, passType: .route)
            
            let shapeStyle = PolygonStyle(styles: [
                PerLevelPolygonStyle(color: UIColor(red: 0.3, green: 0.7, blue: 0.9, alpha: 1.0), level: 0)
            ])
            let shapeStyleSet = PolygonStyleSet(styleSetID: "shapeLevelStyle")
            shapeStyleSet.addStyle(shapeStyle)
            manager.addPolygonStyleSet(shapeStyleSet)
            
            let options = PolygonShapeOptions(shapeID: "waveShape", styleID: "shapeLevelStyle", zOrder: 1)
            let points = Primitives.getCirclePoints(radius: 10.0, numPoints: 90, cw: true)
            let polygon = Polygon(exteriorRing: points, hole: nil, styleIndex: 0)
            
            options.polygons.append(polygon)
            options.basePosition = MapPoint(longitude: 0, latitude: 0)
            
            let shape = layer?.addPolygonShape(options)
            _currentDirectionPoi?.shareTransformWithShape(shape!)   //현위치마커 몸통이 Polygon이 위치 및 방향을 공유하도록 지정한다.
        }
        func createPois(clusters: [MemoCluster],_ selected: MemoCluster? = nil) {
            
            if let view = controller?.getView("mapview") as? KakaoMap {
                let manager = view.getLabelManager()
                let layer = manager.getLabelLayer(layerID: "PoiLayer")
                
                if let currentPoi = layer?.getAllPois() {
                    layer?.removePois(poiIDs: currentPoi.map{$0.itemID})
                }
                for c in clusters {
                    var poiOption = PoiOptions(styleID: "memoPoiStyle1", poiID: c.id.uuidString)
                    if let s = selected {
                        if c == s {
                            poiOption = PoiOptions(styleID: "memoPoiStyle2", poiID: c.id.uuidString)
                        }
                    }
                    
                    if let current = UserDefaults.standard.string(forKey: "userID") // 저장된 내 UUID
                    {
                        if c.memos.contains(where: {$0.id.uuidString == current}) {
                            poiOption = PoiOptions(styleID: "memoPoiStyle3", poiID: c.id.uuidString)
                        }
                    }
                    
                    poiOption.rank = 2
                    poiOption.transformType = .decal
                    let tempPoi = layer?.addPoi(option: poiOption, at: MapPoint(longitude: c.center.longitude,
                                                                                latitude: c.center.latitude))
                    tempPoi?.show()
                    
                    
                    
                    // 임시 구현
                    
                }
            }
        }
        //MARK: - Delegation함수
        func resetLocation(latitude: Double?, longitude: Double?,  withAnimation: Bool = false) {
            if let mapView: KakaoMap = controller?.getView("mapview") as? KakaoMap {
                let cameraUpdate: CameraUpdate = CameraUpdate.make(target: MapPoint(longitude: longitude ??  127.108678, latitude: latitude ?? 37.402001), zoomLevel: 16, mapView: mapView)
                if withAnimation{
                    mapView.animateCamera(cameraUpdate: cameraUpdate, options: .init())
                } else {
                    mapView.moveCamera(cameraUpdate)
                }
                let trackingManager = mapView.getTrackingManager()
                if trackingManager.isTracking {
                    
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
            if let Area = cameraRect() {
                parent.viewModel.clusterTest(mapRect: Area, zoomScale: kakaoMap.zoomLevel)
            }
            switch by {
            case .doubleTapZoomIn, .rotateZoom, .twoFingerTapZoomOut, .zoom, .oneFingerZoom:
                print("줌 레벨 변경")
                let dist = kakaoMap.cameraHeight
                
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
                }
            }
        }
        var _timer: Timer?
        var _currentArea: PolygonShape?
        var _currentPositionPoi: Poi?
        var _currentDirectionArrowPoi: Poi?
        var _currentDirectionPoi: Poi?
        var _currentHeading: Double
        var _currentPosition: GeoCoordinate
        var _moveOnce: Bool
    }
    
    
    
}
