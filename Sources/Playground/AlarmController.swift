import Foundation
import AlarmKit
import ActivityKit
import SwiftUI

/// Wraps AlarmKit to make scheduling test alarms trivial.
///
/// API patterns lifted from jacobsapps/ADHDAlarms (production AlarmKit app).
/// Schedules a fire-now-plus-N-seconds alarm with a chosen sound asset.
/// Watch console for `[Rano]` log lines + observe Lock Screen + Dynamic
/// Island when alarm fires — this is how we validate Silent / Focus / DND
/// bypass and custom sound loading.
@MainActor
@Observable
final class AlarmController {
    static let shared = AlarmController()

    private let manager = AlarmManager.shared

    var lastFiredAt: Date?
    var lastSound: String = "—"
    var authorizationStatus: String = "unknown"
    var log: [String] = []

    private init() {
        Task { await refreshAuthorization() }
    }

    // MARK: - Authorization

    func refreshAuthorization() async {
        let status = manager.authorizationState
        authorizationStatus = String(describing: status)
        appendLog("auth = \(authorizationStatus)")
    }

    func requestAuthorization() async {
        do {
            let status = try await manager.requestAuthorization()
            appendLog("requestAuthorization → \(status)")
            await refreshAuthorization()
        } catch {
            appendLog("auth error: \(error.localizedDescription)")
        }
    }

    // MARK: - Schedule

    /// Schedule an alarm `seconds` from now using the named sound asset.
    func schedule(in seconds: TimeInterval, soundName: String) async {
        let fireDate = Date().addingTimeInterval(seconds)
        lastFiredAt = fireDate
        lastSound = soundName

        let stopButton = AlarmButton(
            text: "Got up",
            textColor: .white,
            systemImageName: "checkmark.circle.fill"
        )

        let alertPresentation = AlarmPresentation.Alert(
            title: "Rano test alarm",
            stopButton: stopButton
        )

        let presentation = AlarmPresentation(alert: alertPresentation)

        let attributes = AlarmAttributes(
            presentation: presentation,
            metadata: RanoAlarmMetadata(),
            tintColor: .orange
        )

        let soundConfig = AlertConfiguration.AlertSound.named(soundName)

        let alertConfig = AlertConfiguration(
            title: "Rano test alarm",
            stopButton: stopButton,
            sound: soundConfig
        )

        let schedule = Alarm.Schedule.fixed(fireDate)

        let alarmConfig = AlarmManager.AlarmConfiguration(
            schedule: schedule,
            attributes: attributes,
            alertConfiguration: alertConfig
        )

        let alarmId = UUID()
        do {
            let alarm = try await manager.schedule(id: alarmId, configuration: alarmConfig)
            appendLog("scheduled \(soundName) at \(formattedTime(fireDate)) — id \(alarm.id.uuidString.prefix(8))")
        } catch {
            appendLog("schedule error: \(error.localizedDescription)")
        }
    }

    func cancelAll() async {
        appendLog("cancel all requested (manual stop only — no list API)")
        // AlarmKit doesn't expose a "list all alarms" API publicly; user
        // can dismiss via the alarm's own UI when it fires.
    }

    // MARK: - Helpers

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

struct RanoAlarmMetadata: AlarmMetadata {
    init() {}
}
