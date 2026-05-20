import Foundation
import SwiftUI

// V0.1.1 STUB: AlarmKit imports temporarily removed.
// First we get the build pipeline working end-to-end + TestFlight install.
// Then we add AlarmKit calls back in V0.2 once we can iterate with
// Xcode local previews.

@MainActor
@Observable
final class AlarmController {
    static let shared = AlarmController()

    var lastFiredAt: Date?
    var lastSound: String = "—"
    var authorizationStatus: String = "stub"
    var log: [String] = []

    private init() {
        appendLog("controller init (AlarmKit stub)")
    }

    func refreshAuthorization() async {
        authorizationStatus = "stub-pending-real-AlarmKit"
        appendLog("auth refresh stub")
    }

    func requestAuthorization() async {
        appendLog("requestAuthorization stub — real AlarmKit comes in V0.2")
    }

    func schedule(in seconds: TimeInterval, soundName: String) async {
        let fireDate = Date().addingTimeInterval(seconds)
        lastFiredAt = fireDate
        lastSound = soundName
        appendLog("STUB: would schedule \(soundName) in \(Int(seconds))s")
    }

    func cancelAll() async {
        appendLog("STUB: cancel all (no real alarms scheduled)")
    }

    private func appendLog(_ entry: String) {
        let ts = formattedTime(Date())
        let line = "[\(ts)] \(entry)"
        log.insert(line, at: 0)
        if log.count > 100 { log = Array(log.prefix(100)) }
        print("[Rano] \(line)")
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
}
