import Foundation
import CoreLocation
import Combine

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    // MARK: - Estado publicado hacia la UI
    @Published var currentSpeedKmh: Double = 0
    @Published var maxSpeedKmh: Double = 0
    @Published var averageSpeedKmh: Double = 0
    @Published var elapsedTime: TimeInterval = 0
    @Published var distanceKm: Double = 0
    @Published var isTracking: Bool = false
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    // MARK: - Privado
    private let manager = CLLocationManager()
    private var lastLocation: CLLocation?
    private var startDate: Date?
    private var timer: Timer?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.activityType = .automotiveNavigation
        // Permite que el GPS siga activo con la app en background / pantalla bloqueada
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
        manager.showsBackgroundLocationIndicator = true
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation() // para poder mostrar velocidad actual aunque no estés grabando ruta
    }

    // MARK: - Control de ruta

    func startRoute() {
        distanceKm = 0
        maxSpeedKmh = 0
        averageSpeedKmh = 0
        elapsedTime = 0
        lastLocation = nil
        startDate = Date()
        isTracking = true

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        // Aseguramos precisión máxima mientras se graba
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.startUpdatingLocation()
    }

    /// Devuelve el registro final de la ruta
    @discardableResult
    func stopRoute() -> RouteRecord {
        isTracking = false
        timer?.invalidate()
        timer = nil

        let record = RouteRecord(
            date: startDate ?? Date(),
            duration: elapsedTime,
            averageSpeedKmh: averageSpeedKmh,
            maxSpeedKmh: maxSpeedKmh,
            distanceKm: distanceKm
        )
        return record
    }

    private func tick() {
        guard let start = startDate else { return }
        elapsedTime = Date().timeIntervalSince(start)
        recomputeAverage()
    }

    private func recomputeAverage() {
        guard elapsedTime > 0 else { return }
        // Media = distancia total / tiempo total (más fiable que promediar muestras)
        averageSpeedKmh = distanceKm / (elapsedTime / 3600.0)
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        // location.speed viene en m/s; -1 significa "no disponible"
        if location.speed >= 0 {
            let speedKmh = location.speed * 3.6
            currentSpeedKmh = speedKmh
            if isTracking {
                maxSpeedKmh = max(maxSpeedKmh, speedKmh)
            }
        }

        if isTracking {
            if let last = lastLocation {
                let deltaMeters = location.distance(from: last)
                // Filtro simple de ruido GPS (ignora saltos irreales en parado)
                if deltaMeters > 0.5 {
                    distanceKm += deltaMeters / 1000.0
                }
            }
            lastLocation = location
            recomputeAverage()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error de localización: \(error.localizedDescription)")
    }
}
