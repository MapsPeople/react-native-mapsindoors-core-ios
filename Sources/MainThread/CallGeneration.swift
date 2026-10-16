//
//  CallGeneration.swift
//  react-native-maps-indoors
//

import Foundation

/// Makes last-call-wins hold for module methods that download before they apply.
///
/// Such a call can finish after a later one, and would then overwrite the later call's result. Each
/// call takes a token with ``next()`` and applies only while ``isCurrent(_:)`` - a call that finished
/// late is stale and drops its result.
///
/// The token has to be taken *synchronously*, before the call's `Task` is created. React Native
/// serialises a module's methods on one queue, and ``onMainThread`` runs them on the main queue in
/// that same order, so taking it there makes the token follow call order. Taking it inside the `Task`
/// would instead number the calls by whichever one the cooperative pool happened to schedule first,
/// which is not the order they were made in - the newer call could take the lower token and then be
/// discarded in favour of the older one.
final class CallGeneration: @unchecked Sendable {
    private let lock = NSLock()
    private var current: UInt64 = 0

    /// Takes the next token, invalidating every earlier one.
    func next() -> UInt64 {
        lock.lock()
        defer { lock.unlock() }
        current &+= 1
        return current
    }

    /// Whether `token` is still the newest, i.e. no later call has taken one.
    func isCurrent(_ token: UInt64) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return token == current
    }
}
