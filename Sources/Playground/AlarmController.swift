import Foundation
import AlarmKit
import ActivityKit
import SwiftUI

/// Wraps AlarmKit to make scheduling test alarms trivial.
///
/// Use `schedule(in:soundName:)` to fire an alarm N seconds from now
/// with a chosen sound asset. Watch the console for the reported
/// `AlarmManager.AlarmState` transitions — this is how we validate
/// that Silent / Focus / DND were bypassed.
@MainActor
@Observable
final class AlarmController {
    static let shared = AlarmController()

    private let manager = AlarmManager.shared
    private var observerTask: Task<Void, Never>?

    var lastFiredAt: Date?
    var lastState: String = "—"
    var lastSound: String = "—"
    var authorizationStatus: String = "unknown"
    var log: [String] = []

    private init() {
        startObserving()
        Task { await refreshAuthorization() }
    }

    // MARK: - Authorization

    func refreshAuthorization() async {
        let status = await manager.authorizationState
        authorizationStatus = String(describing: status)
        appendLog("auth = \(authorizationStatus)")
    }

    func requestAuthorization() async {
        do {
            let granted = try await manager.requestAuthorization()
            appendLog("requestAuthorization → \(granted)")
            await refreshAuthorization()
        } catch {
            appendLog("auth error: \(error.localizedDescription)")
        }
    }

    // MARK: - Schedule

    /// Schedule an alarm `seconds` from now.
    /// - Parameters:
    ///   - seconds: delay before alarm fires
    ///   - soundName: file name in main bundle (e.g. "rhythm_rise" → looks for rhythm_rise.caf)
    func schedule(in seconds: TimeInterval, soundName: String) async {
        let fireDate = Date().addingTimeInterval(seconds)
        lastFiredAt = fireDate
        lastSound = soundName

        // Build alert presentation
        let title = LocalizedStringResource("Rano test alarm")
        let stopButton = AlarmButton(
            text: "Got up",
            textColor: .white,
            systemImageName: "checkmark.circle.fill"
        )
        let alertContent = AlarmPresentation.Alert(
            title: title,
            stopButton: stopButton
        )
        let presentation = AlarmPresentation(alert: alertContent)

        // Custom sound: bundle-only (iOS 26.0 has a confirmed bug for Library/Sounds fallback)
        let sound = AlertConfiguration.AlertSound.named(soundName)

        let attributes = AlarmAttributes<RanoAlarmMetadata>(
            presentation: presentation,
            metadata: RanoAlarmMetadata(label: "Test alarm: \(soundName)"),
            tintColor: .orange
        )

        let alertConfig = AlertConfiguration(
            title: title,
            stopButton: stopButton,
            sound: sound
        )

        let schedule = Alarm.Schedule.fixed(fireDate)

        let alarmConfig = AlarmManager.AlarmConfiguration<RanoAlarmMetadata>(
            schedule: schedule,
            attributes: attributes,
            alertConfiguration: alertConfig
        )

        do {
            let alarm = try await manager.schedule(id: UUID(), configuration: alarmConfig)
            appendLog("scheduled \(soundName) at \(formattedTime(fireDate)) — id \(alarm.id.uuidString.prefix(8))")
        } catch {
            appendLog("schedule error: \(error.localizedDescription)")
        }
    }

    func cancelAll() async {
        do {
            let alarms = try await manager.alarms
            for alarm in alarms {
                try await manager.cancel(id: alarm.id)
            }
            appendLog("cancelled \(alarms.count) alarms")
        } catch {
            appendLog("cancel error: \(error.localizedDescription)")
        }
    }

    // MARK: - State observation

    private func startObserving() {
        observerTask = Task { [weak self] in
            guard let self else { return }
            for await alarms in self.manager.alarmUpdates {
                await MainActor.run {
                    let summary = alarms.map { "\($0.id.uuidString.prefix(6))=\($0.state)" }
                        .joined(separator: ", ")
                    self.lastState = summary.isEmpty ? "no alarms" : summary
                    self.appendLog("state: \(self.lastState)")
                }
            }
        }
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

struct RanoAlarmMetadata: AlarmMetadata {
    let label: String
}
