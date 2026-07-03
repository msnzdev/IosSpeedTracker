import Foundation

struct RouteRecord: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var date: Date
    var duration: TimeInterval      // segundos
    var averageSpeedKmh: Double
    var maxSpeedKmh: Double
    var distanceKm: Double

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
