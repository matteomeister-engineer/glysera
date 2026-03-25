import SwiftUI
import WatchKit
import WatchConnectivity

// ─────────────────────────────────────────────────────────────
// MARK: - Watch App entry point
// ─────────────────────────────────────────────────────────────

@main
struct GlyseraWatchApp: App {
    @StateObject private var store = WatchGlucoseStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - Glucose store (WatchConnectivity)
// Receives updates from the iPhone app via sendMessage / context.
// ─────────────────────────────────────────────────────────────

class WatchGlucoseStore: NSObject, ObservableObject, WCSessionDelegate {
    @Published var value:  String = "--"
    @Published var trend:  String = "→"
    @Published var unit:   String = "mg/dL"
    @Published var status: String = "inRange"
    @Published var lastUpdated: Date? = nil

    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
        // Try loading from shared App Group on launch
        loadFromSharedStore()
    }

    // ── WCSessionDelegate ──────────────────────────────────────

    func session(_ session: WCSession,
                 activationDidCompleteWith state: WCSessionActivationState,
                 error: Error?) {}

    // Receives real-time push from iPhone
    func session(_ session: WCSession,
                 didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            self.apply(message)
        }
    }

    // Receives context update (background sync)
    func session(_ session: WCSession,
                 didReceiveApplicationContext context: [String: Any]) {
        DispatchQueue.main.async {
            self.apply(context)
        }
    }

    private func apply(_ dict: [String: Any]) {
        value  = dict["value"]  as? String ?? value
        trend  = dict["trend"]  as? String ?? trend
        unit   = dict["unit"]   as? String ?? unit
        status = dict["status"] as? String ?? status
        lastUpdated = Date()
    }

    // ── Shared App Group fallback ──────────────────────────────

    private func loadFromSharedStore() {
        guard
            let url = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: "group.com.matteomeister.glysera")?
                .appendingPathComponent("glucose_latest.json"),
            let data = try? Data(contentsOf: url),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return }
        apply(json)
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - Main watch face UI
// ─────────────────────────────────────────────────────────────

struct ContentView: View {
    @EnvironmentObject var store: WatchGlucoseStore

    var glucoseColor: Color {
        switch store.status {
        case "urgentLow", "urgentHigh": return Color(red: 1.0, green: 0.3, blue: 0.3)
        case "low", "high":             return Color(red: 1.0, green: 0.65, blue: 0.2)
        default:                        return Color(red: 0.78, green: 1.0, blue: 0.0)
        }
    }

    var body: some View {
        ZStack {
            Color(red: 0.12, green: 0.12, blue: 0.12)
                .ignoresSafeArea()

            VStack(spacing: 6) {
                // Brand
                Text("Glysera")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.4))

                Spacer()

                // Pulse ring
                ZStack {
                    Circle()
                        .stroke(glucoseColor.opacity(0.2), lineWidth: 3)
                        .frame(width: 80, height: 80)

                    Circle()
                        .stroke(glucoseColor.opacity(0.08), lineWidth: 3)
                        .frame(width: 96, height: 96)

                    VStack(spacing: 2) {
                        Text(store.value)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(glucoseColor)
                            .minimumScaleFactor(0.6)

                        Text(store.trend)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(glucoseColor)
                    }
                }

                Text(store.unit)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))

                Spacer()

                // Last updated
                if let ts = store.lastUpdated {
                    Text(RelativeDateTimeFormatter().localizedString(for: ts, relativeTo: Date()))
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.3))
                }
            }
            .padding()
        }
    }
}
