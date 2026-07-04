import SwiftUI

struct RouteMapDetailView: View {
    let route: RouteRecord

    var body: some View {
        VStack(spacing: 0) {
            if route.coordinates.count > 1 {
                MapRouteView(coordinates: route.coordinates.map { $0.clLocationCoordinate2D })
                    .ignoresSafeArea(edges: .bottom)
            } else {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "map")
                        .font(.system(size: 50))
                        .foregroundStyle(.secondary)
                    Text("Esta ruta no tiene trazado guardado")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle(route.date.formatted(date: .abbreviated, time: .shortened))
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 0) {
                statBox(title: "Duración", value: route.durationFormatted)
                statBox(title: "Distancia", value: String(format: "%.1f km", route.distanceKm))
                statBox(title: "Media", value: String(format: "%.0f km/h", route.averageSpeedKmh))
                statBox(title: "Máxima", value: String(format: "%.0f km/h", route.maxSpeedKmh))
            }
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
    }

    private func statBox(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
    }
}
