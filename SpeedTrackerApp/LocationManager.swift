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
    @Published var isGPSActive: Bool = false

    // MARK: - Privado
    private let manager = CLLocationManager()
    private var lastLocation: CLLocation?
    private var startDate: Date?
    private var timer: Timer?
    private var routeCoordinates: [CLLocationCoordinate2D] = []
    private var lastRecordedPathLocation: CLLocation?
    private let minMetersBetweenPathPoints: CLLocationDistance = 15

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
        routeCoordinates = []
        lastRecordedPathLocation = nil

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
            distanceKm: distanceKm,
            coordinates: routeCoordinates.map { RouteCoordinate(latitude: $0.latitude, longitude: $0.longitude) }
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

        // Consideramos el GPS "activo" cuando la precisión horizontal es razonable.
        // Al principio (recién abierta la app o tras salir de un túnel) la precisión
        // es mala o inválida (-1), y ahí es cuando NO queremos que el usuario empiece la ruta.
        if location.horizontalAccuracy >= 0 && location.horizontalAccuracy <= 50 {
            isGPSActive = true
        } else {
            isGPSActive = false
        }

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

            // Grabamos el trazado de la ruta, pero solo un punto cada X metros
            // para no acumular miles de coordenadas casi idénticas.
            if let lastPathPoint = lastRecordedPathLocation {
                if location.distance(from: lastPathPoint) >= minMetersBetweenPathPoints {
                    routeCoordinates.append(location.coordinate)
                    lastRecordedPathLocation = location
                }
            } else {
                routeCoordinates.append(location.coordinate)
                lastRecordedPathLocation = location
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error de localización: \(error.localizedDescription)")
    }
}
