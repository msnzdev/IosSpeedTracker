import SwiftUI

struct HistoryView: View {
    @ObservedObject var routeStore: RouteStore
    @Environment(\.dismiss) private var dismiss
    @State private var routeToShare: RouteRecord?

    var body: some View {
        NavigationStack {
            List {
                if routeStore.routes.isEmpty {
                    ContentUnavailableView(
                        "Sin rutas guardadas",
                        systemImage: "road.lanes",
                        description: Text("Cuando termines una ruta aparecerá aquí.")
                    )
                } else {
                    ForEach(routeStore.routes) { route in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(route.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.subheadline.bold())
                            HStack {
                                Label(route.durationFormatted, systemImage: "timer")
                                Spacer()
                                Label(String(format: "%.1f km", route.distanceKm), systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            HStack {
                                Label(String(format: "%.0f km/h media", route.averageSpeedKmh), systemImage: "speedometer")
                                Spacer()
                                Label(String(format: "%.0f km/h máx", route.maxSpeedKmh), systemImage: "bolt.fill")
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                        .swipeActions(edge: .trailing) {
                            Button {
                                routeToShare = route
                            } label: {
                                Label("Compartir", systemImage: "square.and.arrow.up")
                            }
                            .tint(.blue)
                        }
                    }
                    .onDelete(perform: routeStore.delete)
                }
            }
            .navigationTitle("Historial de rutas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") { dismiss() }
                }
            }
            .sheet(item: $routeToShare) { route in
                ActivityShareSheet(items: [route.shareText])
            }
        }
    }
}
