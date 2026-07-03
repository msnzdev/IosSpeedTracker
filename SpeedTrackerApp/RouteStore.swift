import Foundation

final class RouteStore: ObservableObject {
    @Published private(set) var routes: [RouteRecord] = []

    private let key = "saved_routes_v1"

    init() {
        load()
    }

    func add(_ route: RouteRecord) {
        routes.insert(route, at: 0)
        save()
    }

    func delete(at offsets: IndexSet) {
        routes.remove(atOffsets: offsets)
        save()
    }

    func delete(_ route: RouteRecord) {
        routes.removeAll { $0.id == route.id }
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(routes) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([RouteRecord].self, from: data) else {
            return
        }
        routes = decoded
    }
}
