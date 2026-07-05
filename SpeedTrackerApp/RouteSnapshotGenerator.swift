import MapKit
import UIKit

/// Genera una imagen (UIImage) del mapa con la línea del recorrido dibujada encima,
/// usando MKMapSnapshotter. Se usa para adjuntar el mapa cuando se comparte una ruta.
enum RouteSnapshotGenerator {

    static func generate(for route: RouteRecord, completion: @escaping (UIImage?) -> Void) {
        guard route.coordinates.count > 1 else {
            completion(nil)
            return
        }

        let coordinates = route.coordinates.map { $0.clLocationCoordinate2D }
        let region = regionThatFits(coordinates)

        let options = MKMapSnapshotter.Options()
        options.region = region
        options.size = CGSize(width: 800, height: 500)
        options.scale = UIScreen.main.scale
        options.mapType = .standard

        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { snapshot, error in
            guard let snapshot = snapshot else {
                completion(nil)
                return
            }
            let image = drawRoute(on: snapshot, coordinates: coordinates)
            completion(image)
        }
    }

    private static func drawRoute(on snapshot: MKMapSnapshotter.Snapshot, coordinates: [CLLocationCoordinate2D]) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: snapshot.image.size)
        return renderer.image { context in
            snapshot.image.draw(at: .zero)

            let points = coordinates.map { snapshot.point(for: $0) }
            guard let firstPoint = points.first, let lastPoint = points.last else { return }

            let path = UIBezierPath()
            path.move(to: firstPoint)
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
            path.lineWidth = 6
            path.lineCapStyle = .round
            path.lineJoinStyle = .round
            UIColor.systemCyan.setStroke()
            path.stroke()

            drawDot(at: firstPoint, color: .systemGreen, context: context.cgContext)
            drawDot(at: lastPoint, color: .systemRed, context: context.cgContext)
        }
    }

    private static func drawDot(at point: CGPoint, color: UIColor, context: CGContext) {
        let radius: CGFloat = 9
        let rect = CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)
        context.setFillColor(color.cgColor)
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(2.5)
        context.addEllipse(in: rect)
        context.drawPath(using: .fillStroke)
    }

    private static func regionThatFits(_ coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
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
