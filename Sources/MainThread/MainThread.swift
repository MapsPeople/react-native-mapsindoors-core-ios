//
//  MainThread.swift
//  react-native-maps-indoors
//

import Foundation

/// Runs `work` on the main thread, which is where the MapsIndoors map control and directions
/// renderer have to be used.
///
/// React Native calls this package's module methods on their own method queue
/// (`requiresMainQueueSetup()` is `false`). `MPMapControl` and `MPDirectionsRenderer` are main-actor
/// isolated in the iOS SDK, and touching either from any other thread crashes the app (SPEX-2633,
/// SPEX-2686), so every module method that reads or writes them does that work in here and settles
/// its promise from in here too.
///
/// `work` is always enqueued, even when the caller is already on the main thread. React Native calls
/// a module's methods one at a time on its queue, and the main queue runs blocks in the order they
/// were added, so the map sees calls in the order the app made them. Running inline when already on
/// main would let such a call overtake one that was enqueued before it.
func onMainThread(_ work: @escaping @MainActor () -> Void) {
    DispatchQueue.main.async {
        MainActor.assumeIsolated(work)
    }
}
