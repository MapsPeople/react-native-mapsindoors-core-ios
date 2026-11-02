import Dispatch
import Testing

@testable import RouteStore

/// `RouteStore` hands `setRoute` the route instance `getRoute` produced, which alone carries the
/// endpoints the directions Insights events report.
@Suite("RouteStore")
struct RouteStoreTests {
    @Test("A kept route comes back by its key")
    func keptRouteComesBack() {
        let store = RouteStore<String>(capacity: 2)

        let key = store.keep("route")

        #expect(store.route(for: key) == "route")
    }

    @Test("Each route gets its own key")
    func keysAreDistinct() {
        let store = RouteStore<String>(capacity: 2)

        let first = store.keep("first")
        let second = store.keep("second")

        #expect(first != second)
        #expect(store.route(for: first) == "first")
        #expect(store.route(for: second) == "second")
    }

    @Test("An unknown key finds nothing")
    func unknownKeyFindsNothing() {
        let store = RouteStore<String>(capacity: 2)
        _ = store.keep("route")

        #expect(store.route(for: "not-a-key") == nil)
    }

    @Test("Past capacity, the least recently used route is forgotten")
    func forgetsLeastRecentlyUsed() {
        let store = RouteStore<String>(capacity: 2)
        let first = store.keep("first")
        let second = store.keep("second")

        // Setting the first route again makes the second the least recently used.
        _ = store.route(for: first)
        let third = store.keep("third")

        #expect(store.route(for: first) == "first")
        #expect(store.route(for: second) == nil)
        #expect(store.route(for: third) == "third")
    }

    @Test("removeAll forgets every route, and the store keeps working after")
    func removeAllForgetsEverything() {
        let store = RouteStore<String>(capacity: 2)
        let first = store.keep("first")
        let second = store.keep("second")

        store.removeAll()
        let third = store.keep("third")

        #expect(store.route(for: first) == nil)
        #expect(store.route(for: second) == nil)
        #expect(store.route(for: third) == "third")
    }

    @Test("Concurrent use keeps at most capacity routes")
    func concurrentUseStaysBounded() {
        let store = RouteStore<Int>(capacity: 10)
        let count = 1_000
        var keys = [String](repeating: "", count: count)

        keys.withUnsafeMutableBufferPointer { buffer in
            DispatchQueue.concurrentPerform(iterations: count) { index in
                buffer[index] = store.keep(index)
                _ = store.route(for: buffer[index])
            }
        }

        #expect(Set(keys).count == count)
        #expect(keys.compactMap(store.route(for:)).count == 10)
    }
}
