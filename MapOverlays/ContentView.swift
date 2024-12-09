//
//  ContentView.swift
//  MapOverlays
//
//  Created by Abhishek Bagela on 08/12/24.
//
import SwiftUI
import MapKit

struct ContentView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 22.7600, longitude: 75.8800),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State var details: MKPolygon? = nil
    @State var showDetails = false
    
    let polygons: [String: MKPolygon] = [
        "Polygon A": MKPolygon(coordinates: [
            CLLocationCoordinate2D(latitude: 22.7500, longitude: 75.8900), // Top-left
            CLLocationCoordinate2D(latitude: 22.7525, longitude: 75.8950), // Top-right
            CLLocationCoordinate2D(latitude: 22.7475, longitude: 75.9000), // Bottom-right
            CLLocationCoordinate2D(latitude: 22.7450, longitude: 75.8950)  // Bottom-left
        ], count: 4),
        
        "Polygon B": MKPolygon(coordinates: [
            CLLocationCoordinate2D(latitude: 22.7600, longitude: 75.8800), // Top-left
            CLLocationCoordinate2D(latitude: 22.7625, longitude: 75.8850), // Top-right
            CLLocationCoordinate2D(latitude: 22.7575, longitude: 75.8900), // Bottom-right
            CLLocationCoordinate2D(latitude: 22.7550, longitude: 75.8850)  // Bottom-left
        ], count: 4),
        
        "Polygon C": MKPolygon(coordinates: [
            CLLocationCoordinate2D(latitude: 22.7700, longitude: 75.8700), // Top-left
            CLLocationCoordinate2D(latitude: 22.7725, longitude: 75.8750), // Top-right
            CLLocationCoordinate2D(latitude: 22.7675, longitude: 75.8800), // Bottom-right
            CLLocationCoordinate2D(latitude: 22.7650, longitude: 75.8750)  // Bottom-left
        ], count: 4),
        
        "Polygon D": MKPolygon(coordinates: [
            CLLocationCoordinate2D(latitude: 22.7800, longitude: 75.8600), // Top-left
            CLLocationCoordinate2D(latitude: 22.7825, longitude: 75.8650), // Top-right
            CLLocationCoordinate2D(latitude: 22.7775, longitude: 75.8700), // Bottom-right
            CLLocationCoordinate2D(latitude: 22.7750, longitude: 75.8650)  // Bottom-left
        ], count: 4)
    ]
    
    var body: some View {
        VStack {
            MapViewWithOverlays(region: $region, polygons: polygons) { polygon in
                details = polygon
                showDetails = true
            }
            .edgesIgnoringSafeArea(.all)
        }
        .alert(isPresented: $showDetails) {
            Alert(title: Text("Polygon Details"), message: Text(details?.title ?? ""))
        }
    }
}

struct MapViewWithOverlays: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var polygons: [String: MKPolygon]
    var didSelectMKPolygon: (MKPolygon) -> Void
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.isUserInteractionEnabled = true // Disable all user interactions
        mapView.setRegion(region, animated: true)
        
        polygons.forEach { dic in
            let polygon = dic.value
            polygon.title = dic.key
            mapView.addOverlay(polygon)
            
            let boundingMapRect = polygon.boundingMapRect
            mapView.setVisibleMapRect(boundingMapRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
        }
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewWithOverlays
        
        init(_ parent: MapViewWithOverlays) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polygon = overlay as? MKPolygon {
                let renderer = MKPolygonRenderer(polygon: polygon)
                renderer.fillColor = UIColor.green.withAlphaComponent(0.3)
                renderer.strokeColor = UIColor.red
                renderer.lineWidth = 2
                renderer.polygon.title = "Selected Polygon"
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
    
    // Add tap interaction to polygons
    func mapView(_ mapView: MKMapView, didSelect overlay: MKOverlay) {
        print("didSelect")
        if let polygon = overlay as? MKPolygon {
            print("Selected: \(polygon.title ?? "Unknown Polygon")")
            
            // Show an alert or pass data back to the SwiftUI View
            didSelectMKPolygon(polygon)
        }
    }
    
}
