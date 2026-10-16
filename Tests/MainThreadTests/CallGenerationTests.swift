import Dispatch
import Testing

@testable import MainThread

/// `CallGeneration` keeps last-call-wins for `setRoute`, `setDefaultRouteStopIcon` and `setOptions`,
/// whose downloads can finish out of order.
@Suite("CallGeneration")
struct CallGenerationTests {
    @Test("A token is current until a later one is taken")
    func latestTokenIsCurrent() {
        let generation = CallGeneration()

        let first = generation.next()
        #expect(generation.isCurrent(first))

        let second = generation.next()
        #expect(!generation.isCurrent(first))
        #expect(generation.isCurrent(second))
    }

    @Test("Concurrent callers each get a distinct token, and only the last is current")
    func concurrentTokensAreDistinct() {
        let generation = CallGeneration()
        let count = 1_000
        var tokens = [UInt64](repeating: 0, count: count)

        tokens.withUnsafeMutableBufferPointer { buffer in
            DispatchQueue.concurrentPerform(iterations: count) { buffer[$0] = generation.next() }
        }

        #expect(Set(tokens).count == count)
        #expect(tokens.filter(generation.isCurrent).count == 1)
        #expect(generation.isCurrent(tokens.max()!))
    }
}
