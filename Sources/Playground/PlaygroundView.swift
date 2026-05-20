import SwiftUI

/// Manual test harness for AlarmKit sound reliability.
///
/// Test protocol:
///   1. Tap "Request alarm permission" once
///   2. Pick a sound preset
///   3. Tap "Fire in 30s" → put phone in different modes:
///         - Silent switch ON
///         - Focus → Sleep
///         - DND on Lock Screen
///         - AirPods connected (alarm should play through SPEAKER)
///   4. Watch the log + System for alarm behavior
struct PlaygroundView: View {
    @State private var controller = AlarmController.shared
    @State private var selectedSound = "rhythm_rise"
    @State private var delaySeconds: Double = 30

    private let sounds = ["rhythm_rise", "warm_pulse", "bright_bell", "urgent_classic"]
    private let delays: [Double] = [15, 30, 60, 300]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    statusCard
                    permissionCard
                    soundPicker
                    delayPicker
                    fireButton
                    cancelButton
                    logCard
                }
                .padding()
            }
            .navigationTitle("Rano · Sound Lab")
        }
    }

    // MARK: - Components

    private var statusCard: some View {
        GroupBox("Status") {
            VStack(alignment: .leading, spacing: 6) {
                row("Authorization", controller.authorizationStatus)
                row("Last sound", controller.lastSound)
                row("Last state", controller.lastState)
                if let date = controller.lastFiredAt {
                    row("Fires at", DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .medium))
                }
            }
        }
    }

    private var permissionCard: some View {
        GroupBox("Permission") {
            Button("Request alarm permission") {
                Task { await controller.requestAuthorization() }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var soundPicker: some View {
        GroupBox("Sound preset") {
            VStack(alignment: .leading, spacing: 8) {
                Picker("Sound", selection: $selectedSound) {
                    ForEach(sounds, id: \.self) { s in
                        Text(s).tag(s)
                    }
                }
                .pickerStyle(.segmented)
                Text("Drop a 29-sec .caf into Resources/Sounds with this name to test.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var delayPicker: some View {
        GroupBox("Fire delay") {
            Picker("Delay", selection: $delaySeconds) {
                ForEach(delays, id: \.self) { d in
                    Text("\(Int(d))s").tag(d)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var fireButton: some View {
        Button {
            Task {
                await controller.schedule(in: delaySeconds, soundName: selectedSound)
            }
        } label: {
            Label("Fire in \(Int(delaySeconds))s", systemImage: "alarm.fill")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
        .buttonStyle(.borderedProminent)
        .tint(.orange)
    }

    private var cancelButton: some View {
        Button(role: .destructive) {
            Task { await controller.cancelAll() }
        } label: {
            Label("Cancel all alarms", systemImage: "xmark.circle")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
    }

    private var logCard: some View {
        GroupBox("Log (newest first)") {
            VStack(alignment: .leading, spacing: 4) {
                if controller.log.isEmpty {
                    Text("No events yet")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(controller.log.prefix(20), id: \.self) { line in
                        Text(line)
                            .font(.system(.caption2, design: .monospaced))
                            .lineLimit(2)
                    }
                }
            }
        }
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.system(.body, design: .monospaced))
        }
        .font(.callout)
    }
}

#Preview {
    PlaygroundView()
}
