//
//  RouteStore.swift
//  react-native-maps-indoors
//

import Foundation

/// Keeps the routes the directions service module returned, so the renderer module can render the
/// very instance instead of decoding the copy that comes back from JavaScript (SPEX-2782).
///
/// Only that instance carries the endpoints the SDK reports with the directions Insights events,
/// and neither SDK encodes them, so a decoded copy reports none.
///
/// Holds at most `capacity` routes and forgets the least recently used, since JavaScript never says
/// when it is done with one. A forgotten route still renders, from its JSON, just without endpoints.
/// Lookups count as use, so a route the app keeps setting stays. Rendering a kept route again is
/// safe: the SDK resolves its endpoints once and reads them on every event.
final class RouteStore<Route>: @unchecked Sendable {
    private let lock = NSLock()
    private let capacity: Int
    private var routes: [String: Route] = [:]
    /// Keys in `routes`, least recently used first.
    private var order: [String] = []

    init(capacity: Int) {
        precondition(capacity > 0, "A RouteStore must be able to hold a route")
        self.capacity = capacity
    }

    /// Keeps `route` and returns the key to look it up by.
    func keep(_ route: Route) -> String {
        let key = UUID().uuidString
        lock.lock()
        defer { lock.unlock() }
        routes[key] = route
        order.append(key)
        if order.count > capacity {
            routes[order.removeFirst()] = nil
        }
        return key
    }

    /// The route kept under `key`, if it is still kept.
    func route(for key: String) -> Route? {
        lock.lock()
        defer { lock.unlock() }
        guard let route = routes[key], let index = order.firstIndex(of: key) else {
            return nil
        }
        order.append(order.remove(at: index))
        return route
    }

    /// Forgets every route, when MapsIndoors loads or is destroyed: a route belongs to the solution that
    /// was loaded when it was requested.
    func removeAll() {
        lock.lock()
        defer { lock.unlock() }
        routes.removeAll()
        order.removeAll()
    }
}
