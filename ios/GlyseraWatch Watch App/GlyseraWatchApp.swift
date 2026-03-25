import SwiftUI
import WatchKit
import WatchConnectivity
import Combine

// ─────────────────────────────────────────────────────────────
// MARK: - App entry point
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
// MARK: - Data store + WatchConnectivity
// ─────────────────────────────────────────────────────────────

class WatchGlucoseStore: NSObject, ObservableObject, WCSessionDelegate {
    @Published var value:   String  = "107"
    @Published var unit:    String  = "mg/dL"
    @Published var trend:   String  = "→"
    @Published var status:  String  = "inRange"
    @Published var history: [Double] = [95, 98, 102, 110, 115, 108, 104, 100, 102, 105, 109, 106]

    private var pollTimer: Timer?

    override init() {
        super.init()
        // WatchConnectivity — works on real device
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
        // Read JSON file immediately
        loadFromSharedStore()
        // Poll every 5 seconds — reliable on simulator
        pollTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.loadFromSharedStore()
        }
    }

    deinit { pollTimer?.invalidate() }

    func session(_ session: WCSession,
                 activationDidCompleteWith state: WCSessionActivationState,
                 error: Error?) {}

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async { self.apply(message) }
    }

    func session(_ session: WCSession, didReceiveApplicationContext context: [String: Any]) {
        DispatchQueue.main.async { self.apply(context) }
    }

    private func apply(_ dict: [String: Any]) {
        value  = dict["value"]  as? String ?? value
        trend  = dict["trend"]  as? String ?? trend
        unit   = dict["unit"]   as? String ?? unit
        status = dict["status"] as? String ?? status
        if let h = dict["history"] as? [Double], !h.isEmpty {
            history = h
        }
    }

    // Read directly from the shared JSON file written by GlucoseSharedStore.
    // Priority: App Group (real device) → simulator file scan (same Mac)
    private func loadFromSharedStore() {
        if let url = appGroupURL(), let data = try? Data(contentsOf: url),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            DispatchQueue.main.async { self.apply(json) }
            return
        }
        // Simulator: scan all CoreSimulator devices for the file
        if let url = scanSimulatorDevices(), let data = try? Data(contentsOf: url),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            DispatchQueue.main.async { self.apply(json) }
        }
    }

    private func appGroupURL() -> URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.com.matteomeister.glysera")?
            .appendingPathComponent("glucose_latest.json")
    }

    // Scan ALL CoreSimulator devices for glucose_latest.json.
    // The Watch runs under a different device UUID than the iPhone,
    // so we build the Devices path from a fixed Mac home-style base
    // extracted from our own Documents URL, then scan every device.
    private func scanSimulatorDevices() -> URL? {
        guard let docs = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }

        // docs = file:///Users/<user>/Library/Developer/CoreSimulator/Devices/<watchUDID>/
        //         data/Containers/Data/Application/<appUUID>/Documents
        // Walk up 6 levels → .../CoreSimulator/Devices/
        var devicesDir = docs
        for _ in 0..<6 { devicesDir = devicesDir.deletingLastPathComponent() }

        // Now scan EVERY device UUID (iPhone, Watch, iPad…) — not just our own
        guard let allDevices = try? FileManager.default
            .contentsOfDirectory(at: devicesDir, includingPropertiesForKeys: nil) else { return nil }

        for deviceURL in allDevices {
            let appsDir = deviceURL.appendingPathComponent("data/Containers/Data/Application")
            guard let appUUIDs = try? FileManager.default
                .contentsOfDirectory(at: appsDir, includingPropertiesForKeys: nil) else { continue }
            for appURL in appUUIDs {
                let candidate = appURL.appendingPathComponent("Documents/glucose_latest.json")
                if FileManager.default.fileExists(atPath: candidate.path) {
                    return candidate
                }
            }
        }
        return nil
    }

    var glucoseColor: Color {
        switch status {
        case "urgentLow", "urgentHigh": return Color(red: 1.0, green: 0.3, blue: 0.3)
        case "low", "high":             return Color(red: 1.0, green: 0.65, blue: 0.2)
        default:                        return Color(red: 0.78, green: 1.0, blue: 0.0)
        }
    }

    var trendLabel: String {
        switch trend {
        case "↑↑": return "Rapidly rising"
        case "↑":  return "Rising"
        case "↗":  return "Slowly rising"
        case "→":  return "Stable"
        case "↘":  return "Slowly falling"
        case "↓":  return "Falling"
        case "↓↓": return "Rapidly falling"
        default:   return "Stable"
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - Smooth curve with gradient fill (matches reference)
// ─────────────────────────────────────────────────────────────

struct GlucoseChartShape: Shape {
    let values: [Double]
    var closedForFill: Bool = false

    func path(in rect: CGRect) -> Path {
        guard values.count > 1 else { return Path() }

        let minV = (values.min() ?? 60) - 10
        let maxV = (values.max() ?? 200) + 10
        let range = maxV - minV
        // Reserve 5pt on right for the dot so the curve ends exactly at it
        let drawWidth = rect.width - 5

        func pt(_ i: Int) -> CGPoint {
            let x = drawWidth * CGFloat(i) / CGFloat(values.count - 1)
            let y = rect.height * (1 - CGFloat((values[i] - minV) / range))
            return CGPoint(x: x, y: y)
        }

        var path = Path()
        let points = (0..<values.count).map { pt($0) }

        // Catmull-Rom → cubic bezier for smooth curve
        path.move(to: points[0])
        for i in 1..<points.count {
            let prev = points[max(0, i - 2)]
            let p0   = points[i - 1]
            let p1   = points[i]
            let next = points[min(points.count - 1, i + 1)]

            let cp1 = CGPoint(
                x: p0.x + (p1.x - prev.x) / 6,
                y: p0.y + (p1.y - prev.y) / 6
            )
            let cp2 = CGPoint(
                x: p1.x - (next.x - p0.x) / 6,
                y: p1.y - (next.y - p0.y) / 6
            )
            path.addCurve(to: p1, control1: cp1, control2: cp2)
        }

        if closedForFill {
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.closeSubpath()
        }

        return path
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - Root: TabView with page-style swiping
// ─────────────────────────────────────────────────────────────

struct ContentView: View {
    @EnvironmentObject var store: WatchGlucoseStore

    var body: some View {
        TabView {
            GlucosePage()
                .environmentObject(store)
            PredictionPage()
                .environmentObject(store)
        }
        .tabViewStyle(.page)
        .background(Color(red: 0.08, green: 0.08, blue: 0.08))
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - Page 1: Live glucose + chart
// ─────────────────────────────────────────────────────────────

struct GlucosePage: View {
    @EnvironmentObject var store: WatchGlucoseStore

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.08, blue: 0.08).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                // ── Header ──────────────────────────────────
                HStack {
                    Text("GLYSERA")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.35))
                        .kerning(1.5)
                    Spacer()
                    Text(store.trend)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(store.glucoseColor)
                }
                .padding(.horizontal, 14)
                .padding(.top, 12)

                Text(store.trendLabel)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(store.glucoseColor)
                    .padding(.horizontal, 14)
                    .padding(.top, 2)

                // ── Chart ───────────────────────────────────
                GeometryReader { geo in
                    ZStack(alignment: .bottom) {
                        GlucoseChartShape(values: store.history, closedForFill: true)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: store.glucoseColor.opacity(0.45), location: 0),
                                        .init(color: store.glucoseColor.opacity(0.15), location: 0.5),
                                        .init(color: store.glucoseColor.opacity(0.0),  location: 1)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        GlucoseChartShape(values: store.history, closedForFill: false)
                            .stroke(store.glucoseColor,
                                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                        if store.history.count > 1 {
                            let minV = (store.history.min() ?? 60) - 10
                            let maxV = (store.history.max() ?? 200) + 10
                            let range = maxV - minV
                            let lastVal = store.history.last ?? 100
                            let yFrac = CGFloat(1 - (lastVal - minV) / range)
                            let dotX = geo.size.width - 5
                            let dotY = geo.size.height * yFrac
                            Circle()
                                .fill(Color(red: 0.08, green: 0.08, blue: 0.08))
                                .frame(width: 10, height: 10)
                                .overlay(Circle().stroke(store.glucoseColor, lineWidth: 2.5))
                                .position(x: dotX, y: dotY)
                        }
                    }
                }
                .frame(height: 62)
                .padding(.horizontal, 6)
                .padding(.top, 6)

                // ── Big value ────────────────────────────────
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(store.value)
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.5)
                    Text(store.unit)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                        .padding(.bottom, 4)
                    Spacer()
                    Text("Live")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(store.glucoseColor)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(store.glucoseColor.opacity(0.15))
                                .overlay(RoundedRectangle(cornerRadius: 6)
                                    .stroke(store.glucoseColor.opacity(0.3), lineWidth: 0.5))
                        )
                        .padding(.bottom, 4)
                }
                .padding(.horizontal, 14)
                .padding(.top, 6)

                // Reserved space for page indicator dots
                Spacer(minLength: 20)
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - Page 2: AI Prediction
// ─────────────────────────────────────────────────────────────

struct PredictionPage: View {
    @EnvironmentObject var store: WatchGlucoseStore

    // Compute a simple 30-min prediction from rate of change
    var prediction30: String {
        guard store.history.count >= 3 else { return store.value }
        let last  = store.history[store.history.count - 1]
        let prev  = store.history[store.history.count - 3]
        let rate  = (last - prev) / 2          // mg/dL per reading interval
        let pred  = last + rate * 6            // 6 intervals × 5min = 30min
        let clamped = min(max(pred, 40), 400)
        return String(format: "%.0f", clamped)
    }

    var predictionStatus: String {
        guard let val = Double(prediction30) else { return "inRange" }
        if val < 54  { return "urgentLow" }
        if val < 70  { return "low" }
        if val > 250 { return "urgentHigh" }
        if val > 180 { return "high" }
        return "inRange"
    }

    var predColor: Color {
        switch predictionStatus {
        case "urgentLow", "urgentHigh": return Color(red: 1.0, green: 0.3, blue: 0.3)
        case "low", "high":             return Color(red: 1.0, green: 0.65, blue: 0.2)
        default:                        return Color(red: 0.78, green: 1.0, blue: 0.0)
        }
    }

    // +10, +20, +30 min predictions
    var timePoints: [(label: String, value: String, color: Color)] {
        guard store.history.count >= 3 else { return [] }
        let last = store.history[store.history.count - 1]
        let prev = store.history[store.history.count - 3]
        let rate = (last - prev) / 2
        return [
            ("+10m", fmt(last + rate * 2), colorFor(last + rate * 2)),
            ("+20m", fmt(last + rate * 4), colorFor(last + rate * 4)),
            ("+30m", fmt(last + rate * 6), colorFor(last + rate * 6)),
        ]
    }

    func fmt(_ v: Double) -> String { String(format: "%.0f", min(max(v, 40), 400)) }
    func colorFor(_ v: Double) -> Color {
        if v < 54 || v > 250 { return Color(red: 1.0, green: 0.3, blue: 0.3) }
        if v < 70 || v > 180 { return Color(red: 1.0, green: 0.65, blue: 0.2) }
        return Color(red: 0.78, green: 1.0, blue: 0.0)
    }

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.08, blue: 0.08).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                // ── Header ──────────────────────────────────
                HStack {
                    HStack(spacing: 3) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(store.glucoseColor)
                        Text("AI PREDICTION")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white.opacity(0.35))
                            .kerning(1.0)
                    }
                    Spacer()
                    Text("30 min")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.3))
                }
                .padding(.horizontal, 14)
                .padding(.top, 12)

                // ── Trend direction ──────────────────────────
                Text(store.trendLabel)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(store.glucoseColor)
                    .padding(.horizontal, 14)
                    .padding(.top, 2)

                Spacer()

                // ── Big predicted value ──────────────────────
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(prediction30)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(predColor)
                        .minimumScaleFactor(0.5)
                    Text(store.unit)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                        .padding(.bottom, 5)
                }
                .padding(.horizontal, 14)

                Spacer()

                // ── Time point pills ─────────────────────────
                HStack(spacing: 6) {
                    // Current
                    VStack(spacing: 2) {
                        Text(store.value)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(store.glucoseColor)
                        Text("Now")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.white.opacity(0.35))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(store.glucoseColor.opacity(0.1))
                    )

                    ForEach(timePoints, id: \.label) { pt in
                        VStack(spacing: 2) {
                            Text(pt.value)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(pt.color)
                            Text(pt.label)
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(.white.opacity(0.35))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(pt.color.opacity(0.1))
                        )
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 12)
            }
        }
    }
}
