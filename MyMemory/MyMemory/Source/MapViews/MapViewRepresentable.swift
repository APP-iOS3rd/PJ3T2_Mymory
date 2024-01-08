//
//  MapViewRepresentable.swift
//  MyMemory
//
//  Created by 김태훈 on 1/7/24.
//

import Foundation
import SwiftUI
import MapKit
struct MapViewRepresentable: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion?
    @Binding var annotations: [MiniMemoModel]
    @Binding var isUserTracking: Bool
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        if isUserTracking {
            if let region = region {
                mapView.setRegion(region, animated: true)
            }
        }
        let annotationList = annotations.map { model in
            let anno = MKPointAnnotation()
            anno.coordinate = model.coordinate
            return anno
        }
        mapView.showsUserLocation = isUserTracking
        mapView.setUserTrackingMode(.followWithHeading, animated: true)
        mapView.addAnnotations(annotationList)
        mapView.setCameraZoomRange(.init(minCenterCoordinateDistance: 10),
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
    }
    func makeCoordinator() -> MapViewCoordinator{
        MapViewCoordinator(self)
    }
    class MapViewCoordinator: NSObject, MKMapViewDelegate {
        var mapViewController: MapViewRepresentable
        private var selectedAnnotation: MKPointAnnotation?
        
        init(_ control: MapViewRepresentable) {
            self.mapViewController = control
        }
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            self.mapViewController.isUserTracking = !(mapView.userTrackingMode == .none)
            mapViewController.region = mapView.region
        }
        
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
            if let selectedAnnotation = selectedAnnotation,
               annotation === selectedAnnotation {
                annotationView?.image = UIImage(systemName: "car.fill")
            } else {
                annotationView?.image = UIImage(systemName: "car")
            }
            return annotationView
        }
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation as? MKPointAnnotation else {return}
            let annotationList = mapViewController.annotations.map { model in
                let anno = MKPointAnnotation()
                anno.coordinate = model.coordinate
                return anno
            }
            selectedAnnotation = annotation
            mapView.removeAnnotations(annotationList)
            mapView.addAnnotations(annotationList)
        }
        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            let annotationList = mapViewController.annotations.map { model in
                let anno = MKPointAnnotation()
                anno.coordinate = model.coordinate
                return anno
            }
            selectedAnnotation = nil
            mapView.removeAnnotations(annotationList)
            mapView.addAnnotations(annotationList)
        }
    }
}
extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return abs(lhs.latitude - rhs.latitude) < 0.0001 && abs(lhs.longitude - rhs.longitude) < 0.0001
    }
}
