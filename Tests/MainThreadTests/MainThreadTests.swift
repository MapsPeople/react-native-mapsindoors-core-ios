import Dispatch
import Foundation
import Testing

@testable import MainThread

/// `onMainThread` is how every module method reaches the map control and directions renderer, which
/// are main-actor isolated in the iOS SDK and crash the app when touched from React Native's method
/// queue (SPEX-2633, SPEX-2686).
@Suite("onMainThread")
struct MainThreadTests {
    /// Thread-safe recorder for what the scheduled work observed.
    private final class Log: @unchecked Sendable {
        private let lock = NSLock()
        private var entries: [String] = []

        func append(_ entry: String) {
            lock.lock()
            defer { lock.unlock() }
            entries.append(entry)
        }

        var all: [String] {
            lock.lock()
            defer { lock.unlock() }
            return entries
        }
    }

    /// Resumes once every block already on the main queue has run.
    private func drainMainQueue() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async { continuation.resume() }
        }
    }

    // MARK: - Happy path

    @Test("Work scheduled from React Native's queue runs on the main thread")
    func runsOnMainThreadWhenCalledFromBackground() async {
        let log = Log()

        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                log.append(Thread.isMainThread ? "called on main" : "called off main")
                onMainThread {
                    log.append(Thread.isMainThread ? "ran on main" : "ran off main")
                    continuation.resume()
                }
            }
        }

        // Asserted here rather than inside the GCD block, so a failure is attributed to this test.
        #expect(log.all == ["called off main", "ran on main"])
    }

    @Test("Calls run in the order they were made")
    func preservesCallOrder() async {
        let log = Log()
        let callCount = 50

        // A serial queue stands in for React Native's method queue, which calls a module's methods one
        // at a time.
        let moduleQueue = DispatchQueue(label: "MainThreadTests.moduleQueue")
        await withCheckedContinuation { continuation in
            moduleQueue.async {
                for index in 0..<callCount {
                    onMainThread { log.append("\(index)") }
                }
                onMainThread { continuation.resume() }
            }
        }

        #expect(log.all == (0..<callCount).map { "\($0)" })
    }

    @MainActor
    @Test("A call made on the main thread is enqueued, not run inline")
    func mainThreadCallIsDeferred() async {
        let log = Log()

        onMainThread { log.append("work") }
        log.append("after call")

        await drainMainQueue()
        #expect(log.all == ["after call", "work"], "the work runs on a later main-queue turn, after the caller returns")
    }

    // MARK: - Negative

    @MainActor
    @Test("Work never runs on the calling background thread")
    func neverRunsOnCallingThread() async {
        let log = Log()

        // Hold the main thread while the background call is made, so the only way the work could have
        // run by the time the call returns is inline on the background thread.
        let callReturned = DispatchSemaphore(value: 0)
        DispatchQueue.global(qos: .userInitiated).async {
            onMainThread { log.append(Thread.isMainThread ? "ran on main" : "ran on background") }
            log.append("call returned")
            callReturned.signal()
        }
        waitBlockingMainThread(on: callReturned)

        #expect(log.all == ["call returned"], "nothing may run before the main thread is free")

        await drainMainQueue()
        #expect(log.all == ["call returned", "ran on main"])
    }

    @MainActor
    @Test("A main-thread call does not overtake one already enqueued from the background")
    func mainThreadCallDoesNotJumpTheQueue() async {
        let log = Log()

        let backgroundCallMade = DispatchSemaphore(value: 0)
        DispatchQueue.global(qos: .userInitiated).async {
            onMainThread { log.append("from background, made first") }
            backgroundCallMade.signal()
        }
        waitBlockingMainThread(on: backgroundCallMade)

        onMainThread { log.append("from main, made second") }

        await drainMainQueue()
        #expect(log.all == ["from background, made first", "from main, made second"])
    }

    /// Blocks the main thread until `semaphore` is signalled. Synchronous so the blocking wait stays out
    /// of an async context.
    @MainActor
    private func waitBlockingMainThread(on semaphore: DispatchSemaphore) {
        semaphore.wait()
    }
}
