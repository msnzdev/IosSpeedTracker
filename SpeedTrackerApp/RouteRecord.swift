import Foundation
import CoreLocation

/// Punto de coordenada simplificado, para poder guardarlo en JSON (CLLocationCoordinate2D no es Codable).
struct RouteCoordinate: Codable, Equatable {
    let latitude: Double
    let longitude: Double

    var clLocationCoordinate2D: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct RouteRecord: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var date: Date
    var duration: TimeInterval      // segundos
    var averageSpeedKmh: Double
    var maxSpeedKmh: Double
    var distanceKm: Double
    var coordinates: [RouteCoordinate] = []

    init(
        id: UUID = UUID(),
        date: Date,
        duration: TimeInterval,
        averageSpeedKmh: Double,
        maxSpeedKmh: Double,
        distanceKm: Double,
        coordinates: [RouteCoordinate] = []
    ) {
        self.id = id
        self.date = date
        self.duration = duration
        self.averageSpeedKmh = averageSpeedKmh
        self.maxSpeedKmh = maxSpeedKmh
        self.distanceKm = distanceKm
        self.coordinates = coordinates
    }

    enum CodingKeys: String, CodingKey {
        case id, date, duration, averageSpeedKmh, maxSpeedKmh, distanceKm, coordinates
    }

    // Decodificación manual: si una ruta se guardó ANTES de añadir el mapa,
    // no tendrá el campo "coordinates" — en ese caso usamos un array vacío
    // en vez de fallar al cargar el historial completo.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        date = try container.decode(Date.self, forKey: .date)
        duration = try container.decode(TimeInterval.self, forKey: .duration)
        averageSpeedKmh = try container.decode(Double.self, forKey: .averageSpeedKmh)
        maxSpeedKmh = try container.decode(Double.self, forKey: .maxSpeedKmh)
        distanceKm = try container.decode(Double.self, forKey: .distanceKm)
        coordinates = try container.decodeIfPresent([RouteCoordinate].self, forKey: .coordinates) ?? []
    }

    var durationFormatted: String {
        let h = Int(duration) / 3600
        let m = (Int(duration) % 3600) / 60
        let s = Int(duration) % 60
        if h > 0 {
            return String(format: "%dh %02dm %02ds", h, m, s)
        }
        return String(format: "%dm %02ds", m, s)
    }

    var shareText: String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return """
        🏍️ Ruta del \(df.string(from: date))
        ⏱️ Duración: \(durationFormatted)
        📏 Distancia: \(String(format: "%.1f", distanceKm)) km
        📊 Velocidad media: \(String(format: "%.1f", averageSpeedKmh)) km/h
        🚀 Velocidad máxima: \(String(format: "%.1f", maxSpeedKmh)) km/h
        """
    }
}
