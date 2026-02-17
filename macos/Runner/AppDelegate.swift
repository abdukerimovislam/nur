import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private let channelName = "com.midas.aion/time_zone"

  override func applicationDidFinishLaunching(_ notification: Notification) {
    if let flutterWindow = mainFlutterWindow,
       let controller = flutterWindow.contentViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: channelName,
        binaryMessenger: controller.engine.binaryMessenger
      )

      channel.setMethodCallHandler { call, result in
        if call.method == "getLocalTimeZone" {
          result(TimeZone.current.identifier)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }
    super.applicationDidFinishLaunching(notification)
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
