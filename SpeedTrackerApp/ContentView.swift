import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var routeStore = RouteStore()

    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []
    @State private var lastRoute: RouteRecord?
    @State private var showHistory = false
    @State private var showPermissionAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.black, .indigo.opacity(0.35)],
                                startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                VStack(spacing: 28) {

                    // Indicador de estado del GPS
                    HStack(spacing: 8) {
                        Circle()
                            .fill(locationManager.isGPSActive ? Color.green : Color.orange)
                            .frame(width: 10, height: 10)
                        Text(locationManager.isGPSActive ? "GPS Activo" : "GPS Inactivo")
                            .font(.caption.bold())
                            .foregroundStyle(locationManager.isGPSActive ? .green : .orange)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.white.opacity(0.08))
                    .clipShape(Capsule())
                    .padding(.top, 8)

                    // Velocidad actual
                    VStack(spacing: 4) {
                        Text("VELOCIDAD ACTUAL")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(String(format: "%.0f", locationManager.currentSpeedKmh))
                            .font(.system(size: 90, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("km/h")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 20)

                    if locationManager.isTracking {
                        HStack(spacing: 24) {
                            statBox(title: "TIEMPO", value: formattedTime(locationManager.elapsedTime))
                            statBox(title: "MEDIA", value: String(format: "%.0f km/h", locationManager.averageSpeedKmh))
                            statBox(title: "MÁXIMA", value: String(format: "%.0f km/h", locationManager.maxSpeedKmh))
                        }
                        Text(String(format: "%.2f km recorridos", locationManager.distanceKm))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button {
                        if locationManager.isTracking {
                            let record = locationManager.stopRoute()
                            routeStore.add(record)
                            lastRoute = record
                            prepareShare(for: record)
                        } else {
                            locationManager.startRoute()
                        }
                    } label: {
                        Text(locationManager.isTracking ? "TERMINAR RUTA" : "EMPEZAR RUTA")
                            .font(.title2.bold())
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(startButtonColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(!locationManager.isTracking && !locationManager.isGPSActive)
                    .padding(.horizontal)

                    if !locationManager.isTracking && !locationManager.isGPSActive {
                        Text("Esperando señal GPS antes de poder empezar…")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }

                    Button {
                        showHistory = true
                    } label: {
                        Label("Ver historial de rutas", systemImage: "clock.arrow.circlepath")
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding(.bottom, 16)
                }
                .padding()
            }
            .navigationTitle("Speed Tracker")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showHistory) {
                HistoryView(routeStore: routeStore)
            }
            .sheet(isPresented: $showShareSheet) {
                ActivityShareSheet(items: shareItems)
            }
            .alert("Permiso de ubicación necesario", isPresented: $showPermissionAlert) {
                Button("Abrir Ajustes") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("Para medir tu velocidad con la pantalla bloqueada, activa 'Siempre' en el permiso de ubicación desde Ajustes.")
            }
            .onChange(of: locationManager.authorizationStatus) { newValue in
                if newValue == .denied || newValue == .restricted {
                    showPermissionAlert = true
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var startButtonColor: Color {
        if locationManager.isTracking { return .red }
        return locationManager.isGPSActive ? .green : .gray
    }

    private func prepareShare(for route: RouteRecord) {
        RouteSnapshotGenerator.generate(for: route) { image in
            DispatchQueue.main.async {
                var items: [Any] = [route.shareText]
                if let image {
                    items.insert(image, at: 0)
                }
                self.shareItems = items
                self.showShareSheet = true
            }
        }
    }

    private func statBox(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func formattedTime(_ interval: TimeInterval) -> String {
        let m = Int(interval) / 60
        let s = Int(interval) % 60
        return String(format: "%02d:%02d", m, s)
    }
}

#Preview {
    ContentView()
}
