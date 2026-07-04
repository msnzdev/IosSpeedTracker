import SwiftUI
import MapKit

/// Envoltorio de MKMapView para dibujar la línea del recorrido.
/// Usamos MKMapView directamente (en vez del Map nativo de SwiftUI) para tener
/// control total sobre el trazado (polyline) y que funcione desde iOS 16.
struct MapRouteView: UIViewRepresentable {
    let coordinates: [CLLocationCoordinate2D]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.isRotateEnabled = true
        mapView.isPitchEnabled = false
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)

        guard coordinates.count > 1 else { return }

        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polyline)

        let startAnnotation = MKPointAnnotation()
        startAnnotation.coordinate = coordinates.first!
        startAnnotation.title = "Inicio"
        mapView.addAnnotation(startAnnotation)

        let endAnnotation = MKPointAnnotation()
        endAnnotation.coordinate = coordinates.last!
        endAnnotation.title = "Fin"
        mapView.addAnnotation(endAnnotation)

        mapView.setRegion(regionThatFits(coordinates), animated: false)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let polyline = overlay as? MKPolyline else {
                return MKOverlayRenderer(overlay: overlay)
            }
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.systemCyan
            renderer.lineWidth = 5
            return renderer
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard annotation is MKPointAnnotation else { return nil }
            let identifier = "RoutePoint"
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.annotation = annotation
            if let markerView = view as? MKMarkerAnnotationView {
                markerView.markerTintColor = annotation.title == "Inicio" ? .systemGreen : .systemRed
                markerView.glyphImage = UIImage(systemName: annotation.title == "Inicio" ? "flag.fill" : "flag.checkered")
            }
            return view
        }
    }

    private func regionThatFits(_ coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        var minLat = coordinates[0].latitude
        var maxLat = coordinates[0].latitude
        var minLon = coordinates[0].longitude
        var maxLon = coordinates[0].longitude

        for coordinate in coordinates {
            minLat = min(minLat, coordinate.latitude)
            maxLat = max(maxLat, coordinate.latitude)
            minLon = min(minLon, coordinate.longitude)
            maxLon = max(maxLon, coordinate.longitude)
        }

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: max((maxLat - minLat) * 1.5, 0.01),
            longitudeDelta: max((maxLon - minLon) * 1.5, 0.01)
        )
        return MKCoordinateRegion(center: center, span: span)
    }
}
