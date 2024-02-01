//
//  MapViewRepresentable.swift
//  MyMemory
//
//  Created by 김태훈 on 1/7/24.
//

import Foundation
import SwiftUI
import MapKit
import KakaoMapsSDK
import KakaoMapsSDK_SPM
struct MapViewRepresentable: UIViewRepresentable {
    @Binding var isUserTracking: Bool
    @Binding var distance: Double
    @Binding var clusters: [MemoCluster]
    @Binding var selectedCluster: MemoCluster?
    @EnvironmentObject var viewModel: MainMapViewModel
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.followWithHeading, animated: true)
        
        mapView.setCameraZoomRange(.init(minCenterCoordinateDistance: 10,
                                        maxCenterCoordinateDistance: 20000),
                                   animated: true)
        mapView.delegate = context.coordinator
        return mapView
    }    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // 지도 이동했을 때 userlocation 사라지게 하는 경우
        // mapView.showsUserLocation = isUserTracking
        if isUserTracking {
            // 지도 이동했을 때 userlocation 남아있게 하는 경우
            mapView.showsUserLocation = isUserTracking
            mapView.setUserTrackingMode(.followWithHeading, animated: true)
        }
        if abs(mapView.camera.centerCoordinateDistance - distance) > 2 {
            print(abs(mapView.camera.centerCoordinateDistance - distance))
            var annotationList: [MKPointAnnotation] = []
            for model in clusters {
                let anno = MKPointAnnotation()
                anno.coordinate = model.center
                anno.title = model.id.uuidString
                annotationList.append(anno)
            }
            mapView.removeAnnotations(
                //삭제할 annotation만 삭제
                mapView.annotations
            )
            mapView.addAnnotations(
                //new annotation만 삭제
                annotationList
            )
            distance = mapView.camera.centerCoordinateDistance
        }
    /*
        let exists =	(removeData)
        mapView.addAnnotations(Array(addData)
    */
        //의심 3
    }
    
    func makeCoordinator() -> MapViewCoordinator{
        MapViewCoordinator(self)
    }
    
    class MapViewCoordinator: NSObject, MKMapViewDelegate {
        var mapViewController: MapViewRepresentable        
        init(_ control: MapViewRepresentable) {
            self.mapViewController = control
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            
            if abs(mapViewController.distance - mapView.camera.centerCoordinateDistance) > 2 {
                mapViewController.viewModel.updateAnnotations(cameraDistance: mapView.camera.centerCoordinateDistance)
            }
            
            self.mapViewController.isUserTracking = !(mapView.userTrackingMode == .none)
        }
        
        func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
            
        }
        //MARK: - 어노테이션 처리
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // 현재 애너테이션의 클래스가 MKPointAnnotation인지 확인
            guard annotation is MKPointAnnotation else {
                return nil
            }
            let identifier = "CustomAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            } else {
                annotationView?.annotation = annotation
            }
            // 원하는 이미지 설정
            if let id = mapViewController.selectedCluster?.id.uuidString,
               let title = annotation.title,
               id == title {

                annotationView?.image = UIImage(systemName: "car.fill")
            } else {
                annotationView?.image = UIImage(systemName: "car")
            }
            return annotationView
        }
        func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
            guard let annotation = annotation as? MKPointAnnotation else {return}
            if annotation.title != mapViewController.selectedCluster?.id.uuidString {
                mapViewController
                    .selectedCluster
                = mapViewController
                    .clusters
                    .first(where: {annotation.title == $0.id.uuidString})
                mapViewController
                    .distance = 0.0
            }

        }
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return abs(lhs.latitude - rhs.latitude) < 0.0001 && abs(lhs.longitude - rhs.longitude) < 0.0001
    }

    func squaredDistance(to : CLLocationCoordinate2D) -> Double {
        return (self.latitude - to.latitude) * (self.latitude - to.latitude) + (self.longitude - to.longitude) * (self.longitude - to.longitude)
    }
    

    func distance(to: CLLocationCoordinate2D) -> Double {
        return sqrt(squaredDistance(to: to))
    }
}

