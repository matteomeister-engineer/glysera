import UIKit
import Flutter
import WidgetKit
import WatchConnectivity

@main
@objc class AppDelegate: FlutterAppDelegate, WCSessionDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        GeneratedPluginRegistrant.register(with: self)

        // ── WatchConnectivity session ──────────────────────────
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }

        // ── Widget + Watch method channel ──────────────────────
        if let controller = window?.rootViewController as? FlutterViewController {
            let channel = FlutterMethodChannel(
                name: "com.matteomeister.glysera/widget",
                binaryMessenger: controller.binaryMessenger
            )

            channel.setMethodCallHandler { [weak self] (call, result) in
                switch call.method {

                case "reloadWidgets":
                    if #available(iOS 14.0, *) {
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                    result(nil)

                case "appGroupPath":
                    if let groupId = call.arguments as? String,
                       let url = FileManager.default.containerURL(
                        forSecurityApplicationGroupIdentifier: groupId) {
                        result(url.path)
                    } else {
                        result(FlutterError(
                            code: "NO_APP_GROUP",
                            message: "App Group not configured",
                            details: nil
                        ))
                    }

                case "sendToWatch":
                    // Push glucose data to paired Apple Watch
                    if let payload = call.arguments as? [String: Any] {
                        self?.sendGlucoseToWatch(payload)
                    }
                    result(nil)

                default:
                    result(FlutterMethodNotImplemented)
                }
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // ── Push to Watch ──────────────────────────────────────────
    // Uses sendMessage for real-time (Watch app open)
    // Falls back to updateApplicationContext for background sync

    private func sendGlucoseToWatch(_ payload: [String: Any]) {
        guard WCSession.default.activationState == .activated else { return }
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(
                payload,
                replyHandler: nil,
                errorHandler: nil
            )
        } else {
            try? WCSession.default.updateApplicationContext(payload)
        }
    }

    // ── WCSessionDelegate ──────────────────────────────────────

    func session(_ session: WCSession,
                 activationDidCompleteWith state: WCSessionActivationState,
                 error: Error?) {}

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
}
