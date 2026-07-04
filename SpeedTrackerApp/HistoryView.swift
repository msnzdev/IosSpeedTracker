import SwiftUI

struct HistoryView: View {
    @ObservedObject var routeStore: RouteStore
    @Environment(\.dismiss) private var dismiss
    @State private var routeToShare: RouteRecord?
    @State private var routeToDelete: RouteRecord?

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
                        NavigationLink {
                            RouteMapDetailView(route: route)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(route.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.subheadline.bold())
                                    if route.coordinates.count > 1 {
                                        Image(systemName: "map.fill")
                                            .font(.caption)
                                            .foregroundStyle(.cyan)
                                    }
                                    Spacer()
                                    Button {
                                        routeToShare = route
                                    } label: {
                                        Image(systemName: "square.and.arrow.up")
                                    }
                                    .buttonStyle(.borderless)
                                    .tint(.blue)

                                    Button {
                                        routeToDelete = route
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                    .buttonStyle(.borderless)
                                    .tint(.red)
                                }
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
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                routeToDelete = route
                            } label: {
                                Label("Eliminar", systemImage: "trash")
                            }
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
            .toolbar { closeToolbarContent }
            .sheet(item: $routeToShare) { route in
                ActivityShareSheet(items: [route.shareText])
            }
            .alert("¿Eliminar esta ruta?", isPresented: Binding(
                get: { routeToDelete != nil },
                set: { if !$0 { routeToDelete = nil } }
            )) {
                Button("Eliminar", role: .destructive) {
                    if let route = routeToDelete {
                        routeStore.delete(route)
                    }
                    routeToDelete = nil
                }
                Button("Cancelar", role: .cancel) {
                    routeToDelete = nil
                }
            } message: {
                Text("Esta acción no se puede deshacer.")
            }
        }
    }

    @ToolbarContentBuilder
    private var closeToolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Cerrar") { dismiss() }
        }
    }
}
